resource "google_project_service" "secretmanager" {
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
}

locals {
  secret_ids = {
    auth_token = "${var.project_name}-ai-auth-token"
    hf_token   = "${var.project_name}-ai-hf-token"
  }
}

resource "google_secret_manager_secret" "ai" {
  for_each  = local.secret_ids
  secret_id = each.value

  replication {
    auto {}
  }

  depends_on = [google_project_service.secretmanager]
}

resource "google_secret_manager_secret_iam_member" "ai_accessor" {
  for_each = google_secret_manager_secret.ai

  secret_id = each.value.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.ai_sa_email}"
}
