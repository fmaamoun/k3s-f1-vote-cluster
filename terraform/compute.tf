# =============================================================================
# 4. INSTANCES (EC2)
# =============================================================================

# Key Pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "generated_key" {
  key_name   = "k3s-f1-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}
resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/k3s-f1-key.pem"
  file_permission = "0600"
}

# AMI Image
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# --- BASTION HOST (Public) ---
resource "aws_instance" "bastion" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro" 
  key_name      = aws_key_pair.generated_key.key_name
  subnet_id     = aws_subnet.public_1.id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = { Name = "k3s-bastion" }
}

# --- MASTER (Private) ---
resource "aws_instance" "master" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  key_name      = aws_key_pair.generated_key.key_name
  subnet_id     = aws_subnet.private.id # Private Subnet
  vpc_security_group_ids = [aws_security_group.k3s_internal_sg.id]

  tags = { Name = "k3s-master", Role = "control-plane" }
}

# --- WORKERS (Private) ---
resource "aws_instance" "workers" {
  count         = 2
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.generated_key.key_name
  subnet_id     = aws_subnet.private.id # Private Subnet
  vpc_security_group_ids = [aws_security_group.k3s_internal_sg.id]

  tags = { Name = "k3s-worker-${count.index + 1}", Role = "worker" }
}

# Connect Workers to ALB
resource "aws_lb_target_group_attachment" "workers_attachment" {
  count            = 2
  target_group_arn = aws_lb_target_group.f1_tg.arn
  target_id        = aws_instance.workers[count.index].id
  port             = 80
}