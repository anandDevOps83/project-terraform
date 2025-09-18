output "frontend_instance_id" {
  value = aws_instance.main.tags.Name == "frontend-dev" ? aws_instance.main.id : "Instance name mismatch, ID not exported"
}