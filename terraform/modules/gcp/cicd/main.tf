resource "google_project_service" "cloudbuild" {
  service            = "cloudbuild.googleapis.com"
  disable_on_destroy = false
}

resource "google_cloudbuild_trigger" "backend_push_trigger" {
  name     = "backend-trigger"
  location = var.region

  service_account = var.cloudbuild_sa_id
  depends_on      = [google_project_service.cloudbuild]

  substitutions = {
    _REGION                               = var.region
    _ZONE                                 = var.zone
    _REPO_NAME                            = var.artifact_registry_repo_id
    _IMAGE_NAME                           = "backend"
    _INSTANCE_NAME                        = var.backend_instance_name
    _PORT                                 = "8080"
    _BACKEND_IP                           = var.backend_ip_address
    _IMAGES_BUCKET                        = var.images_bucket_name
    _FRONTEND_URL                         = var.frontend_url
    _API_DOMAIN                           = var.api_domain
    _JWT_ACCESS_TOKEN_EXPIRATION_TIME     = "604800000"
    _JWT_REFRESH_TOKEN_EXPIRATION_TIME    = "604800000"
    _JWT_REFRESH_TOKEN_REISSUE_LIMIT_DAYS = "14"
  }

  repository_event_config {
    repository = "projects/${var.project_id}/locations/${var.region}/connections/${var.github_connection_name}/repositories/${var.github_repo_name}"

    push {
      branch = var.trigger_branch
    }
  }

  filename = "cloudbuild.yaml"
}
