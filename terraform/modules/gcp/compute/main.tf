resource "google_compute_instance" "backend" {
  name         = "${var.project_name}-backend"
  machine_type = var.machine_type
  zone         = var.zone

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
      nat_ip = var.backend_ip_address
    }
  }

  tags = ["${var.project_name}-backend"]

  service_account {
    email  = var.backend_sa_email
    scopes = ["cloud-platform"]
  }

  metadata = {
    startup-script-url = "gs://${var.scripts_bucket_name}/${var.startup_script_object_name}"
  }
}
