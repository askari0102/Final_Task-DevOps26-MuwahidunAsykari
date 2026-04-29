resource "local_file" "ansible_inventory" {
  content = <<EOT
[gateway]
gateway_server ansible_host=${aws_eip.gateway_eip.public_ip} gateway_private_ip=${aws_instance.gateway.private_ip}

[staging]
staging_server ansible_host=${aws_instance.staging.private_ip}

[k3s_master]
master_server ansible_host=${aws_instance.master.private_ip}

[k3s_worker]
worker_server ansible_host=${aws_instance.worker.private_ip}

[cicd]
cicd_server ansible_host=${aws_instance.cicd.private_ip}

[monitoring]
monitoring_server ansible_host=${aws_instance.monitoring.private_ip}

# Grouping: Define all private subnet servers
[private:children]
staging
k3s_master
k3s_worker
cicd
monitoring

# Global Variables (Applied to ALL servers)
[all:vars]
ansible_user=ubuntu
ansible_port=6969
ansible_ssh_private_key_file=~/.ssh/finaltask-key.pem

# Gateway Variables (Direct Connection)
[gateway:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no'

# Private Variables (Routed via Gateway)
[private:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o ProxyCommand="ssh -W %h:%p -q ubuntu@${aws_eip.gateway_eip.public_ip} -p 6969 -i ~/.ssh/finaltask-key.pem -o StrictHostKeyChecking=no"'
EOT

  filename = "${path.module}/../ansible/inventory"
}