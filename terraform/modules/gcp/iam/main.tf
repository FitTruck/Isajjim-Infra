resource "google_service_account" "ai" {
  account_id   = "${var.project_name}-ai-sa"
  display_name = "${var.project_name} AI Server Service Account"
}

resource "google_project_iam_member" "ai_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.ai.email}"
}
