resource "google_pubsub_topic" "topic" {
  name = "landing-topic"
}

# Creates pull subscription to store messages
resource "google_pubsub_subscription" "default_subscription" {
  name  = "unzip-default-subscription"
  topic = google_pubsub_topic.topic.name
}

# Creates Push subscription calling Cloud Run
resource "google_pubsub_subscription" "subscription" {
  name  = "unzip-subscription"
  topic = google_pubsub_topic.topic.name

  ack_deadline_seconds = 600

  push_config {
    push_endpoint = google_cloud_run_service.run_service.status[0].url
    oidc_token {
      service_account_email = "cloud-run-task-invoker@caged-rais-230822.iam.gserviceaccount.com"
    }
    attributes = {
      x-goog-version = "v1"
    }
  }

  retry_policy {
    minimum_backoff = "30s"
    maximum_backoff = "300s"
  }

  dead_letter_policy {
    dead_letter_topic     = "projects/${var.project}/topics/dead-letter-topic"
    max_delivery_attempts = 5
  }
}
