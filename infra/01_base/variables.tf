variable "environment_name" {
  description = "Name of the azd environment. Used to derive resource names and the azd-env-name tag."
  type        = string
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
}

