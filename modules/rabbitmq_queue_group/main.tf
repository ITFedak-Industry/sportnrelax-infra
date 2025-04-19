terraform {
  required_providers {
    rabbitmq = {
      source  = "cyrilgdn/rabbitmq"
      version = "~> 1.8"
    }
  }
}

# Create main / retry / dlq queues for each basename
resource "rabbitmq_queue" "queues" {
  for_each = {for idx, binding in flatten([for v in local.config : v.bindings]) : idx => binding}

  vhost = var.vhost

  name  = each.value.source
  settings {
    durable     = true
    auto_delete = false
    arguments_json = jsonencode({
      "x-dead-letter-exchange" = var.exchange
      "x-dead-letter-routing-key" = each.value.routing_key
      "x-message-ttl"             = each.value.ttl
    })
  }
}

resource "rabbitmq_queue" "queues_dlq" {
  for_each = {for idx, v in local.config : idx => v.dlq}

  vhost = var.vhost

  name  = each.value
  settings {
    durable     = true
    auto_delete = false
  }
}

# Bind (exchange, event) pair to corresponding main queue
resource "rabbitmq_binding" "main_queues_bindings" {
  for_each = zipmap(var.events, local.basenames)

  vhost       = var.vhost

  source      = var.exchange
  routing_key  = each.key
  destination = local.config[each.value].main
  destination_type = "queue"

  depends_on = [
    rabbitmq_queue.queues,
    rabbitmq_queue.queues_dlq
  ]
}

resource "rabbitmq_binding" "retry_bindings" {
  for_each = {for idx, binding in flatten([for v in local.config : v.bindings]) : idx => binding}

  vhost       = var.vhost

  source      = var.exchange
  routing_key  = each.value.routing_key
  destination = each.value.destination
  destination_type = "queue"

  depends_on = [
    rabbitmq_queue.queues,
    rabbitmq_queue.queues_dlq
  ]
}

output "queue_groups" {
  value = rabbitmq_queue.queues
}