# 1. Main VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = "main-vpc" }
}

# 2. Internet Gateway 
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "main-igw" }
}

# 3. Public Subnet 
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-southeast-1a"
  tags              = { Name = "public-subnet" }
}

# 4. Public Route Table 
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"                 # Route all outbound traffic...
    gateway_id = aws_internet_gateway.igw.id # ...through the Internet Gatewayy
  }

  tags = { Name = "public-route-table" }
}

# 5. Associate Public Subnet with Public Route Table
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}


# 6. Private Subnet
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false # Instances will not get public IPs
  availability_zone       = "ap-southeast-1a"
  tags                    = { Name = "private-subnet" }
}

# 7. Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags   = { Name = "nat-eip" }
}

# 8. NAT Gateway (Enables outbound internet access for private subnet)
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id
  tags          = { Name = "main-nat" }
  depends_on    = [aws_internet_gateway.igw]
}

# 9. Private Route Table 
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"            # Route all outbound traffic from private instances...
    nat_gateway_id = aws_nat_gateway.nat.id # ...through the NAT Gateway
  }

  tags = { Name = "private-route-table" }
}

# 10. Associate Private Subnet with Private Route Table
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_rt.id
}