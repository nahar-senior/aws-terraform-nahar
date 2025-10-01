variable "prefix" {
  description = "Prefix for resource naming"
  type        = string
}

variable "node_type_id" {
  description = "Node type for worker nodes"
  type        = string
  default     = "i3.xlarge"
}

variable "driver_node_type_id" {
  description = "Node type for driver node"
  type        = string
  default     = "i3.xlarge"
}

variable "min_workers" {
  description = "Minimum number of workers"
  type        = number
  default     = 1
}

variable "max_workers" {
  description = "Maximum number of workers"
  type        = number
  default     = 3
}

variable "autotermination_minutes" {
  description = "Auto-termination time in minutes"
  type        = number
  default     = 60
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
