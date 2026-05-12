output "backend_ip_address" {
  description = "백엔드 고정 외부 IP"
  value       = google_compute_address.backend_ip.address
}

output "backend_tag" {
  description = "백엔드 VM 네트워크 태그"
  value       = "${var.project_name}-backend"
}
