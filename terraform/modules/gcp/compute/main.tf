data "google_compute_image" "ubuntu_2404_lts" {
  family  = "ubuntu-2404-lts-amd64"
  project = "ubuntu-os-cloud"
}

resource "google_compute_instance" "ai" {
  name         = "${var.project_name}-ai"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu_2404_lts.self_link
      size  = var.disk_size_gb
      type  = "pd-balanced"
    }
  }

  network_interface {
    subnetwork = var.ai_subnet
    access_config {
      nat_ip = var.ai_ip_address
    }
  }

  tags = ["${var.project_name}-ai"]

  service_account {
    email  = var.ai_sa_email
    scopes = ["cloud-platform"]
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "TERMINATE"
  }

  metadata = {
    startup-script = <<-EOT
      #!/bin/bash
      set -euo pipefail
      exec >> /var/log/ai-startup-script.log 2>&1

      echo "[$(date)] AI server startup script started"

      apt-get update -y
      apt-get install -y docker.io

      systemctl enable docker
      systemctl start docker
      usermod -aG docker ubuntu || true

      echo "[$(date)] AI server startup script completed"
    EOT
  }
}
