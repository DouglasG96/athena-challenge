provider "aws" {
  region = var.region
  profile = var.profile
}

data "http" "my_public_ip" {
  url = "https://ifconfig.me/ip" # A service that returns your public IP
}

locals {
  my_ip = "${chomp(data.http.my_public_ip.response_body)}/32"
}

# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
}

# Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
}

# Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "igw-athena"
  }
}

# Create a route table for the public subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Associate the public subnet with the public route table
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Security Group for EC2
resource "aws_security_group" "web_sg"  {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.my_ip] # Allow SSH only from your current IP
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg-athena"
  }
}

resource "aws_key_pair" "athena_key" {
  key_name   = "kp-athena"
  public_key = file("~/.ssh/kp-athena.pub") # Path to your public key file
}

# EC2 Instance
resource "aws_instance" "web_server" {
  ami             = "ami-05b10e08d247fb927"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name        = "kp-athena"
  tags = {
    Name = "web-server-athena"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd awslogs

              # Configure AWS CloudWatch Logs Agent
              cat <<EOL > /etc/awslogs/awslogs.conf
              [general]
              state_file = /var/lib/awslogs/agent-state

              [/var/log/messages]
              file = /var/log/messages
              log_group_name = ${aws_cloudwatch_log_group.system_logs.name}
              log_stream_name = {instance_id}
              datetime_format = %b %d %H:%M:%S

              [/var/log/httpd/access_log]
              file = /var/log/httpd/access_log
              log_group_name = ${aws_cloudwatch_log_group.application_logs.name}
              log_stream_name = {instance_id}
              datetime_format = %d/%b/%Y:%H:%M:%S %z
              EOL

              # Start and enable AWS Logs Agent
              systemctl start awslogsd
              systemctl enable awslogsd

              # Start and enable Apache
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello, AWS DevOps!</h1>" > /var/www/html/index.html
              EOF
}