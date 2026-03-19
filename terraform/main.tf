# Terraform 설정
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
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
# API 활성화
# ============================================
resource "google_project_service" "compute" {
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "sqladmin" {
  service            = "sqladmin.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "artifactregistry" {
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudbuild" {
  service            = "cloudbuild.googleapis.com"
  disable_on_destroy = false
}


# ============================================
# 서비스 계정 
# ============================================
resource "google_service_account" "backend" {
  account_id   = "isajjim-backend-sa"
  display_name = "Isajjim Backend Service Account"
}

# GCS 접근 권한
resource "google_project_iam_member" "backend_storage" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.backend.email}"
}

# Cloud SQL 접근 권한
resource "google_project_iam_member" "backend_sql" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.backend.email}"
}

# Artifact Registry 읽기 권한 
resource "google_project_iam_member" "backend_registry" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.backend.email}"
}

# Cloud Build 권한
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

# Cloud Build가 VM에 SSH 접속하기 위한 권한
resource "google_project_iam_member" "cloudbuild_compute" {
  project = var.project_id
  role    = "roles/compute.osLogin"
  member  = "serviceAccount:675009148577@cloudbuild.gserviceaccount.com"
}

# 서비스 계정이 Signed URL 생성할 수 있도록 자기 자신에게 서명 권한 부여
resource "google_service_account_iam_member" "backend_token_creator" {
  service_account_id = google_service_account.backend.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${google_service_account.backend.email}"
}

# ============================================
# 방화벽 규칙 
# ============================================
resource "google_compute_firewall" "allow_ssh" {
  name          = "isajjim-allow-ssh"
  network       = "default"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["isajjim-backend"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "allow_http" {
  name          = "isajjim-allow-http"
  network       = "default"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["isajjim-backend"]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

resource "google_compute_firewall" "allow_https" {
  name          = "isajjim-allow-https"
  network       = "default"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["isajjim-backend"]

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}

# DNS 없이 IP:8080으로 직접 테스트할 때 사용 - 운영 안정화 후 제거 권장
resource "google_compute_firewall" "allow_spring" {
  name          = "isajjim-allow-spring"
  network       = "default"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["isajjim-backend"]

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
}


# ============================================
# 고정 외부 IP (AWS Elastic IP와 동일)
# ============================================
resource "google_compute_address" "backend_ip" {
  name       = "isajjim-backend-ip"
  region     = var.region
  depends_on = [google_project_service.compute]
}


# ============================================
# Cloud Storage - 이미지 업로드용 버킷
# ============================================
resource "google_storage_bucket" "images" {
  name                        = "${var.project_name}-images"
  location                    = var.region
  uniform_bucket_level_access = true

  versioning {
    enabled = false
  }

  lifecycle_rule {
    condition { age = 90 }
    action { type = "Delete" }
  }

  cors {
    origin = [
      "https://isajjim.kro.kr",
      "https://isajjim.web.app",
      "https://isajjim.firebaseapp.com"
    ]
    method          = ["GET", "PUT", "POST"]
    response_header = ["Content-Type"]
    max_age_seconds = 3600
  }
}


# ============================================
# Cloud Storage - 3D PLY 결과물 버킷
# ============================================
resource "google_storage_bucket" "assets" {
  name                        = "${var.project_name}-3d-assets"
  location                    = var.region
  uniform_bucket_level_access = true

  versioning {
    enabled = false
  }

  lifecycle_rule {
    condition { age = 90 }
    action { type = "Delete" }
  }
}


# ============================================
# Cloud SQL MySQL 8.0 
# ============================================
resource "google_sql_database_instance" "main" {
  name                = "${var.project_id}-db"
  database_version    = "MYSQL_8_0"
  region              = var.region
  deletion_protection = false

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled = true

      # 백엔드 VM 고정 IP만 DB 접근 허용
      authorized_networks {
        name  = "backend-vm"
        value = google_compute_address.backend_ip.address
      }
    }

    backup_configuration {
      enabled = false
    }

    maintenance_window {
      hour = 19  # UTC 19:00 = KST 04:00
      day  = 7
    }
  }

  depends_on = [google_project_service.sqladmin]
}

resource "google_sql_database" "isajjim" {
  name     = "isajjim"
  instance = google_sql_database_instance.main.name
}

resource "google_sql_user" "app_user" {
  name     = "isajjim-user"
  instance = google_sql_database_instance.main.name
  password = var.db_password
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
# 백엔드 VM 
# ============================================
resource "google_compute_instance" "backend" {
  name         = "isajjim-backend"
  machine_type = "e2-medium"
  zone = var.zone

  depends_on = [
    google_project_service.compute,
    google_compute_address.backend_ip
  ]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 20
      type  = "pd-balanced"
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.backend_ip.address
    }
  }

  tags = ["isajjim-backend"]

  service_account {
    email  = google_service_account.backend.email
    scopes = ["cloud-platform"]
  }

  # VM 최초 부팅 시 자동 설치 
  metadata = {
    startup-script = <<-EOF
      #!/bin/bash
      set -e

      apt-get update -y

      # Docker 설치
      apt-get install -y docker.io
      systemctl enable docker
      systemctl start docker
      usermod -aG docker ubuntu

      # Docker Compose 설치
      curl -SL https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-linux-x86_64 \
        -o /usr/local/bin/docker-compose
      chmod +x /usr/local/bin/docker-compose

      # Nginx, Certbot 설치
      apt-get install -y nginx
      apt-get install -y certbot python3-certbot-nginx

      echo "Startup script completed" >> /var/log/startup-script.log
    EOF
  }
}
