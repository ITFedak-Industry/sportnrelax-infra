module "rabbitmq" {
  source            = "./rabbitmq"
  rabbitmq_endpoint = var.rabbitmq_endpoint
  rabbitmq_username = var.rabbitmq_username
  rabbitmq_password = var.rabbitmq_password
}


output "session_exchange_name" {
  value = module.rabbitmq.session_exchange_name
}