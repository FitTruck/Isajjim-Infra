variable "zone" {
  description = "GCP 존"
  type        = string
}

variable "project_name" {
  description = "리소스 명명 접두사"
  type        = string
}

variable "machine_type" {
  description = "AI 서버 Compute Engine 머신 타입"
  type        = string
  default     = "g2-standard-4"
}

variable "disk_size_gb" {
  description = "AI 서버 부트 디스크 크기(GB)"
  type        = number
  default     = 100
}

variable "ai_ip_address" {
  description = "AI 서버 고정 외부 IP (networking 모듈 output)"
  type        = string
}

variable "ai_subnet" {
  description = "AI 서버 subnet self link (networking 모듈 output)"
  type        = string
}

variable "ai_sa_email" {
  description = "AI 서버 서비스 계정 이메일 (iam 모듈 output)"
  type        = string
}
