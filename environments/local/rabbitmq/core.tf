resource "rabbitmq_exchange" "session_exchange" {
  vhost      = rabbitmq_vhost.default_vhost.name
  name       = "session.exchange"
  settings {
    type        = "topic" # Using topic exchange for flexible routing
    durable     = true
    auto_delete = false
  }
}