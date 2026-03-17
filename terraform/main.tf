# Terraform 설정
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# GCP 프로바이더 설정
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# ============================================
# Cloud Storage - 이미지 업로드용 버킷
# ============================================
resource "google_storage_bucket" "images" {
  name     = "${var.project_name}-images"
  location = var.region

  # 버전 관리 (실수로 삭제 방지)
  versioning {
    enabled = false
  }

  # 비용 절약: 90일 후 자동 삭제
  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type = "Delete"
    }
  }

  # 균일한 접근 제어
  uniform_bucket_level_access = true
}

# ============================================
# 서비스 계정 추가 
# ============================================

# 서비스 계정 생성
resource "google_service_account" "backend" {
  account_id   = "isajjim-backend-sa"
  display_name = "Isajjim Backend Service Account"
}

# Cloud SQL 접근 권한
resource "google_project_iam_member" "backend_sql" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.backend.email}"
}

# GCS 접근 권한
resource "google_project_iam_member" "backend_storage" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.backend.email}"
}

# Cloud Build 서비스 계정 권한
resource "google_project_iam_member" "cloudbuild_run" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:675009148577@cloudbuild.gserviceaccount.com"
}

resource "google_project_iam_member" "cloudbuild_sa" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:675009148577@cloudbuild.gserviceaccount.com"
}

resource "google_project_iam_member" "cloudbuild_registry" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:675009148577@cloudbuild.gserviceaccount.com"
}

# ============================================
# Cloud Storage - 3D PLY 결과물 버킷
# ============================================
resource "google_storage_bucket" "assets" {
  name     = "${var.project_name}-3d-assets"
  location = var.region

  versioning {
    enabled = false
  }

  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type = "Delete"
    }
  }

  uniform_bucket_level_access = true
}

# ============================================
# Cloud SQL - MySQL 8.0
# ============================================

# Cloud SQL Admin API 활성화
resource "google_project_service" "sqladmin" {
  service = "sqladmin.googleapis.com"
}

resource "google_sql_database_instance" "main" {
  name             = "${var.project_id}-db"
  database_version = "MYSQL_8_0"
  region           = var.region

  settings {
    tier = "db-f1-micro"    # 가장 저렴한 티어

    ip_configuration {
      ipv4_enabled = true
    }

    backup_configuration {
      enabled = false    # 크레딧 절약
    }
  }

  # Terraform destroy 시 DB 삭제 허용
  deletion_protection = false

  depends_on = [google_project_service.sqladmin]
}

# 데이터베이스 생성
resource "google_sql_database" "isajjim" {
  name     = "isajjim"
  instance = google_sql_database_instance.main.name
}

# DB 사용자 생성
resource "google_sql_user" "app_user" {
  name     = "isajjim-user"
  instance = google_sql_database_instance.main.name
  password = var.db_password
}

# ============================================
# 필요한 API 활성화
# ============================================
resource "google_project_service" "run" {
  service = "run.googleapis.com"
}

resource "google_project_service" "artifactregistry" {
  service = "artifactregistry.googleapis.com"
}

resource "google_project_service" "cloudbuild" {
  service = "cloudbuild.googleapis.com"
}

# ============================================
# Artifact Registry - Docker 이미지 저장소
# ============================================
resource "google_artifact_registry_repository" "main" {
  location      = var.region
  repository_id = "isajjim-repo"
  format        = "DOCKER"

  depends_on = [google_project_service.artifactregistry]
}

# ============================================
# Cloud Run - 백엔드
# ============================================
resource "google_cloud_run_v2_service" "backend" {
  name     = "isajjim-backend"
  location = var.region

  template {
    scaling {
      min_instance_count = 0
      max_instance_count = 5
    }

    service_account = google_service_account.backend.email

    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [google_sql_database_instance.main.connection_name]
      }
    }

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/isajjim-repo/backend:latest"

      ports {
        container_port = 8080
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }

      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }

      env {
        name  = "SPRING_PROFILES_ACTIVE"
        value = "dev"
      }
      env {
        name  = "DB_URL"
        value = "jdbc:mysql:///${google_sql_database.isajjim.name}?cloudSqlInstance=${google_sql_database_instance.main.connection_name}&socketFactory=com.google.cloud.sql.mysql.SocketFactory&unixDomainSocket=/cloudsql/${google_sql_database_instance.main.connection_name}"
      }
      env {
        name  = "DB_USERNAME"
        value = "isajjim-user"
      }
      env {
        name  = "DB_PASSWORD"
        value = var.db_password
      }
      env {
        name  = "AI_BASE_URL"
        value = "http://placeholder:8000"
      }
      env {
        name  = "AI_USE_SERVER"
        value = "false"
      }
      env {
        name  = "GEMINI_API_KEY"
        value = var.gemini_api_key
      }
      env {
        name  = "GEMINI_MODEL"
        value = "gemini-flash-latest"
      }
      env {
        name  = "GOOGLE_PROJECT_ID"
        value = var.project_id
      }
      env {
        name  = "GOOGLE_GCS_BUCKET"
        value = google_storage_bucket.images.name
      }
      env {
        name  = "FRONTEND_URL"
        value = "https://isajjim.kro.kr"
      }
      env {
        name  = "ESTIMATE_EXTRA_VOLUME_RATIO"
        value = "1.1"
      }
      env {
        name  = "DEV_SWAGGER_URL"
        value = "https://isajjim-backend-egwdefgu5q-du.a.run.app"
      }
    }
  }

  depends_on = [
    google_project_service.run,
    google_artifact_registry_repository.main
  ]
}


# Cloud Run을 외부에서 접근 가능하게 설정
resource "google_cloud_run_v2_service_iam_member" "public" {
  name     = google_cloud_run_v2_service.backend.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
}
