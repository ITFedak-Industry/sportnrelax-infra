variable "rabbitmq_endpoint" {
  type        = string
  description = "The RabbitMQ Management UI endpoint"
}

variable "rabbitmq_username" {
  type        = string
  description = "The RabbitMQ username"
}

variable "rabbitmq_password" {
  type        = string
  description = "The RabbitMQ password"
  sensitive   = true # Mark as sensitive to prevent output in logs
}