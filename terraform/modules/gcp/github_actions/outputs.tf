output "service_account_email" {
  description = "GitHub Actions 서비스 계정 이메일"
  value       = google_service_account.github_actions.email
}

output "workload_identity_provider" {
  description = "google-github-actions/auth workload_identity_provider 값"
  value       = "projects/${data.google_project.current.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github.workload_identity_pool_id}/providers/${google_iam_workload_identity_pool_provider.github.workload_identity_pool_provider_id}"
}
