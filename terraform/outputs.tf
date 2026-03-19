output "backend_external_ip" {
  description = "백엔드 VM 고정 외부 IP (DNS A 레코드에 등록할 값)"
  value       = google_compute_address.backend_ip.address
}

output "db_public_ip" {
  description = "Cloud SQL 공개 IP"
  value       = google_sql_database_instance.main.public_ip_address
}

output "db_connection_name" {
  description = "Cloud SQL 연결 이름"
  value       = google_sql_database_instance.main.connection_name
}

output "images_bucket_name" {
  description = "이미지 업로드 버킷 이름"
  value       = google_storage_bucket.images.name
}

output "assets_bucket_name" {
  description = "3D 결과물 버킷 이름"
  value       = google_storage_bucket.assets.name
}

output "artifact_registry_url" {
  description = "Docker 이미지 저장소 URL"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/isajjim-repo"
}

output "backend_sa_email" {
  description = "백엔드 서비스 계정 이메일"
  value       = google_service_account.backend.email
}
