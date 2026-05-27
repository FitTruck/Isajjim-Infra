output "instance_name" {
  description = "AI 서버 Compute Engine 인스턴스 이름"
  value       = google_compute_instance.ai.name
}

output "instance_id" {
  description = "AI 서버 Compute Engine 인스턴스 ID"
  value       = google_compute_instance.ai.id
}
