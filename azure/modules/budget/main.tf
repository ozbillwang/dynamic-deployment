data "azurerm_subscription" "current" {}

variable "amount" {
  default = 500.0
}

variable "thresholds" {
  default = [80.0, 100.0, 150.0]
}

variable "email_address" {
  default = ["<your_mailbox>"]
}

resource "azurerm_consumption_budget_subscription" "this" {
  name               = format("%s-%s-monthly", data.azurerm_subscription.current.display_name, substr(data.azurerm_subscription.current.subscription_id,0,8))
  subscription_id = data.azurerm_subscription.current.id

  amount             = var.amount
  time_grain         = "Monthly"

  time_period {
    start_date = "2024-01-01T00:00:00Z"
  }

  dynamic "notification" {
    for_each = toset(var.thresholds)

    content {
      enabled        = true
      threshold      = notification.key
      operator       = "GreaterThan"
      threshold_type = "Actual"

      contact_emails = var.email_address
    }
  }
}
