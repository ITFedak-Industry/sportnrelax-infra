variable "app" {
  type = string
  description = "App name"
}

variable "events" {
  type = list(string)
  description = "List of events that queue group should react on"
}

variable "exchange" {
  type = string
  description = "Name of exchange that queues should be bound to"
}

variable "vhost" {
  type = string
  description = "vhost where queues should be created within"
}