variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "log_analytics_name" {
  type = string
}

variable "monitor_workspace_name" {
  type = string
}

variable "grafana_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
