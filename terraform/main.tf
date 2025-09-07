terraform {
  required_version = ">= 1.3.0"
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

###############################################################
# REDE PERSONALIZADA: VPC + Subnet + IGW + Route Table
###############################################################
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "main-vpc"
    Project     = "debugai"
    Environment = "dev"
    Owner       = "luiz"
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name        = "main-subnet"
    Project     = "debugai"
    Environment = "dev"
    Owner       = "luiz"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "main-igw"
    Project     = "debugai"
    Environment = "dev"
    Owner       = "luiz"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "main-route-table"
    Project     = "debugai"
    Environment = "dev"
    Owner       = "luiz"
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

###############################################################
# SECURITY GROUP
###############################################################
module "security_group" {
  source            = "./modules/security_group"
  name              = "main-sg"
  description       = "Allow inbound traffic for Streamlit"
  vpc_id            = aws_vpc.main.id
  ingress_from_port = 8501
  ingress_to_port   = 8501
}

###############################################################
# KEY PAIR
###############################################################
resource "aws_key_pair" "lab_key" {
  key_name = "lab-key"

  public_key = try(
    file(pathexpand("~/.ssh/id_rsa.pub")),
    file("${path.module}/lab-key.pub")
  )
}

###############################################################
# VARIÁVEL PARA GEMINI_API_KEY
###############################################################
variable "gemini_api_key" {
  description = "API Key do Google Gemini"
  type        = string
  sensitive   = true
}

###############################################################
# EC2 INSTANCE (via módulo)
###############################################################
module "ec2_instance" {
  source            = "./modules/ec2"
  ami               = "ami-0360c520857e3138f" # Ubuntu 22.04 LTS (us-east-1)
  instance_type     = "t3.micro"
  subnet_id         = aws_subnet.main.id
  security_group_id = module.security_group.security_group_id
  key_name          = aws_key_pair.lab_key.key_name
  name              = "debugai-ec2"

  user_data = <<-EOF
#!/bin/bash
set -xe
apt-get update -y
apt-get install -y docker.io git

# Docker
systemctl start docker
systemctl enable docker

# Clonar app
cd /home/ubuntu
git clone https://github.com/LuizSilva-1/IA-Generativa-DebugAI.git app || exit 1
cd app

# Criar .env
echo "GEMINI_API_KEY=${var.gemini_api_key}" > .env

# Build + Run
docker build -t debugai .
docker run -d -p 8501:8501 --name debugai --env-file .env debugai
EOF
}

###############################################################
# OUTPUTS
###############################################################
output "instance_public_ip" {
  description = "IP público da instância EC2"
  value       = module.ec2_instance.public_ip
}

output "ssh_key_name" {
  description = "Nome do par de chaves associado à instância"
  value       = aws_key_pair.lab_key.key_name
}
