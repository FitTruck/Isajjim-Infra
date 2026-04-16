#백엔드 컴퓨트 엔진 생성

resource "google_compute_instance" "backend" {
  name         = "isajjim-backend"
  machine_type = "e2-medium"
  zone         = var.zone

  depends_on = [
    google_project_service.compute,
    google_secret_manager_secret_version.db_password_version,
    google_secret_manager_secret_version.gemini_api_key_version,
    google_storage_bucket_object.startup_script
  ]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 20
      type  = "pd-balanced"
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.backend_ip.address
    }
  }

  tags = ["isajjim-backend"]

  service_account {
    email  = google_service_account.backend.email
    scopes = ["cloud-platform"]
  }

  metadata = {
    startup-script-url = "gs://${google_storage_bucket.scripts.name}/${google_storage_bucket_object.startup_script.name}"
  }
}