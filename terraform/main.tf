provider "aws" {
  region = "eu-west-3" # Paris Region
}

# =============================================================================
# 1. NETWORK & INFRASTRUCTURE (VPC)
# =============================================================================

# The VPC is the isolated network container for the entire project
resource "aws_vpc" "k3s_vpc" {
  cidr_block           = "10.0.0.0/16" # 65k IPs available
  enable_dns_hostnames = true          # Required for nodes to find each other by name
  
  tags = { 
    Name        = "k3s-f1-vpc"
    Project     = "F1-Voting-App"
    Description = "Isolated network for K3s Kubernetes cluster"
  }
}

# The gateway to the Internet (for downloading Docker images, updates, etc.)
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.k3s_vpc.id
  
  tags = { Name = "k3s-f1-gateway" }
}

# The public subnet where our servers will reside
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.k3s_vpc.id
  cidr_block              = "10.0.1.0/24" # 256 IPs (10.0.1.x)
  map_public_ip_on_launch = true          # Automatically assigns a public IP to VMs
  availability_zone       = "eu-west-3a"  # Paris Datacenter A
  
  tags = { Name = "k3s-f1-public-subnet" }
}

# The route table that dictates: "Anything not local must go to the Internet"
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.k3s_vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = { Name = "k3s-f1-route-table" }
}

# Associate the route table with our public subnet
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

# =============================================================================
# 2. SECURITY (FIREWALL / SECURITY GROUP)
# =============================================================================

resource "aws_security_group" "k3s_sg" {
  name        = "k3s-security-group"
  description = "Firewall rules for F1 K3s Cluster"
  vpc_id      = aws_vpc.k3s_vpc.id

  # --- INGRESS RULES (Inbound) ---

  # 1. SSH: Always needed for Ansible and Admin access
  ingress {
    description = "SSH Access for Admin"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 2. K3s API: Required for kubectl access from your PC
  ingress {
    description = "K3s Kubernetes API Server"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 3. HTTP & HTTPS: Standard web access
  ingress {
    description = "HTTP Web Traffic (Ingress)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS Web Traffic (Ingress)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 4. Internal Traffic (Vital for Pod-to-Pod communication)
  ingress {
    description = "Internal Cluster Communication (Self)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # --- EGRESS RULES (Outbound) ---
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "k3s-f1-firewall" }
}

# =============================================================================
# 3. KEY MANAGEMENT
# =============================================================================

# Cryptographic key generation (RSA 4096 bits)
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Send the PUBLIC key to AWS (The lock on the servers)
resource "aws_key_pair" "generated_key" {
  key_name   = "k3s-f1-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Save the PRIVATE key to your PC (The key to enter)
resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/k3s-f1-key.pem"
  file_permission = "0600" # Restricted permissions required by SSH
}

# =============================================================================
# 4. SERVERS (EC2 INSTANCES)
# =============================================================================

# Dynamically fetch the latest Ubuntu 22.04 LTS image
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical Official
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# --- THE MASTER (Control Plane) ---
# Requires more RAM (2GB) to manage Kubernetes database (etcd/sqlite)
resource "aws_instance" "master" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small" # 2 vCPU / 2 Go RAM
  key_name      = aws_key_pair.generated_key.key_name
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.k3s_sg.id]

  tags = {
    Name = "k3s-master"
    Role = "control-plane"
  }
}

# --- THE WORKERS (Compute Nodes) ---
# Running application Pods. t3.micro is enough for K3s agent + Node.js App
resource "aws_instance" "workers" {
  count         = 2
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro" # 2 vCPU / 1 Go RAM (Free Tier eligible)
  key_name      = aws_key_pair.generated_key.key_name
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.k3s_sg.id]

  tags = {
    Name = "k3s-worker-${count.index + 1}"
    Role = "worker"
  }
}

# =============================================================================
# 5. OUTPUTS
# =============================================================================

output "master_ip" {
  description = "Public IP of the Master node (Use for SSH and K3s API)"
  value       = aws_instance.master.public_ip
}

output "worker_ips" {
  description = "Public IPs of the Worker nodes"
  value       = aws_instance.workers[*].public_ip
}

output "ssh_command_example" {
  description = "Command to connect to the Master"
  value       = "ssh -i k3s-f1-key.pem ubuntu@${aws_instance.master.public_ip}"
}