#버킷 및 아티팩트 스토리지 

resource "google_storage_bucket" "images" {
  name                        = "${var.project_name}-images"
  location                    = var.region
  uniform_bucket_level_access = true

  versioning {
    enabled = false
  }

  lifecycle_rule {
    condition {
      age = 7
    }
    action {
      type = "Delete"
    }
  }

  cors {
    origin          = ["https://isajjim.kro.kr", "https://api.isajjim.kro.kr"]
    method          = ["GET", "PUT", "POST"]
    response_header = ["Content-Type"]
    max_age_seconds = 3600
  }
}

resource "google_storage_bucket" "assets" {
  name                        = "${var.project_name}-3d-assets"
  location                    = var.region
  uniform_bucket_level_access = true

  versioning {
    enabled = false
  }

  lifecycle_rule {
    condition {
      age = 7
    }
    action {
      type = "Delete"
    }
  }
}

resource "google_artifact_registry_repository" "main" {
  location      = var.region
  repository_id = "isajjim-repo"
  format        = "DOCKER"
  depends_on    = [google_project_service.artifactregistry]
}