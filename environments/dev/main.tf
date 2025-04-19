terraform {
  required_providers {
    rabbitmq = {
      source  = "cyrilgdn/rabbitmq"
      version = "~> 1.8"
    }
  }
}

provider "rabbitmq" {
  # https://developer.hashicorp.com/terraform/language/providers/configuration#selecting-alternate-provider-configurations
  # "alias" in case of requirement of instantiating multiple provider with different creds i.e 
  # alias = "main"

  endpoint = var.rabbitmq_endpoint
  username = var.rabbitmq_username
  password = var.rabbitmq_password
}

resource "rabbitmq_vhost" "default_vhost" {
  # provider = rabbitmq.main  // resource-level provider select

  name = "/" # Or a specific vhost if you're using one
}

resource "rabbitmq_exchange" "session_exchange" {
  vhost = rabbitmq_vhost.default_vhost.name
  name  = "session.exchange"
  settings {
    type        = "topic" # Using topic exchange for flexible routing
    durable     = true
    auto_delete = false
  }
}

module "rabbitmq_session_catalog_group_queue" {
  source = "./modules/rabbitmq_queue_group"

  providers = {
    # rabbitmq = rabbitmq.main // module-level provider select
    rabbitmq = rabbitmq
  }

  vhost    = rabbitmq_vhost.default_vhost.name
  app      = "catalog"
  events   = ["session.created", "session.canceled"] # Array of events
  exchange = rabbitmq_exchange.session_exchange.name
}

output "session_exchange_name" {
  value = rabbitmq_exchange.session_exchange.name
}