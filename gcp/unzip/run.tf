# Enables the Cloud Run API
resource "google_project_service" "run_api" {
  service = "run.googleapis.com"
}

resource "google_cloud_run_service" "run_service" {
  name                       = "unzip"
  location                   = var.region
  autogenerate_revision_name = true

  template {
    spec {
      containers {
        image = "gcr.io/${var.project}/unzip:latest"
        resources {
          requests = {
            memory = "1024Mi"
            cpu    = "1000m"
          }
          limits = {
            memory = "4196Mi"
            cpu    = "2000m"
          }
        }
      }
      container_concurrency = 1
      timeout_seconds       = 150
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"  = "5"
        "client.knative.dev/user-image"     = "gcr.io/${var.project}/unzip:latest"
        "run.googleapis.com/client-name"    = "gcloud"
        "run.googleapis.com/client-version" = "405.0.1"
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
