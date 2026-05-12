output "trigger_id" {
  description = "Cloud Build 트리거 ID"
  value       = google_cloudbuild_trigger.backend_push_trigger.trigger_id
}

output "trigger_name" {
  description = "Cloud Build 트리거 이름"
  value       = google_cloudbuild_trigger.backend_push_trigger.name
}
