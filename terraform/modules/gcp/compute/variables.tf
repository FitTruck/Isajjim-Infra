variable "zone" {
  description = "GCP 존"
  type        = string
}

variable "project_name" {
  description = "리소스 명명 접두사"
  type        = string
}

variable "machine_type" {
  description = "Compute Engine 머신 타입"
  type        = string
  default     = "e2-medium"
}

variable "backend_ip_address" {
  description = "백엔드 고정 외부 IP (networking 모듈 output)"
  type        = string
}

variable "backend_sa_email" {
  description = "백엔드 서비스 계정 이메일 (iam 모듈 output)"
  type        = string
}

variable "scripts_bucket_name" {
  description = "startup script가 저장된 GCS 버킷 이름 (storage 모듈 output)"
  type        = string
}

variable "startup_script_object_name" {
  description = "GCS 버킷 내 startup script 오브젝트 이름 (storage 모듈 output)"
  type        = string
}
