#백엔드 컴퓨트 엔진 생성

resource "google_compute_instance" "backend" {
  name         = "isajjim-backend"
  machine_type = "e2-medium"
  zone         = var.zone

  depends_on = [
    google_project_service.compute,
    google_compute_address.backend_ip,
    google_secret_manager_secret_version.db_password_version,
    google_secret_manager_secret_version.gemini_api_key_version
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
    startup-script = <<-EOF
      #!/bin/bash
      set -e

      apt-get update -y
      apt-get install -y docker.io
      systemctl enable docker
      systemctl start docker

      usermod -aG docker ubuntu
      usermod -aG docker suhari

      apt-get install -y nginx
      apt-get install -y certbot python3-certbot-nginx

      # Secret Manager를 통한 보안 데이터 동적 호출
      DB_PASSWORD=$(gcloud secrets versions access latest --secret="db-password" --project="${var.project_id}")
      GEMINI_API_KEY=$(gcloud secrets versions access latest --secret="gemini-api-key" --project="${var.project_id}")

      mkdir -p /home/ubuntu/configs
      cat > /home/ubuntu/configs/.env << ENVEOF
SPRING_PROFILES_ACTIVE=dev
DB_URL=jdbc:mysql://${google_sql_database_instance.main.private_ip_address}:3306/isajjim
DB_USERNAME=isajjim-user
DB_PASSWORD=$${DB_PASSWORD}
GEMINI_API_KEY=$${GEMINI_API_KEY}
GEMINI_MODEL=gemini-2.0-flash
GOOGLE_PROJECT_ID=${var.project_id}
GOOGLE_GCS_BUCKET=${google_storage_bucket.images.name}
FRONTEND_URL=http://${google_compute_address.backend_ip.address}
AI_BASE_URL=http://localhost:8000
AI_USE_SERVER=false
ESTIMATE_EXTRA_VOLUME_RATIO=1.1
DEV_SWAGGER_URL=http://${google_compute_address.backend_ip.address}
ENVEOF

      chown -R ubuntu:ubuntu /home/ubuntu/configs

      gcloud auth configure-docker ${var.region}-docker.pkg.dev --quiet
      docker pull ${var.region}-docker.pkg.dev/${var.project_id}/isajjim-repo/backend:latest

      docker run -d \
        --name isajjim-backend \
        --env-file /home/ubuntu/configs/.env \
        -p 8080:8080 \
        --restart unless-stopped \
        ${var.region}-docker.pkg.dev/${var.project_id}/isajjim-repo/backend:latest

      echo "Startup script completed" >> /var/log/startup-script.log
    EOF
  }
}