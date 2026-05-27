variable "project_id" {
  description = "GCP 프로젝트 ID"
  type        = string
}

variable "project_name" {
  description = "리소스 명명 접두사"
  type        = string
}

variable "github_repository" {
  description = "GitHub repository (owner/repo)"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch allowed to impersonate the service account"
  type        = string
}

variable "ai_sa_email" {
  description = "AI 서버 서비스 계정 이메일"
  type        = string
}
