# Message schema for the topic
resource "google_pubsub_schema" "schema" {
  name       = "ftp-to-gcs-schema"
  type       = "AVRO"
  definition = <<EOT
{
  "type": "record",
  "name": "Avro",
  "fields": [
    {
      "name": "source",
      "type": "string"
    },
    {
      "name": "destination",
      "type": "string"
    }
  ]
}
EOT
}

# Creates PubSub topic
resource "google_pubsub_topic" "topic" {
  name = "ftp-to-gcs-topic"
  schema_settings {
    schema   = google_pubsub_schema.schema.id
    encoding = "JSON"
  }
}

# Creates Push subscription calling Cloud Run
resource "google_pubsub_subscription" "subscription" {
  name  = "ftp-to-gcs-subscription"
  topic = google_pubsub_topic.topic.name

  push_config {
    push_endpoint = google_cloud_run_service.run_service.status[0].url
    oidc_token {
      service_account_email = google_service_account.sa.email
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
