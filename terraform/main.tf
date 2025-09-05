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
# 🔹 KEY PAIR (criado na hora do apply)
###############################################################
resource "aws_key_pair" "lab_key" {
  key_name   = "lab-key"
  public_key = file("~/.ssh/id_rsa.pub")   # 🔹 sua chave pública local
}

###############################################################
# MÓDULO DE EC2
###############################################################
module "ec2_instance" {
  source            = "./modules/ec2"
  ami               = "ami-0c02fb55956c7d316"
  instance_type     = "t3.micro"
  subnet_id         = aws_subnet.main.id
  security_group_id = module.security_group.security_group_id
  key_name          = aws_key_pair.lab_key.key_name   # 🔹 usa o Key Pair criado acima
  name              = "debugai-ec2"

  user_data         = <<-EOF
#!/bin/bash
sudo apt-get update
sudo apt-get install -y docker.io git
sudo systemctl start docker
sudo systemctl enable docker
cd /home/ubuntu
git clone git@github.com:LuizSilva-1/IA-Generativa-DebugAI.git app
cd app
sudo docker build -t debugai .
sudo docker run -d -p 8501:8501 --name debugai debugai
EOF
}

###############################################################
# OUTPUT DO IP PÚBLICO DA INSTÂNCIA
###############################################################
output "instance_public_ip" {
  value = module.ec2_instance.public_ip
}
