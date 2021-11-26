variable "name_prefix" {}
variable "gcp_project" {}
variable "cluster_endpoint" {}
variable "cluster_ca_cert" {}

data "google_client_config" "default" {
  provider = google-beta
}

provider "kubernetes" {
  experiments {
    manifest_resource = true
  }

  host                   = var.cluster_endpoint
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = var.cluster_ca_cert
}

provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = var.cluster_ca_cert
  }
}

module "services" {
  source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/services?ref=094e04f"
  # source = "../../../modules/services"

  name_prefix              = var.name_prefix
  gcp_project              = var.gcp_project
  letsencrypt_issuer_email = var.letsencrypt_issuer_email
  cluster_endpoint         = var.cluster_endpoint
  cluster_ca_cert          = var.cluster_ca_cert
  honeycomb_api_key        = "dummy"
  small_footprint          = true
}