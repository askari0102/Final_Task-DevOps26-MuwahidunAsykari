# **Provisioning**

## Creating Infrastructure with Terraform

**1. Terraform Setup**

* Install Terraform in your local computer
```
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt-get install terraform
```
<img width="1860" height="905" alt="image" src="https://github.com/user-attachments/assets/a5a41c03-659b-41fa-9149-21d8ca3eabc8" />
<img width="1863" height="841" alt="image" src="https://github.com/user-attachments/assets/d095a1d4-cc59-43d9-8369-c3cd65e624fd" />

* Verify with `terraform -v`
<img width="1863" height="78" alt="image" src="https://github.com/user-attachments/assets/8a138772-ef34-47ef-9314-6ef7f2ca4e3a" />

* Install AWS CLI
```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```
<img width="1860" height="200" alt="image" src="https://github.com/user-attachments/assets/95e4317c-3f42-4f22-910b-f42ffea3bd6e" />
<img width="1862" height="203" alt="image" src="https://github.com/user-attachments/assets/6c2033b1-b6da-49d5-9277-f1313ef9a770" />

* Verify with `aws --v`
<img width="1858" height="61" alt="image" src="https://github.com/user-attachments/assets/2a41d777-fdb7-4d5f-a16e-cbbca298255f" />


**2. Infrastructure Provisioning**

* Build the infrastructure using Terraform to provision six Ubuntu 22.04 LTS instances on AWS. The architecture is designed with security in mind, utilizing a Public Subnet for the entry point and a Private Subnet for application and internal workflows.

* Server List & Roles:
  - Gateway Server: Single entry point and Nginx Reverse Proxy managing external HTTP/HTTPS traffic and automatic SSL
  - Staging Server: Testing environment for validating application updates securely before production release.
  - Production - Master: The K3s Control Plane managing the Kubernetes cluster within the isolated private network.
  - Production - Worker: The K3s compute node running the live production application pods.
  - CI/CD - GitLab Runner: Automation server hosting the self-managed GitLab Runner for pipelines (build, test, push, deploy).
  - Monitoring & Registry Server: Hosts Prometheus/Grafana for system monitoring and a Private Docker Registry for image storage.

* Terraform Directory Structures:
<pre>
Terraform/
├── <a href="./Terraform/provider.tf"><b>provider.tf</b></a>            # AWS Provider configuration
├── <a href="./Terraform/vpc.tf"><b>vpc.tf</b></a>                 # Public & Private VPC, Subnet, IGW, and Routing
├── <a href="./Terraform/sg.tf"><b>sg.tf</b></a>                  # Security Group rules 
├── <a href="./Terraform/ssh.tf"><b>ssh.tf</b></a>                 # Automated SSH Key Pair generation and SSH config automation
├── <a href="./Terraform/ec2.tf"><b>ec2.tf</b></a>                 # EC2 Instances
├── <a href="./Terraform/ansible-inventory.tf"><b>ansible-inventory.tf</b></a>   # Automated inventory for Ansible with custom SSH port and ProxyJump configuration for Private Subnet access
└── <a href="./Terraform/outputs.tf"><b>outputs.tf</b></a>             # # IP & Private Key (only visible when called) outputs
</pre>
