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
