# Search Ubuntu 22.04 LTS ID
data "aws_ami" "ubuntu_22" {
  most_recent = true
  owners      = ["099720109477"] # Offical ID Canonical (Ubuntu)
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 1. Gateway (Public)
resource "aws_instance" "gateway" {
  ami                    = data.aws_ami.ubuntu_22.id
  instance_type          = "t3.micro" # 2 CPU, 1GB RAM
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.sg_gateway.id]
  key_name               = aws_key_pair.finaltask_key.key_name

  user_data = <<-EOF
    #!/bin/bash
    hostnamectl set-hostname gateway

    # Change SSH Port to 6969 
    sed -i 's/^#*Port 22/Port 6969/' /etc/ssh/sshd_config
    systemctl restart ssh
      
  EOF

  tags = { Name = "Gateway-Server" }
}

# Elastic IP Server Gateway
resource "aws_eip" "gateway_eip" {
  domain   = "vpc"
  instance = aws_instance.gateway.id
  tags     = { Name = "gateway-eip" }
}

# 2. Server Private (App & ToolS)
# Server Staging
resource "aws_instance" "staging" {
  ami                    = data.aws_ami.ubuntu_22.id
  instance_type          = "t3.small"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.sg_private.id]
  key_name               = aws_key_pair.finaltask_key.key_name

  user_data = <<-EOF
    #!/bin/bash
    hostnamectl set-hostname staging

    # Change SSH Port to 6969 
    sed -i 's/^#*Port 22/Port 6969/' /etc/ssh/sshd_config
    systemctl restart ssh
  EOF

  tags = { Name = "Staging-Server" }
}

# Server Production - K3s Master
resource "aws_instance" "master" {
  ami                    = data.aws_ami.ubuntu_22.id
  instance_type          = "t3.small"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.sg_private.id]
  key_name               = aws_key_pair.finaltask_key.key_name

  user_data = <<-EOF
    #!/bin/bash
    hostnamectl set-hostname prod-master

    # Change SSH Port to 6969 
    sed -i 's/^#*Port 22/Port 6969/' /etc/ssh/sshd_config
    systemctl restart ssh
  EOF

  tags = { Name = "Production-Master" }
}

# Server Production - K3s Worker
resource "aws_instance" "worker" {
  ami                    = data.aws_ami.ubuntu_22.id
  instance_type          = "t3.small"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.sg_private.id]
  key_name               = aws_key_pair.finaltask_key.key_name

  user_data = <<-EOF
    #!/bin/bash
    hostnamectl set-hostname prod-worker

    # Change SSH Port to 6969 
    sed -i 's/^#*Port 22/Port 6969/' /etc/ssh/sshd_config
    systemctl restart ssh
  EOF

  tags = { Name = "Production-Worker" }
}

# Server CI/CD & SonarQube
resource "aws_instance" "cicd" {
  ami                    = data.aws_ami.ubuntu_22.id
  instance_type          = "t3.small"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.sg_private.id]
  key_name               = aws_key_pair.finaltask_key.key_name

  user_data = <<-EOF
    #!/bin/bash
    hostnamectl set-hostname cicd-runner

    # Change SSH Port to 6969 
    sed -i 's/^#*Port 22/Port 6969/' /etc/ssh/sshd_config
    systemctl restart ssh
  EOF

  tags = { Name = "CICD-Server" }
}

# Server Monitoring & Docker Registry
resource "aws_instance" "monitoring" {
  ami                    = data.aws_ami.ubuntu_22.id
  instance_type          = "t3.small"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.sg_private.id]
  key_name               = aws_key_pair.finaltask_key.key_name

  user_data = <<-EOF
    #!/bin/bash
    hostnamectl set-hostname monitoring

    # Change SSH Port to 6969 
    sed -i 's/^#*Port 22/Port 6969/' /etc/ssh/sshd_config
    systemctl restart ssh
  EOF

  tags = { Name = "Monitoring-Server" }
}