output "frontend_instance_id" {
  value = var.name == "frontend" ? aws_instance.main.id : null
}