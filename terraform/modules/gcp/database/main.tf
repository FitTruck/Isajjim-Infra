resource "google_project_service" "sqladmin" {
  service            = "sqladmin.googleapis.com"
  disable_on_destroy = false
}

resource "google_sql_database_instance" "main" {
  name                = "${var.project_id}-db"
  database_version    = "MYSQL_8_0"
  region              = var.region
  deletion_protection = false

  depends_on = [google_project_service.sqladmin]

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled    = false
      private_network = "projects/${var.project_id}/global/networks/default"
    }

    backup_configuration { enabled = false }

    maintenance_window {
      hour = 19
      day  = 7
    }
  }
}

resource "google_sql_database" "app" {
  name     = var.db_name
  instance = google_sql_database_instance.main.name
}

resource "google_sql_user" "app_user" {
  name     = var.db_user
  instance = google_sql_database_instance.main.name
  password = var.db_password
}
