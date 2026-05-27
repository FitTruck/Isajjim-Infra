output "ai_sa_email" {
  description = "AI 서버 서비스 계정 이메일"
  value       = google_service_account.ai.email
}

output "ai_sa_name" {
  description = "AI 서버 서비스 계정 전체 이름"
  value       = google_service_account.ai.name
}
