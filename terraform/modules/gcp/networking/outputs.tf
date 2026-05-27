output "ai_ip_address" {
  description = "AI 서버 고정 외부 IP"
  value       = google_compute_address.ai_ip.address
}

output "ai_network_self_link" {
  description = "AI 서버 전용 VPC self link"
  value       = google_compute_network.ai.self_link
}

output "ai_subnet_self_link" {
  description = "AI 서버 전용 subnet self link"
  value       = google_compute_subnetwork.ai.self_link
}

output "ai_tag" {
  description = "AI 서버 VM 네트워크 태그"
  value       = "${var.project_name}-ai"
}
