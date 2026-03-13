output "images_bucket_name" {
  description = "이미지 업로드 버킷 이름"
  value       = google_storage_bucket.images.name
}

output "assets_bucket_name" {
  description = "3D 결과물 버킷 이름"
  value       = google_storage_bucket.assets.name
}

output "db_public_ip" {
  description = "Cloud SQL 공개 IP"
  value       = google_sql_database_instance.main.public_ip_address
}

output "db_connection_name" {
  description = "Cloud SQL 연결 이름 (Cloud Run에서 사용)"
  value       = google_sql_database_instance.main.connection_name
}

output "artifact_registry_url" {
  description = "Docker 이미지 저장소 URL"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/isajjim-repo"
}

output "backend_url" {
  description = "Cloud Run 백엔드 URL"
  value       = google_cloud_run_v2_service.backend.uri
}