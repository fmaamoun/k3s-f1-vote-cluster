[master]
${master_ip}

[workers]
%{ for ip in worker_ips ~}
${ip}
%{ endfor ~}

[k3s_cluster:children]
master
workers

[k3s_cluster:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=../terraform/k3s-f1-key.pem
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ../terraform/k3s-f1-key.pem -W %h:%p ubuntu@${bastion_ip}"'