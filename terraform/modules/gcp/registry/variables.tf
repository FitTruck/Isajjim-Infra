variable "project_id" {
  description = "GCP 프로젝트 ID"
  type        = string
}

variable "region" {
  description = "Artifact Registry 리전"
  type        = string
}

variable "repo_id" {
  description = "Artifact Registry repository ID"
  type        = string
}

variable "description" {
  description = "Artifact Registry repository 설명"
  type        = string
  default     = ""
}

variable "reader_members" {
  description = "Artifact Registry reader 권한을 부여할 IAM member 목록"
  type        = list(string)
  default     = []
}
