resource "google_cloudbuild_trigger" "backend_push_trigger" {

  name     = "backend-trigger"
  location = "asia-northeast3"

  service_account = "projects/knu-2026-agion427/serviceAccounts/675009148577-compute@developer.gserviceaccount.com"

  repository_event_config {
    repository = "projects/knu-2026-agion427/locations/asia-northeast3/connections/Backend/repositories/FitTruck-Isajjim-Backend"
    
    push {
      branch = "^dev$"
    }
  }

  filename = "cloudbuild.yaml"
}