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
