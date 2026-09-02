variable "environment_name" {
  type = string
}

variable "location" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "principal_id" {
  type    = string
  default = ""
}

variable "github_actions_principal_id" {
  type    = string
  default = ""
}

variable "acr_sku" {
  type    = string
  default = "Premium"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "acr_sku must be one of Basic, Standard or Premium."
  }
}
