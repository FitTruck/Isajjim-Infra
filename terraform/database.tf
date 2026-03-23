#DB 세팅

resource "google_sql_database_instance" "main" {
  name                = "${var.project_id}-db"
  database_version    = "MYSQL_8_0"
  region              = var.region
  deletion_protection = false

  depends_on = [
    google_project_service.sqladmin,
    google_service_networking_connection.private_vpc_connection
  ]

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

resource "google_sql_database" "isajjim" {
  name     = "isajjim"
  instance = google_sql_database_instance.main.name
}

resource "google_sql_user" "app_user" {
  name     = "isajjim-user"
  instance = google_sql_database_instance.main.name
  password = var.db_password
}