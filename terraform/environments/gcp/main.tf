module "networking" {
  source       = "../../modules/gcp/networking"
  project_id   = var.project_id
  project_name = var.project_name
  region       = var.region
}

module "iam" {
  source       = "../../modules/gcp/iam"
  project_id   = var.project_id
  project_name = var.project_name
}

module "secrets" {
  source         = "../../modules/gcp/secrets"
  db_password    = var.db_password
  gemini_api_key = var.gemini_api_key
}

module "storage" {
  source        = "../../modules/gcp/storage"
  project_id    = var.project_id
  project_name  = var.project_name
  region        = var.region
  backend_ip    = module.networking.backend_ip_address
  frontend_url  = var.frontend_url
  api_domain    = var.api_domain
}

module "compute" {
  source                     = "../../modules/gcp/compute"
  zone                       = var.zone
  project_name               = var.project_name
  backend_ip_address         = module.networking.backend_ip_address
  backend_sa_email           = module.iam.backend_sa_email
  scripts_bucket_name        = module.storage.scripts_bucket_name
  startup_script_object_name = module.storage.startup_script_object_name

  # startup script가 업로드되고 시크릿이 준비된 후 VM이 생성되어야 함
  depends_on = [module.secrets]
}

module "cicd" {
  source                    = "../../modules/gcp/cicd"
  project_id                = var.project_id
  region                    = var.region
  zone                      = var.zone
  artifact_registry_repo_id = module.storage.artifact_registry_repo_id
  backend_instance_name     = module.compute.instance_name
  backend_ip_address        = module.networking.backend_ip_address
  images_bucket_name        = module.storage.images_bucket_name
  frontend_url              = var.frontend_url
  api_domain                = var.api_domain
  cloudbuild_sa_id          = module.iam.cloudbuild_sa_id
  github_connection_name    = var.github_connection_name
  github_repo_name          = var.github_repo_name
  trigger_branch            = var.trigger_branch
}
