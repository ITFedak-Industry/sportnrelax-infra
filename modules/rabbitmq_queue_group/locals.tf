locals {
  # Number of retries
  retry = 9
  ttl = 5000

  basenames = [for event in var.events: "${var.app}.${event}"]

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
            ttl = local.ttl
          }
        ],

        # Retry chain bindings
        [
          for i in range(1, local.retry) : {
            source      = "${basename}.retry${i}"
            routing_key  = "${basename}.retry${i+1}"
            destination = "${basename}.retry${i+1}"
            ttl = i * local.ttl
          }
        ],

        # Final DLQ binding
        [
          {
            source      = "${basename}.retry${local.retry}"
            routing_key  = "${basename}.dlq"
            destination = "${basename}.dlq"
            ttl = local.retry * local.ttl
          }
        ]
      ])
    }
  }
}