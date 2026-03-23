
#백엔드 고정 IP 할당 
resource "google_compute_address" "backend_ip" {
  name       = "isajjim-backend-ip"
  region     = var.region
  depends_on = [google_project_service.compute]
}

#백엔드와 DB 내부 네트워크 연결을 위한 VPC Peering 설정
resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = "projects/${var.project_id}/global/networks/default"
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = "projects/${var.project_id}/global/networks/default"
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
  depends_on              = [google_project_service.servicenetworking]
}

#22번 포트 개방
resource "google_compute_firewall" "allow_ssh" {
  name          = "isajjim-allow-ssh"
  network       = "default"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["isajjim-backend"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

#80,443포트 개방
resource "google_compute_firewall" "allow_http_https" {
  name          = "isajjim-allow-http-https"
  network       = "default"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["isajjim-backend"]

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}