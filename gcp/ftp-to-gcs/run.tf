# Enables the Cloud Run API
resource "google_project_service" "run_api" {
  service = "run.googleapis.com"
}

# Create the Cloud Run service
resource "google_cloud_run_service" "run_service" {
  name                       = "ftp-to-gcs"
  location                   = var.region
  autogenerate_revision_name = true

  template {
    spec {
      containers {
        image = "gcr.io/${var.project}/ftp-to-gcs:latest"
        resources {}
      }
      container_concurrency = 1
      timeout_seconds       = 150
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"  = "3"
        "client.knative.dev/user-image"     = "gcr.io/${var.project}/ftp-to-gcs:latest"
        "run.googleapis.com/client-name"    = "gcloud"
        "run.googleapis.com/client-version" = "400.0.0"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  # Waits for the Cloud Run API to be enabled
  depends_on = [google_project_service.run_api]
}
