# 1. BASE SECURITY GROUPS 

resource "aws_security_group" "sg_gateway" {
  name   = "sg_gateway"
  vpc_id = aws_vpc.main.id
  tags   = { Name = "sg-gateway-public" }
}

resource "aws_security_group" "sg_private" {
  name   = "sg_private"
  vpc_id = aws_vpc.main.id
  tags   = { Name = "sg-private-internal" }
}

# 2. STANDALONE RULES FOR GATEWAY & PRIVATE

# --- Gateway Inbound Rules ---
# Allow HTTP traffic from anywhere
resource "aws_security_group_rule" "gw_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_gateway.id
}

# Allow HTTPS traffic from anywhere
resource "aws_security_group_rule" "gw_ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_gateway.id
}

# Allow SSH (Port 6969) for remote access
resource "aws_security_group_rule" "gw_ingress_ssh" {
  type              = "ingress"
  from_port         = 6969
  to_port           = 6969
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_gateway.id
}

# --- Private Inbound Rules ---
# Allow all internal communication within this Security Group
resource "aws_security_group_rule" "private_ingress_self" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.sg_private.id
  security_group_id        = aws_security_group.sg_private.id
}

# --- Outbound (Egress) Rules ---
# Allow all outbound traffic from Gateway
resource "aws_security_group_rule" "gw_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_gateway.id
}

# Allow all outbound traffic from Private servers
resource "aws_security_group_rule" "private_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_private.id
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

# 3. Allow Gateway to access Prometheus in Monitoring Server
resource "aws_security_group_rule" "gateway_to_private_prometheus" {
  type                     = "ingress"
  from_port                = 9090
  to_port                  = 9090
  protocol                 = "tcp"
  security_group_id        = aws_security_group.sg_private.id
  source_security_group_id = aws_security_group.sg_gateway.id
}

# 4. Allow Gateway to access Node Exporter in Monitoring Server
resource "aws_security_group_rule" "gateway_to_private_node_exporter" {
  type                     = "ingress"
  from_port                = 9100
  to_port                  = 9100
  protocol                 = "tcp"
  security_group_id        = aws_security_group.sg_private.id
  source_security_group_id = aws_security_group.sg_gateway.id
}

# 4. Allow Gateway to access Frontend App in Staging/K3s
resource "aws_security_group_rule" "gateway_to_private_app_fe" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.sg_private.id
  source_security_group_id = aws_security_group.sg_gateway.id
}

# 5. Allow Gateway to access Backend App in Staging/K3s
resource "aws_security_group_rule" "gateway_to_private_app_be" {
  type                     = "ingress"
  from_port                = 5000
  to_port                  = 5000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.sg_private.id
  source_security_group_id = aws_security_group.sg_gateway.id
}

# 6. Allow Gateway to access SonarQube in CI/CD Server
resource "aws_security_group_rule" "gateway_to_private_sonarqube" {
  type                     = "ingress"
  from_port                = 9000
  to_port                  = 9000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.sg_private.id
  source_security_group_id = aws_security_group.sg_gateway.id
}
