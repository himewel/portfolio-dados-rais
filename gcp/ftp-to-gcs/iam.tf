# Creates service account to invoke Cloud Run
resource "google_service_account" "sa" {
  project      = var.project
  account_id   = "cloud-run-task-invoker"
  display_name = "Cloud Run Task Invoker"
}

# Binds Cloud Run invoker to pubsub
resource "google_cloud_run_service_iam_binding" "binding" {
  project  = var.project
  location = var.region
  service  = google_cloud_run_service.run_service.name
  role     = "roles/run.invoker"
  members  = ["serviceAccount:${google_service_account.sa.email}"]
}

resource "google_project_iam_binding" "project" {
  role    = "roles/iam.serviceAccountTokenCreator"
  project = var.project
  members = ["serviceAccount:${google_service_account.sa.email}"]
}
