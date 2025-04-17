locals {
  # Number of retries
  retry = 9

  app = "catalog"
  events = ["session.created", "session.canceled"]  # Array of events
  basenames = [for event in local.events: "${local.app}.${event}"]

  config = {
    for basename in local.basenames : basename => {
      main  = "${basename}.queue"
      dlq  = "${basename}.dlq"

      bindings = flatten([
        # First binding
        [
          {
            source      = "${basename}.queue"
            routing_key  = "${basename}.retry1"
            destination = "${basename}.retry1"
          }
        ],

        # Retry chain bindings
        [
          for i in range(1, local.retry) : {
            source      = "${basename}.retry${i}"
            routing_key  = "${basename}.retry${i+1}"
            destination = "${basename}.retry${i+1}"
          }
        ],

        # Final DLQ binding
        [
          {
            source      = "${basename}.retry${local.retry}"
            routing_key  = "${basename}.dlq"
            destination = "${basename}.dlq"
          }
        ]
      ])
    }
  }
}

# Create main / retry / dlq queues for each basename
resource "rabbitmq_queue" "catalog_queues" {
  for_each = {for idx, binding in flatten([for v in local.config : v.bindings]) : idx => binding}

  vhost = rabbitmq_vhost.default_vhost.name

  name  = each.value.source
  settings {
    durable     = true
    auto_delete = false
    arguments = {
      "x-dead-letter-exchange" = rabbitmq_exchange.session_exchange.name
      "x-dead-letter-routing-key" = each.value.routing_key
    }
  }
}

resource "rabbitmq_queue" "catalog_queues_dlq" {
  for_each = {for idx, v in local.config : idx => v.dlq}

  vhost = rabbitmq_vhost.default_vhost.name

  name  = each.value
  settings {
    durable     = true
    auto_delete = false
  }
}

# Bind (exchange, event) pair to corresponding main queue
resource "rabbitmq_binding" "catalog_main_queues_bindings" {
  for_each = zipmap(local.events, local.basenames)

  vhost       = rabbitmq_vhost.default_vhost.name

  source      = rabbitmq_exchange.session_exchange.name
  routing_key  = each.key
  destination = local.config[each.value].main
  destination_type = "queue"

  depends_on = [
    rabbitmq_queue.catalog_queues,
    rabbitmq_queue.catalog_queues_dlq
  ]
}

resource "rabbitmq_binding" "catalog_retry_bindings" {
  for_each = {for idx, binding in flatten([for v in local.config : v.bindings]) : idx => binding}

  vhost       = rabbitmq_vhost.default_vhost.name

  source      = rabbitmq_exchange.session_exchange.name
  routing_key  = each.value.routing_key
  destination = each.value.destination
  destination_type = "queue"

  depends_on = [
    rabbitmq_queue.catalog_queues,
    rabbitmq_queue.catalog_queues_dlq
  ]
}