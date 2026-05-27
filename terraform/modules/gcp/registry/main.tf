resource "google_project_service" "artifactregistry" {
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "ai" {
  location      = var.region
  repository_id = var.repo_id
  description   = var.description
  format        = "DOCKER"

  depends_on = [google_project_service.artifactregistry]
}

resource "google_artifact_registry_repository_iam_member" "reader" {
  for_each = toset(var.reader_members)

  project    = var.project_id
  location   = google_artifact_registry_repository.ai.location
  repository = google_artifact_registry_repository.ai.name
  role       = "roles/artifactregistry.reader"
  member     = each.value
}
