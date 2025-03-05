output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "web_server_public_ip" {
  value = aws_instance.web_server.public_ip
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/kp-athena ec2-user@${aws_instance.web_server.public_ip}"
}