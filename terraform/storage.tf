#버킷 및 아티팩트 스토리지 

resource "google_storage_bucket" "images" {
  name                        = "${var.project_name}-images"
  location                    = var.region
  uniform_bucket_level_access = true

  cors {
    origin          = ["https://isajjim.kro.kr", "https://api.isajjim.kro.kr"]
    method          = ["GET", "PUT", "POST"]
    response_header = ["Content-Type"]
    max_age_seconds = 3600
  }
}

resource "google_storage_bucket" "assets" {
  name     = "${var.project_name}-3d-assets"
  location = var.region
  uniform_bucket_level_access = true
}

# 스타트업 스크립트 저장용 버킷
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
    region        = var.region
    db_private_ip = google_sql_database_instance.main.private_ip_address
    backend_ip    = google_compute_address.backend_ip.address
    images_bucket = google_storage_bucket.images.name
    frontend_url  = var.frontend_url
    api_domain    = var.api_domain
  })
}

resource "google_artifact_registry_repository" "main" {
  location      = var.region
  repository_id = "isajjim-repo"
  format        = "DOCKER"
  depends_on    = [google_project_service.artifactregistry]
}