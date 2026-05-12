resource "google_project_service" "compute" {
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "iap" {
  service            = "iap.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_address" "backend_ip" {
  name       = "${var.project_name}-backend-ip"
  region     = var.region
  depends_on = [google_project_service.compute]
}

resource "google_compute_firewall" "allow_ssh" {
  name          = "${var.project_name}-allow-ssh"
  network       = "default"
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["${var.project_name}-backend"]
  depends_on    = [google_project_service.compute]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "allow_http_https" {
  name          = "${var.project_name}-allow-http-https"
  network       = "default"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.project_name}-backend"]
  depends_on    = [google_project_service.compute]

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}

resource "google_compute_firewall" "allow_monitoring" {
  name          = "${var.project_name}-allow-monitoring"
  network       = "default"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.project_name}-backend"]
  depends_on    = [google_project_service.compute]

  allow {
    protocol = "tcp"
    ports    = ["9090", "3000"]
  }
}
