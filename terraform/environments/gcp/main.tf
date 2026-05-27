module "networking" {
  source                   = "../../modules/gcp/networking"
  project_id               = var.project_id
  project_name             = var.project_name
  region                   = var.region
  ai_subnet_cidr           = var.ai_subnet_cidr
  ai_service_port          = var.ai_service_port
  ai_allowed_source_ranges = var.ai_allowed_source_ranges
}

module "iam" {
  source       = "../../modules/gcp/iam"
  project_id   = var.project_id
  project_name = var.project_name
}

module "secrets" {
  source       = "../../modules/gcp/secrets"
  project_name = var.project_name
  ai_sa_email  = module.iam.ai_sa_email
}

module "registry" {
  source      = "../../modules/gcp/registry"
  project_id  = var.project_id
  region      = var.region
  repo_id     = var.artifact_registry_repo_id
  description = "Docker images for ${var.project_name} AI server"
  reader_members = [
    "serviceAccount:${module.iam.ai_sa_email}",
  ]
}

module "github_actions" {
  source            = "../../modules/gcp/github_actions"
  project_id        = var.project_id
  project_name      = var.project_name
  github_repository = var.github_repository
  github_branch     = var.github_branch
}

module "compute" {
  source        = "../../modules/gcp/compute"
  zone          = var.zone
  project_name  = var.project_name
  machine_type  = var.ai_machine_type
  disk_size_gb  = var.ai_disk_size_gb
  ai_ip_address = module.networking.ai_ip_address
  ai_subnet     = module.networking.ai_subnet_self_link
  ai_sa_email   = module.iam.ai_sa_email
}
