output "backend_ip_address" {
  description = "백엔드 고정 외부 IP"
  value       = google_compute_address.backend_ip.address
}

output "private_vpc_connection_id" {
  description = "VPC Peering 연결 ID (DB 모듈 depends_on 용)"
  value       = google_service_networking_connection.private_vpc_connection.id
}

output "backend_tag" {
  description = "백엔드 VM 네트워크 태그"
  value       = "${var.project_name}-backend"
}
