resource "google_storage_bucket" "landing_bucket" {
  name     = "landing-270822"
  location = var.region
}

resource "google_storage_notification" "notification" {
  bucket         = google_storage_bucket.landing_bucket.name
  payload_format = "JSON_API_V1"
  topic          = google_pubsub_topic.topic.id
  event_types    = ["OBJECT_FINALIZE"]
  depends_on     = [google_pubsub_topic_iam_binding.binding]
}

// Enable notifications by giving the correct IAM permission to the unique service account.
data "google_storage_project_service_account" "gcs_account" {
}

resource "google_pubsub_topic_iam_binding" "binding" {
  topic   = google_pubsub_topic.topic.id
  role    = "roles/pubsub.publisher"
  members = ["serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"]
}

resource "google_storage_bucket" "raw_bucket" {
  name     = "raw-270822"
  location = var.region
}
