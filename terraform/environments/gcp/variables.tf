variable "project_name" {
  description = "프로젝트 이름 (리소스 명명 접두사)"
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
  description = "프론트엔드 URL (CORS 및 환경변수에 사용)"
  type        = string
  default     = "https://isajjim.kro.kr"
}

variable "api_domain" {
  description = "백엔드 API 도메인"
  type        = string
  default     = "api.isajjim.kro.kr"
}

variable "github_connection_name" {
  description = "Cloud Build GitHub 연결 이름"
  type        = string
  default     = "Backend"
}

variable "github_repo_name" {
  description = "Cloud Build에 연결된 GitHub 저장소 이름"
  type        = string
  default     = "FitTruck-Isajjim-Backend"
}

variable "trigger_branch" {
  description = "Cloud Build 트리거 브랜치 패턴 (정규식)"
  type        = string
  default     = "^dev$"
}
