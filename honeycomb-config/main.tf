terraform {
  required_providers {
    honeycombio = {
      source  = "honeycombio/honeycombio"
      version = "~> 0.23.0"
    }
  }
}

provider "honeycombio" {
  api_url = var.honeycomb_api_url
  api_key = var.honeycomb_api_key
  debug   = true
}

# Data Sources
# Not everything has to be managed via Terraform. You can use
# data sources to access info about things defined outside of
# Terraform
data "honeycombio_auth_metadata" "current" {}

# Datasets
# Creates a dataset
resource "honeycombio_dataset" "test-dataset" {
  name        = "test-dataset"
  description = "I am a test dataset"
}

# Recipients
resource "honeycombio_email_recipient" "test-email" {
  address = "<YOUR-EMAIL-HERE>"
}

resource "honeycombio_webhook_recipient" "test-webhook" {
  name   = "Test Webhook"
  url    = "<YOUR-WEBHOOK-URL-HERE>"
  secret = "fake-secret"
}

data "honeycombio_recipient" "test-pagerduty" {
  type = "pagerduty"

  detail_filter {
    name  = "integration_name"
    value = "NoOp Test Service"
  }
}

# Triggers
# Creates column to use in the trigger query spec
resource "honeycombio_column" "test-column" {
  name        = "test-column"
  type        = "integer"
  description = "I am a column"
  dataset     = honeycombio_dataset.test-dataset.name
}

# Creates the query spec to use for the trigger
data "honeycombio_query_specification" "avg-trigger-query-spec" {
  calculation {
    op     = "AVG"
    column = honeycombio_column.test-column.name
  }

  time_range = 1800
}

# Creates the query to use for the trigger
resource "honeycombio_query" "avg-trigger-query" {
  dataset    = honeycombio_dataset.test-dataset.name
  query_json = data.honeycombio_query_specification.avg-trigger-query-spec.json
}

# Creates a trigger in the dataset
resource "honeycombio_trigger" "test-trigger" {
  name        = "Test Trigger"
  description = "I am a test trigger"
  dataset     = honeycombio_dataset.test-dataset.name

  query_id = honeycombio_query.avg-trigger-query.id

  // In seconds, 10 minutes
  frequency = 600

  alert_type = "on_change"

  threshold {
    op    = ">"
    value = 1000
  }

  recipient {
    id = data.honeycombio_recipient.test-pagerduty.id
  }
}

# SLOs
# Creates a derived column in the dataset
resource "honeycombio_derived_column" "test-sli" {
  alias       = "sli.test-sli"
  description = "I am a test SLI"
  dataset     = honeycombio_dataset.test-dataset.name

  expression = format("LTE($%s, 100)", honeycombio_column.test-column.name)
}

# Creates an SLO
resource "honeycombio_slo" "test-slo" {
  name        = "Test SLO"
  description = "I am a test SLO"
  dataset     = honeycombio_dataset.test-dataset.name

  sli               = honeycombio_derived_column.test-sli.alias
  target_percentage = 99.9
  time_period       = 30
}

# Creates an exhaustion time alert for the SLO
resource "honeycombio_burn_alert" "test-exhaustion-time-alert" {
  alert_type         = "exhaustion_time"
  exhaustion_minutes = 480

  dataset = honeycombio_dataset.test-dataset.name
  slo_id  = honeycombio_slo.test-slo.id

  recipient {
    id = honeycombio_email_recipient.test-email.id
  }
}

# Creates a budget rate alert for the SLO
resource "honeycombio_burn_alert" "budget-rate-alert" {
  alert_type                   = "budget_rate"
  budget_rate_window_minutes   = 480
  budget_rate_decrease_percent = 1

  dataset = honeycombio_dataset.test-dataset.name
  slo_id  = honeycombio_slo.test-slo.id

  recipient {
    id = honeycombio_email_recipient.test-email.id
  }

  recipient {
    id = honeycombio_webhook_recipient.test-webhook.id
  }
}