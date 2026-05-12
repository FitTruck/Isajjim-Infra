resource "google_project_service" "secretmanager" {
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
}

locals {
  secret_ids = [
    "jwt-secret",
    "app-encryption-key",
    "auth-token",
    "kakao-client-id",
    "kakao-client-secret",
    "kakao-admin-key",
    "google-client-id",
    "google-client-secret",
    "naver-client-id",
    "naver-client-secret",
  ]
}

# 값이 주입되는 시크릿 (db-password, gemini-api-key)
resource "google_secret_manager_secret" "db_password" {
  secret_id  = "db-password"
  depends_on = [google_project_service.secretmanager]
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_password_version" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = var.db_password
}

resource "google_secret_manager_secret" "gemini_api_key" {
  secret_id  = "gemini-api-key"
  depends_on = [google_project_service.secretmanager]
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "gemini_api_key_version" {
  secret      = google_secret_manager_secret.gemini_api_key.id
  secret_data = var.gemini_api_key
}

# 콘솔/CI에서 별도로 값을 넣는 시크릿 (자리만 생성)
resource "google_secret_manager_secret" "app_secrets" {
  for_each   = toset(local.secret_ids)
  secret_id  = each.key
  depends_on = [google_project_service.secretmanager]
  replication {
    auto {}
  }
}
