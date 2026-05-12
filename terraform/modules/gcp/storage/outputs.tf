output "images_bucket_name" {
  description = "이미지 업로드 버킷 이름"
  value       = google_storage_bucket.images.name
}

output "assets_bucket_name" {
  description = "3D 결과물 버킷 이름"
  value       = google_storage_bucket.assets.name
}

output "scripts_bucket_name" {
  description = "startup script 버킷 이름"
  value       = google_storage_bucket.scripts.name
}

output "startup_script_object_name" {
  description = "GCS 버킷 내 startup script 오브젝트 이름"
  value       = google_storage_bucket_object.startup_script.name
}

output "artifact_registry_repo_id" {
  description = "Artifact Registry 저장소 ID"
  value       = google_artifact_registry_repository.main.repository_id
}

output "artifact_registry_url" {
  description = "Docker 이미지 전체 저장소 URL"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.main.repository_id}"
}
