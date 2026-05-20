# main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
} 
# Security group for web servers - allows SSH and HTTP
resource "aws_security_group" "web_sg" {
  name        = "web-servers-sg"
  description = "Allow SSH and HTTP"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
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
    Name = "web-servers-sg"
  }
}

# Security group for control node - allows SSH only
resource "aws_security_group" "control_sg" {
  name        = "control-node-sg"
  description = "Allow SSH"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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
    Name = "control-node-sg"
  }
}

# Three web server EC2 instances
resource "aws_instance" "web1" {
  ami                    = "ami-02fe376e6ac9632c8"
  instance_type          = "t2.micro"
  key_name               = "ansible-key"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  tags = { Name = "WebServer1" }
}

resource "aws_instance" "web2" {
  ami                    = "ami-02fe376e6ac9632c8"
  instance_type          = "t2.micro"
  key_name               = "ansible-key"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  tags = { Name = "WebServer2" }
}

resource "aws_instance" "web3" {
  ami                    = "ami-02fe376e6ac9632c8"
  instance_type          = "t2.micro"
  key_name               = "ansible-key"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  tags = { Name = "WebServer3" }
}

# Control node EC2 instance - this is where Ansible runs from
resource "aws_instance" "control_node" {
  ami                    = "ami-02fe376e6ac9632c8"
  instance_type          = "t2.micro"
  key_name               = "ansible-key"
  vpc_security_group_ids = [aws_security_group.control_sg.id]
  tags = { Name = "ControlNode" }
}