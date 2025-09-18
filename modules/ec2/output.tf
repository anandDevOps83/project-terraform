output "frontend_instance_id" {
  value = var.name == "frontend" ? aws_instance.main.id : "Instance name mismatch, ID not exported"
}