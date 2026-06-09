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
    enable-oslogin = "FALSE"

    startup-script = <<-EOT
      #!/bin/bash
      set -euo pipefail
      exec >> /var/log/ai-startup-script.log 2>&1

      echo "[$(date)] AI server startup script started"

      apt-get update -y
      apt-get install -y \
        ca-certificates \
        curl \
        docker.io \
        gnupg \
        linux-headers-$(uname -r) \
        python3

      systemctl enable docker
      systemctl start docker
      usermod -aG docker ubuntu || true

      if ! nvidia-smi >/dev/null 2>&1; then
        echo "[$(date)] Installing NVIDIA GPU driver from Ubuntu packages..."
        apt-get install -y \
          linux-modules-nvidia-595-gcp \
          nvidia-driver-595 \
          nvidia-utils-595
        modprobe nvidia
      else
        echo "[$(date)] NVIDIA GPU driver already installed"
      fi

      if ! command -v nvidia-ctk >/dev/null 2>&1; then
        echo "[$(date)] Installing NVIDIA Container Toolkit..."
        curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey \
          | gpg --dearmor --yes -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

        curl -fsSL https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list \
          | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' \
          > /etc/apt/sources.list.d/nvidia-container-toolkit.list

        apt-get update -y
        apt-get install -y nvidia-container-toolkit
      else
        echo "[$(date)] NVIDIA Container Toolkit already installed"
      fi

      nvidia-ctk runtime configure --runtime=docker
      systemctl restart docker

      echo "[$(date)] AI server startup script completed"
    EOT
  }

  lifecycle {
    ignore_changes = [metadata["ssh-keys"]]
  }
}
