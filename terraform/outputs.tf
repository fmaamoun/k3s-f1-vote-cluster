# =============================================================================
# 5. OUTPUTS
# =============================================================================

output "bastion_ip" {
  description = "Public IP of the Bastion Host"
  value       = aws_instance.bastion.public_ip
}

output "load_balancer_dns" {
  description = "The URL of your site (AWS ALB)"
  value       = aws_lb.f1_alb.dns_name
}

output "master_private_ip" {
  description = "Private IP of Master (Hidden)"
  value       = aws_instance.master.private_ip
}

output "worker_private_ips" {
  description = "Private IPs of Workers"
  value       = aws_instance.workers[*].private_ip
}

output "ssh_proxy_command" {
  description = "Command to SSH into Master via Bastion"
  value       = "ssh -i k3s-f1-key.pem -o ProxyCommand='ssh -i k3s-f1-key.pem -W %h:%p ubuntu@${aws_instance.bastion.public_ip}' ubuntu@${aws_instance.master.private_ip}"
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.tpl", {
    bastion_ip = aws_instance.bastion.public_ip
    master_ip  = aws_instance.master.private_ip
    worker_ips = aws_instance.workers[*].private_ip
  })
  filename = "../ansible/inventory.ini"
}