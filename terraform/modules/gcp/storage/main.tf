resource "google_project_service" "artifactregistry" {
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_storage_bucket" "images" {
  name                        = "${var.project_name}-images"
  location                    = var.region
  uniform_bucket_level_access = true

  cors {
    origin          = [var.frontend_url, "https://${var.api_domain}"]
    method          = ["GET", "PUT", "POST"]
    response_header = ["Content-Type"]
    max_age_seconds = 3600
  }
}

resource "google_storage_bucket" "assets" {
  name                        = "${var.project_name}-3d-assets"
  location                    = var.region
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "scripts" {
  name                        = "${var.project_name}-scripts"
  location                    = var.region
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "startup_script" {
  name   = "startup.sh"
  bucket = google_storage_bucket.scripts.name
  content = templatefile("${path.module}/scripts/startup.sh.tpl", {
    project_id    = var.project_id
    project_name  = var.project_name
    region        = var.region
    backend_ip    = var.backend_ip
    images_bucket = google_storage_bucket.images.name
    frontend_url  = var.frontend_url
    api_domain    = var.api_domain
  })
}

resource "google_artifact_registry_repository" "main" {
  location      = var.region
  repository_id = "${var.project_name}-repo"
  format        = "DOCKER"
  depends_on    = [google_project_service.artifactregistry]
}
