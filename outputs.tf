output "aws_instance_public_ip" {
  description = "Public IP of the Nginx Proxy Server"
  value       = module.myapp-webserver.instance.public_ip
}

output "aws_web-1_public_ip" {
  description = "Public IP of the Apache Backend Server"
  value       = module.myapp-web-1.instance.public_ip
}
output "aws_web-2_public_ip" {
  value = module.myapp-web-2.instance.public_ip
}