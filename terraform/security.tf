# =============================================================================
# 2. SECURITY GROUPS (FIREWALLS)
# =============================================================================

# A. BASTION SG (The Doorman)
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Security Group for Bastion Host"
  vpc_id      = aws_vpc.k3s_vpc.id

  # --- INGRESS ---
  ingress {
    description = "SSH from Admin"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # --- EGRESS ---
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# B. ALB SG (The Public Entrance)
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP from world, strict outbound"
  vpc_id      = aws_vpc.k3s_vpc.id

  # --- INGRESS ---
  ingress {
    description = "HTTP from World"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # --- EGRESS ---
  # Strict: Can only talk to the Private Subnet (10.0.10.0/24)
  egress {
    description = "Forward traffic to K3s Private Nodes"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.10.0/24"]
  }
}

# C. K3S PRIVATE SG (The Vault Rules)
resource "aws_security_group" "k3s_internal_sg" {
  name        = "k3s-internal-sg"
  description = "Internal Rules for K3s Nodes"
  vpc_id      = aws_vpc.k3s_vpc.id

  # Rule 1: Allow SSH ONLY from Bastion
  ingress {
    description     = "SSH from Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  # Rule 2: Allow HTTP traffic ONLY from Load Balancer
  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  
  # Rule 3: Allow API access ONLY from Bastion (for kubectl tunneling)
  ingress {
    description     = "K8s API from Bastion"
    from_port       = 6443
    to_port         = 6443
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  # Rule 4: Allow Nodes to talk to each other (Vital for K3s)
  ingress {
    description = "Intra-cluster communication"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # Allow nodes to go to Internet via NAT (updates, docker pull)
  egress {
    description = "Allow all outbound (via NAT)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}