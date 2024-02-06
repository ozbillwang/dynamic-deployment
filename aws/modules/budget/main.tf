variable "thresholds" {
  type    = list(number)
  default = [80.0, 100.0, 150.0]
}

variable "email_addresses" {
  type    = list(string)
  default = ["<update_your_mailbox>"]
}

variable "budget_limit" {
  type    = number
  default = 500.0
}

data "aws_caller_identity" "this" {}

data "aws_iam_account_alias" "this" {}

resource "aws_budgets_budget" "this" {
  name              = "${data.aws_iam_account_alias.this.account_alias}-${data.aws_caller_identity.this.account_id}-monthly"
  budget_type       = "COST"
  limit_amount      = var.budget_limit
  limit_unit        = "USD"
  time_period_start = "2024-01-01_00:00"
  time_unit         = "MONTHLY"

  dynamic "notification" {
    for_each = var.thresholds
    content {
      comparison_operator        = "GREATER_THAN"
      threshold                  = notification.value
      threshold_type             = "PERCENTAGE"
      notification_type          = "ACTUAL"
      subscriber_email_addresses = var.email_addresses
    }
  }
}

