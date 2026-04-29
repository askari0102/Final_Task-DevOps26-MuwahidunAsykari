# 1. GATEWAY (Publik & Private)
output "gateway_public_ip" {
  value       = aws_eip.gateway_eip.public_ip
  description = "Pintu masuk utama (Akses web dan Bastion Host SSH)"
}

output "gateway_private_ip" {
  value = aws_instance.gateway.private_ip
}

# 2. Private Servers (Hanya Private)
output "staging_private_ip" {
  value = aws_instance.staging.private_ip
}

output "master_private_ip" {
  value = aws_instance.master.private_ip
}

output "worker_private_ip" {
  value = aws_instance.worker.private_ip
}

output "cicd_private_ip" {
  value = aws_instance.cicd.private_ip
}

output "monitoring_private_ip" {
  value = aws_instance.monitoring.private_ip
}

# 3. SSH Key (Untuk Backup dan CI/CD)
output "private_key" {
  value       = tls_private_key.finaltask_key.private_key_pem
  sensitive   = true # Ga keluar di terminal isinya
  description = "Liat pake 'terraform output -raw private_key'"
}