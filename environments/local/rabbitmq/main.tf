terraform {
  required_providers {
    rabbitmq = {
      source  = "cyrilgdn/rabbitmq"
      version = "~> 1.8"
    }
  }
}

provider "rabbitmq" {
  endpoint = var.rabbitmq_endpoint
  username = var.rabbitmq_username
  password = var.rabbitmq_password
}

resource "rabbitmq_vhost" "default_vhost" {
  name = "/" # Or a specific vhost if you're using one
}

output "session_exchange_name" {
  value = rabbitmq_exchange.session_exchange.name
}