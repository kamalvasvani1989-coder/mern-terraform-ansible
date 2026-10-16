output "web_public_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.web.public_ip
}

output "db_private_ip" {
  description = "Private IP of the database server"
  value       = aws_instance.db.private_ip
}
