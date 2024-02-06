# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  subscription_name = "{{.subscription_name}}"
  subscription_id = "{{.subscription_id}}"
  deployment_storage_account_name = "sa${substr(local.subscription_id, 0, 8)}"
  deployment_storage_resource_group_name = "sa${substr(local.subscription_id, 0, 8)}"
}
