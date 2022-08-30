# Enables the Cloud Run API
resource "google_project_service" "run_api" {
  service = "run.googleapis.com"

  disable_on_destroy = true
}

# Create the Cloud Run service
resource "google_cloud_run_service" "run_service" {
  name     = "ftp-to-gcs"
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/${var.project}/ftp-to-gcs:latest"
        resources {
          requests = {
            memory = "512Mi"
            cpu    = "250m"
          }
        }
      }
      container_concurrency = 1
      timeout_seconds       = 600
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"  = "5"
        "client.knative.dev/user-image"     = "gcr.io/${var.project}/ftp-to-gcs:latest"
        "run.googleapis.com/client-name"    = "gcloud"
        "run.googleapis.com/client-version" = "399.0.0"
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
