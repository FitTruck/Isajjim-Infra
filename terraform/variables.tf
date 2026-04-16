variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "project_id" {
  description = "GCP 프로젝트 ID"
  type        = string
}

variable "region" {
  description = "GCP 리전"
  type        = string
  default     = "asia-northeast3"
}

variable "zone" {
  description = "GCP 존"
  type        = string
  default     = "asia-northeast3-a"
}

variable "db_password" {
  description = "Cloud SQL 사용자 비밀번호"
  type        = string
  sensitive   = true
}

variable "gemini_api_key" {
  description = "Gemini API 키"
  type        = string
  sensitive   = true
}

variable "frontend_url" {
  description = "프론트엔드 URL (CORS 및 백엔드 환경변수에 사용)"
  type        = string
  default     = "https://isajjim.kro.kr"
}

variable "api_domain" {
  description = "백엔드 API 도메인 (Swagger, OAuth redirect 등에 사용)"
  type        = string
  default     = "api.isajjim.kro.kr"
}

