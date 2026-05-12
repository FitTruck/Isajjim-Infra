variable "project_id" {
  description = "GCP 프로젝트 ID"
  type        = string
}

variable "region" {
  description = "GCP 리전"
  type        = string
}

variable "db_password" {
  description = "Cloud SQL 사용자 비밀번호"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "생성할 데이터베이스 이름"
  type        = string
  default     = "isajjim"
}

variable "db_user" {
  description = "데이터베이스 사용자 이름"
  type        = string
  default     = "isajjim-user"
}
