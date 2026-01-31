# =============================================================================
# 1. NETWORK (VPC, SUBNETS, GATEWAYS)
# =============================================================================

resource "aws_vpc" "k3s_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  
  tags = { Name = "k3s-f1-vpc", Project = "F1-Vote-Pro" }
}

# --- PUBLIC ZONE (DMZ) ---
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.k3s_vpc.id
  tags   = { Name = "k3s-igw" }
}

# Public Subnet 1 (Zone A) - For Bastion & ALB
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.k3s_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-3a"
  tags                    = { Name = "public-subnet-a" }
}

# Public Subnet 2 (Zone B) - Required for ALB High Availability
resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.k3s_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-3b"
  tags                    = { Name = "public-subnet-b" }
}

# Route Table for Public Zone
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.k3s_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = { Name = "public-rt" }
}

resource "aws_route_table_association" "pub_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "pub_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_rt.id
}

# --- PRIVATE ZONE (The Vault) ---
# Private Subnet - Where K3s Cluster lives (Hidden from Internet)
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.k3s_vpc.id
  cidr_block        = "10.0.10.0/24" # <--- TARGET FOR ALB
  availability_zone = "eu-west-3a"
  tags              = { Name = "private-subnet-k3s" }
}

# NAT Gateway (The only way out for Private Servers)
# Requires an Elastic IP (Static Public IP)
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_1.id # Lives in Public, connects Private
  tags          = { Name = "k3s-nat-gw" }
}

# Route Table for Private Zone (Routes to NAT, not IGW)
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.k3s_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
  tags = { Name = "private-rt" }
}

resource "aws_route_table_association" "priv" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_rt.id
}