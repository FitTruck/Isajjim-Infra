output "private_ip_address" {
  description = "Cloud SQL 프라이빗 IP"
  value       = google_sql_database_instance.main.private_ip_address
}

output "connection_name" {
  description = "Cloud SQL 연결 이름"
  value       = google_sql_database_instance.main.connection_name
}

output "instance_name" {
  description = "Cloud SQL 인스턴스 이름"
  value       = google_sql_database_instance.main.name
}
