variable "project_id" {
  description = "GCP 프로젝트 ID"
  type        = string
}

variable "project_name" {
  description = "리소스 명명 접두사 (버킷 이름 등)"
  type        = string
}

variable "region" {
  description = "GCP 리전"
  type        = string
}

variable "db_private_ip" {
  description = "Cloud SQL 프라이빗 IP (startup script 주입용)"
  type        = string
}

variable "backend_ip" {
  description = "백엔드 VM 외부 고정 IP (startup script 주입용)"
  type        = string
}

variable "frontend_url" {
  description = "프론트엔드 URL (CORS 및 startup script 주입용)"
  type        = string
}

variable "api_domain" {
  description = "백엔드 API 도메인 (startup script 주입용)"
  type        = string
}
