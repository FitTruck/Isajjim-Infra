output "ai_external_ip" {
  description = "AI 서버 VM 고정 외부 IP"
  value       = module.networking.ai_ip_address
}

output "ai_instance_name" {
  description = "AI 서버 Compute Engine 인스턴스 이름"
  value       = module.compute.instance_name
}

output "ai_sa_email" {
  description = "AI 서버 서비스 계정 이메일"
  value       = module.iam.ai_sa_email
}

output "ai_auth_token_secret_id" {
  description = "AI 서버 AUTH_TOKEN Secret ID"
  value       = module.secrets.auth_token_secret_id
}

output "ai_hf_token_secret_id" {
  description = "AI 서버 Hugging Face token Secret ID"
  value       = module.secrets.hf_token_secret_id
}

output "artifact_registry_url" {
  description = "AI 서버 Docker 이미지 Artifact Registry URL"
  value       = module.registry.repository_url
}

output "github_actions_sa_email" {
  description = "GitHub Actions용 서비스 계정 이메일"
  value       = module.github_actions.service_account_email
}

output "workload_identity_provider" {
  description = "GitHub Actions google-github-actions/auth provider 값"
  value       = module.github_actions.workload_identity_provider
}
