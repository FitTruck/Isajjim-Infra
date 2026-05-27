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

variable "ai_machine_type" {
  description = "AI 서버 Compute Engine 머신 타입"
  type        = string
  default     = "g2-standard-4"
}

variable "ai_disk_size_gb" {
  description = "AI 서버 부트 디스크 크기(GB)"
  type        = number
  default     = 100
}

variable "ai_subnet_cidr" {
  description = "AI 서버 전용 subnet CIDR"
  type        = string
  default     = "10.10.0.0/24"
}

variable "ai_service_port" {
  description = "AI 서버 API 포트"
  type        = string
  default     = "8000"
}

variable "ai_allowed_source_ranges" {
  description = "AI 서버 API 포트 접근 허용 CIDR 목록"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "artifact_registry_repo_id" {
  description = "AI 서버 Docker 이미지용 Artifact Registry repository ID"
  type        = string
  default     = "isajjim-ai"
}

variable "github_repository" {
  description = "GitHub Actions OIDC를 허용할 repository (owner/repo)"
  type        = string
  default     = "FitTruck/boxer-Isajjim"
}

variable "github_branch" {
  description = "GitHub Actions OIDC를 허용할 branch 이름"
  type        = string
  default     = "infra-dev"
}
