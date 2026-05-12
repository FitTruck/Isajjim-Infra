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
