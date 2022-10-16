# Binds Cloud Run invoker to pubsub
resource "google_cloud_run_service_iam_binding" "binding" {
  project  = var.project
  location = var.region
  service  = google_cloud_run_service.run_service.name
  role     = "roles/run.invoker"
  members  = ["serviceAccount:cloud-run-task-invoker@caged-rais-230822.iam.gserviceaccount.com"]
}
