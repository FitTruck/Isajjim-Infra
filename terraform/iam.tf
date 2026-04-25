#각종 권한 설정

data "google_project" "current" {
  project_id = var.project_id
}

resource "google_service_account" "backend" {
  account_id   = "isajjim-backend-sa"
  display_name = "Isajjim Backend Service Account"
}

resource "google_project_iam_member" "backend_storage" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.backend.email}"
}


resource "google_project_iam_member" "backend_registry" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.backend.email}"
}

resource "google_project_iam_member" "backend_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.backend.email}"
}

# Cloud Build 전용 서비스 계정
resource "google_service_account" "cloudbuild" {
  account_id   = "isajjim-cloudbuild-sa"
  display_name = "Isajjim Cloud Build Service Account"
}

# Docker 이미지 push 권한
resource "google_project_iam_member" "cloudbuild_registry" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.cloudbuild.email}"
}

# SSH 터널을 통한 VM 접근 권한 (IAP)
resource "google_project_iam_member" "cloudbuild_iap" {
  project = var.project_id
  role    = "roles/iap.tunnelResourceAccessor"
  member  = "serviceAccount:${google_service_account.cloudbuild.email}"
}

# IAP SSH 접속 대상 VM 조회 권한
resource "google_project_iam_member" "cloudbuild_viewer" {
  project = var.project_id
  role    = "roles/compute.viewer"
  member  = "serviceAccount:${google_service_account.cloudbuild.email}"
}

# VM SSH 키 주입 권한 (OS Login 미사용 환경에서 gcloud compute ssh 동작에 필요)
resource "google_project_iam_member" "cloudbuild_instance_admin" {
  project = var.project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.cloudbuild.email}"
}

# Cloud Build 로그 쓰기 권한 
resource "google_project_iam_member" "cloudbuild_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloudbuild.email}"
}

# Cloud Build 에이전트가 전용 SA를 사용할 수 있도록 허용 
resource "google_service_account_iam_member" "cloudbuild_agent_token_creator" {
  service_account_id = google_service_account.cloudbuild.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"
}

resource "google_service_account_iam_member" "cloudbuild_backend_sa_user" {
  service_account_id = google_service_account.backend.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.cloudbuild.email}"
}
