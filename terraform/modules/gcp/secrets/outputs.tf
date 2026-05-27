output "auth_token_secret_id" {
  description = "AI 서버 AUTH_TOKEN Secret ID"
  value       = google_secret_manager_secret.ai["auth_token"].secret_id
}

output "hf_token_secret_id" {
  description = "AI 서버 Hugging Face token Secret ID"
  value       = google_secret_manager_secret.ai["hf_token"].secret_id
}
