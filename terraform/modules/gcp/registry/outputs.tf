output "repository_id" {
  description = "Artifact Registry repository ID"
  value       = google_artifact_registry_repository.ai.repository_id
}

output "repository_url" {
  description = "Docker image repository URL"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.ai.repository_id}"
}
