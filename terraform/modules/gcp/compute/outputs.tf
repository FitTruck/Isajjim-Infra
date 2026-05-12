output "instance_name" {
  description = "Compute Engine 인스턴스 이름"
  value       = google_compute_instance.backend.name
}

output "instance_id" {
  description = "Compute Engine 인스턴스 ID"
  value       = google_compute_instance.backend.id
}
