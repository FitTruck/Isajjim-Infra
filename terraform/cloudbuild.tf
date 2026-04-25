resource "google_cloudbuild_trigger" "backend_push_trigger" {
  name     = "backend-trigger"
  location = var.region

  service_account = google_service_account.cloudbuild.id

  substitutions = {
    _REGION                               = var.region
    _ZONE                                 = var.zone
    _REPO_NAME                            = google_artifact_registry_repository.main.repository_id
    _IMAGE_NAME                           = "backend"
    _INSTANCE_NAME                        = google_compute_instance.backend.name
    _PORT                                 = "8080"
    _DB_PRIVATE_IP                        = google_sql_database_instance.main.private_ip_address
    _BACKEND_IP                           = google_compute_address.backend_ip.address
    _IMAGES_BUCKET                        = google_storage_bucket.images.name
    _FRONTEND_URL                         = var.frontend_url
    _API_DOMAIN                           = var.api_domain
    _JWT_ACCESS_TOKEN_EXPIRATION_TIME     = "604800000"
    _JWT_REFRESH_TOKEN_EXPIRATION_TIME    = "604800000"
    _JWT_REFRESH_TOKEN_REISSUE_LIMIT_DAYS = "14"
  }

  repository_event_config {
    repository = "projects/${var.project_id}/locations/${var.region}/connections/Backend/repositories/FitTruck-Isajjim-Backend"

    push {
      branch = "^dev$"
    }
  }

  filename = "cloudbuild.yaml"
}
