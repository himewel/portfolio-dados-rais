terraform {
  required_version = ">=0.14"

  backend "gcs" {
    bucket = "tf-backend-270822"
    prefix = "terraform/state/pubsub"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.3"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.3"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}
