output "db_password_secret_version_id" {
  description = "db-password 시크릿 버전 ID (compute 모듈 depends_on 용)"
  value       = google_secret_manager_secret_version.db_password_version.id
}

output "gemini_api_key_secret_version_id" {
  description = "gemini-api-key 시크릿 버전 ID (compute 모듈 depends_on 용)"
  value       = google_secret_manager_secret_version.gemini_api_key_version.id
}
