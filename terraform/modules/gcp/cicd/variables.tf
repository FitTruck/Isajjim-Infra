variable "project_id" {
  description = "GCP 프로젝트 ID"
  type        = string
}

variable "region" {
  description = "GCP 리전"
  type        = string
}

variable "zone" {
  description = "GCP 존"
  type        = string
}

variable "artifact_registry_repo_id" {
  description = "Artifact Registry 저장소 ID (storage 모듈 output)"
  type        = string
}

variable "backend_instance_name" {
  description = "백엔드 Compute Engine 인스턴스 이름 (compute 모듈 output)"
  type        = string
}

variable "backend_ip_address" {
  description = "백엔드 고정 외부 IP (networking 모듈 output)"
  type        = string
}

variable "db_private_ip" {
  description = "Cloud SQL 프라이빗 IP (database 모듈 output)"
  type        = string
}

variable "images_bucket_name" {
  description = "이미지 버킷 이름 (storage 모듈 output)"
  type        = string
}

variable "frontend_url" {
  description = "프론트엔드 URL"
  type        = string
}

variable "api_domain" {
  description = "백엔드 API 도메인"
  type        = string
}

variable "cloudbuild_sa_id" {
  description = "Cloud Build 서비스 계정 ID (iam 모듈 output)"
  type        = string
}

variable "github_connection_name" {
  description = "Cloud Build GitHub 연결 이름"
  type        = string
}

variable "github_repo_name" {
  description = "연결된 GitHub 저장소 이름"
  type        = string
}

variable "trigger_branch" {
  description = "Cloud Build 트리거 브랜치 패턴"
  type        = string
  default     = "^dev$"
}
