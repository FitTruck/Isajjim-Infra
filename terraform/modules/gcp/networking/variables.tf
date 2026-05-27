variable "project_id" {
  description = "GCP 프로젝트 ID"
  type        = string
}

variable "region" {
  description = "GCP 리전"
  type        = string
}

variable "project_name" {
  description = "리소스 명명 접두사"
  type        = string
}

variable "ai_subnet_cidr" {
  description = "AI 서버 전용 subnet CIDR"
  type        = string
  default     = "10.10.0.0/24"
}

variable "ai_service_port" {
  description = "AI 서버 API 포트"
  type        = string
}

variable "ai_allowed_source_ranges" {
  description = "AI 서버 API 포트 접근 허용 CIDR 목록"
  type        = list(string)
}
