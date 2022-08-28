terraform {
  required_version = ">=0.14"

  backend "gcs" {
    bucket = "tf-backend-270822"
    prefix = "terraform/state/run"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.3"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}
