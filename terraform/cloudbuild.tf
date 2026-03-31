resource "google_cloudbuild_trigger" "backend_push_trigger" {
  name     = "backend-trigger"
  location = var.region 

  service_account = "projects/${var.project_id}/serviceAccounts/675009148577-compute@developer.gserviceaccount.com"

  substitutions = {
    _REGION        = var.region
    _ZONE          = var.zone
    _REPO_NAME     = google_artifact_registry_repository.main.repository_id
    _IMAGE_NAME    = "backend"
    _INSTANCE_NAME = google_compute_instance.backend.name
    _ENV_FILE      = "/home/ubuntu/configs/.env"
    _PORT          = "8080"
  }

  repository_event_config {
    repository = "projects/${var.project_id}/locations/${var.region}/connections/Backend/repositories/FitTruck-Isajjim-Backend"
    
    push {
      branch = "^dev$"
    }
  }

  filename = "cloudbuild.yaml"
}