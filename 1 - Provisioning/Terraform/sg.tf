# 1. SECURITY GROUP GATEWAY 
resource "aws_security_group" "sg_gateway" {
  name   = "sg_gateway"
  vpc_id = aws_vpc.main.id
  tags   = { Name = "sg-gateway-public" }

  # HTTP 
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS 
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH - Port 6969 open for remote access
  ingress {
    from_port   = 6969
    to_port     = 6969
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. SECURITY GROUP PRIVATE 
# Applied for Staging, Prod K3s, Runner, & Monitoring
resource "aws_security_group" "sg_private" {
  name   = "sg_private"
  vpc_id = aws_vpc.main.id
  tags   = { Name = "sg-private-internal" }

  # Allow all internal communication within this Security Group
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  # Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. CROSS-REFERENCE RULES 
# Allow Prometheus (Private SG) to scrape Node Exporter on Gateway
resource "aws_security_group_rule" "gateway_allow_prometheus" {
  type                     = "ingress"
  from_port                = 9100
  to_port                  = 9100
  protocol                 = "tcp"
  security_group_id        = aws_security_group.sg_gateway.id
  source_security_group_id = aws_security_group.sg_private.id
}

# Gateway to Private rules
# 1. Allow Gateway to SSH into all private servers
resource "aws_security_group_rule" "gateway_to_private_ssh" {
  type                     = "ingress"
  from_port                = 6969
  to_port                  = 6969
  protocol                 = "tcp"
  security_group_id        = aws_security_group.sg_private.id
  source_security_group_id = aws_security_group.sg_gateway.id
}

# 2. Allow Gateway to access Grafana in Monitoring Server
resource "aws_security_group_rule" "gateway_to_private_grafana" {
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.sg_private.id
  source_security_group_id = aws_security_group.sg_gateway.id
}

# 3. Allow Gateway to access Frontend App in Staging/K3s
resource "aws_security_group_rule" "gateway_to_private_app_fe" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.sg_private.id
  source_security_group_id = aws_security_group.sg_gateway.id
}

# 3. Allow Gateway to access Backend App in Staging/K3s
resource "aws_security_group_rule" "gateway_to_private_app_be" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = aws_security_group.sg_private.id
  source_security_group_id = aws_security_group.sg_gateway.id
}