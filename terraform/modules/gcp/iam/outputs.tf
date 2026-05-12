output "backend_sa_email" {
  description = "백엔드 서비스 계정 이메일"
  value       = google_service_account.backend.email
}

output "backend_sa_name" {
  description = "백엔드 서비스 계정 전체 이름"
  value       = google_service_account.backend.name
}

output "cloudbuild_sa_email" {
  description = "Cloud Build 서비스 계정 이메일"
  value       = google_service_account.cloudbuild.email
}

output "cloudbuild_sa_id" {
  description = "Cloud Build 서비스 계정 ID (cicd 모듈 input 용)"
  value       = google_service_account.cloudbuild.id
}
