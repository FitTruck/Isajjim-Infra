resource "google_project_service" "compute" {
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "iap" {
  service            = "iap.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_network" "ai" {
  name                    = "${var.project_name}-ai-vpc"
  auto_create_subnetworks = false
  depends_on              = [google_project_service.compute]
}

resource "google_compute_subnetwork" "ai" {
  name          = "${var.project_name}-ai-subnet"
  ip_cidr_range = var.ai_subnet_cidr
  region        = var.region
  network       = google_compute_network.ai.id
}

resource "google_compute_address" "ai_ip" {
  name       = "${var.project_name}-ai-ip"
  region     = var.region
  depends_on = [google_project_service.compute]
}

resource "google_compute_firewall" "allow_ssh" {
  name          = "${var.project_name}-allow-ssh"
  network       = google_compute_network.ai.name
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["${var.project_name}-ai"]
  depends_on    = [google_project_service.compute]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "allow_ai_service" {
  name          = "${var.project_name}-allow-ai-service"
  network       = google_compute_network.ai.name
  source_ranges = var.ai_allowed_source_ranges
  target_tags   = ["${var.project_name}-ai"]
  depends_on    = [google_project_service.compute]

  allow {
    protocol = "tcp"
    ports    = [var.ai_service_port]
  }
}
