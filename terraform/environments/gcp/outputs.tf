output "backend_external_ip" {
  description = "백엔드 VM 고정 외부 IP (DNS A 레코드에 등록할 값)"
  value       = module.networking.backend_ip_address
}

output "db_private_ip" {
  description = "Cloud SQL 프라이빗 IP (VM 내부망 접근용)"
  value       = module.database.private_ip_address
}

output "db_connection_name" {
  description = "Cloud SQL 연결 이름"
  value       = module.database.connection_name
}

output "images_bucket_name" {
  description = "이미지 업로드 버킷 이름"
  value       = module.storage.images_bucket_name
}

output "assets_bucket_name" {
  description = "3D 결과물 버킷 이름"
  value       = module.storage.assets_bucket_name
}

output "artifact_registry_url" {
  description = "Docker 이미지 저장소 URL"
  value       = module.storage.artifact_registry_url
}

output "backend_sa_email" {
  description = "백엔드 서비스 계정 이메일"
  value       = module.iam.backend_sa_email
}

output "cloudbuild_sa_email" {
  description = "Cloud Build 서비스 계정 이메일"
  value       = module.iam.cloudbuild_sa_email
}
