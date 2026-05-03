# 1. Generate RSA Key
resource "tls_private_key" "finaltask_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 2. Register Public Key to AWS Key Pair
resource "aws_key_pair" "finaltask_key" {
  key_name   = "finaltask-key"
  public_key = tls_private_key.finaltask_key.public_key_openssh
}

# 3. Save Private Key to Local Machine
resource "local_file" "private_key" {
  filename        = pathexpand("~/.ssh/finaltask-key.pem")
  content         = tls_private_key.finaltask_key.private_key_pem
  file_permission = "0400"
}

# 4. Automatically generate SSH config for easier access
resource "local_file" "ssh_config" {
  filename        = pathexpand("~/.ssh/config") # Replaces the config file if it already exists
  file_permission = "0600"
  content         = <<-EOT
    # Gateway (Direct Access via Public IP)
    Host gateway
      HostName ${aws_eip.gateway_eip.public_ip}
      User finaltask-Asykari
      Port 6969
      IdentityFile ~/.ssh/finaltask-key.pem
      StrictHostKeyChecking no

    # Private Servers (Access through Gateway)
    Host staging
      HostName ${aws_instance.staging.private_ip}
      User finaltask-Asykari
      Port 6969
      IdentityFile ~/.ssh/finaltask-key.pem
      ProxyJump gateway
      StrictHostKeyChecking no

    Host prod-master
      HostName ${aws_instance.master.private_ip}
      User finaltask-Asykari
      Port 6969
      IdentityFile ~/.ssh/finaltask-key.pem
      ProxyJump gateway
      StrictHostKeyChecking no

    Host prod-worker
      HostName ${aws_instance.worker.private_ip}
      User finaltask-Asykari
      Port 6969
      IdentityFile ~/.ssh/finaltask-key.pem
      ProxyJump gateway
      StrictHostKeyChecking no

    Host cicd
      HostName ${aws_instance.cicd.private_ip}
      User finaltask-Asykari
      Port 6969
      IdentityFile ~/.ssh/finaltask-key.pem
      ProxyJump gateway
      StrictHostKeyChecking no

    Host monitoring
      HostName ${aws_instance.monitoring.private_ip}
      User finaltask-Asykari
      Port 6969
      IdentityFile ~/.ssh/finaltask-key.pem
      ProxyJump gateway
      StrictHostKeyChecking no
  EOT
}
