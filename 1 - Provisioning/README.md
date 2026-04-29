# **Provisioning**

## Creating Infrastructure with Terraform

**1. Environment Setup**

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

* Create IAM user by going to AWS Management Cons*ole → IAM Dashboard → IAM Users → Create user.
Create a dedicated IAM user to avoid using the Root Account
<img width="1919" height="634" alt="Screenshot 2026-04-28 091751" src="https://github.com/user-attachments/assets/ff25da0c-a8c8-45eb-8128-e7063bf197b5" />
<img width="1919" height="799" alt="image" src="https://github.com/user-attachments/assets/d33128c6-76a2-4fe0-9c08-74c526abe225" />
<img width="1919" height="804" alt="image" src="https://github.com/user-attachments/assets/ce8d7506-b44a-4a37-8a73-07bef0489316" />
<img width="1919" height="248" alt="image" src="https://github.com/user-attachments/assets/b41c10ca-2463-455b-9a7d-0dc8bf337be0" />

* Create AWS Console → IAM Dashboard → Users → [Select your User] → Security credentials → Access keys → Create access key.
Generate a new Access Key specifically for the created IAM User.
<img width="1919" height="519" alt="image" src="https://github.com/user-attachments/assets/f4eceda6-f296-49fa-9065-4ab4a48b7edb" />
<img width="1919" height="803" alt="image" src="https://github.com/user-attachments/assets/eaad188c-2131-4fc6-b0d0-f187f75ca91c" />
<img width="1919" height="465" alt="image" src="https://github.com/user-attachments/assets/1616f0a4-9bd1-464a-95ec-d81e74a0e873" />
<img width="1919" height="804" alt="image" src="https://github.com/user-attachments/assets/8b9bae11-4ba0-44f5-be68-43c1e964949e" />
<img width="1919" height="375" alt="image" src="https://github.com/user-attachments/assets/4ba2b8c4-2f99-4a5b-a2fb-7a3d5c0a0c75" />

* Setup credentials by running `aws configure`
```
AWS Access Key ID: (Enter your Access Key ID)
AWS Secret Access Key: (Enter your Secret Access Key)
Default region name: ap-southeast-1 (or your preferred region)
Default output format: json (or just press enter)
```
<img width="1860" height="120" alt="image" src="https://github.com/user-attachments/assets/b1289f01-5f84-4b61-8e9f-bae7deec6bce" />

* Verify credentials by running `aws sts get-caller-identity`
<img width="1853" height="140" alt="image" src="https://github.com/user-attachments/assets/98d83e59-8eaa-4138-93dc-ff68e30542b6" />

**2. Infrastructure Provisioning**

* Build the infrastructure using Terraform to provision six Ubuntu 22.04 LTS instances on AWS. The architecture is designed with security in mind, utilizing a Public Subnet for the entry point and a Private Subnet for application and internal workflows.

* Server List & Roles:
  - Gateway Server: Single entry point and Nginx Reverse Proxy managing external HTTP/HTTPS traffic and automatic SSL
  - Staging Server: Testing environment for validating application updates securely before production release.
  - Production - Master: The K3s Control Plane managing the Kubernetes cluster within the isolated private network.
  - Production - Worker: The K3s compute node running the live production application pods.
  - CI/CD - GitLab Runner: Automation server hosting the self-managed GitLab Runner for pipelines (build, test, push, deploy).
  - Monitoring & Registry Server: Hosts Prometheus/Grafana for system monitoring and a Private Docker Registry for image storage.

* Create a new directory for Terraform in your local computer, the structures will be as follow:
<pre>
Terraform/
├── <a href="./Terraform/provider.tf"><b>provider.tf</b></a>            # AWS Provider configuration
├── <a href="./Terraform/vpc.tf"><b>vpc.tf</b></a>                 # VPC, Subnets, Internet Gateway, and NAT Gateway configuration
├── <a href="./Terraform/sg.tf"><b>sg.tf</b></a>                  # Security Group rules for Gateway and Private servers
├── <a href="./Terraform/ssh.tf"><b>ssh.tf</b></a>                 # Automated SSH Key generation and SSH config creation
├── <a href="./Terraform/ec2.tf"><b>ec2.tf</b></a>                 # EC2 Instances provisioning
├── <a href="./Terraform/ansible-inventory.tf"><b>ansible-inventory.tf</b></a>   # Automated inventory for Ansible with custom SSH port and ProxyJump configuration for Private Subnet access
└── <a href="./Terraform/outputs.tf"><b>outputs.tf</b></a>             # # IP & Private Key (only visible when called) outputs
</pre>
<img width="1484" height="51" alt="image" src="https://github.com/user-attachments/assets/646945af-4b65-47e7-a4f5-8537a75f9602" />

**3. Deploying the Infrastructure**

* Initialize Terraform and download providers `terraform init`
<img width="1398" height="574" alt="Screenshot 2026-04-28 004901" src="https://github.com/user-attachments/assets/c2d91bb2-3f87-49ea-8ab1-455837c6657a" />

* Format Terraform configuration files to a canonical format and style `terraform fmt`
<img width="1420" height="91" alt="image" src="https://github.com/user-attachments/assets/f19d911a-13bf-4c77-bc68-0fff6cbbb95f" />

* Validate the configuration files to ensure they are syntactically valid and internally consistent `terraform validate`
<img width="1425" height="68" alt="image" src="https://github.com/user-attachments/assets/8edaf942-7a4d-4fb1-87d7-775964b8bb2e" />

* Review and save the execution plan `terraform plan -out=tfplan`
<img width="1485" height="428" alt="image" src="https://github.com/user-attachments/assets/0c8ed369-d6bd-4c57-adad-86fbc2dd11ba" />

* Deploy the infrastructure from the saved plan `terraform apply "tfplan"`
<img width="1483" height="425" alt="image" src="https://github.com/user-attachments/assets/a3fe9aca-20ec-433f-bbed-10e9d7f7c2f8" />


## Creating Infrastructure with Terraform

**1. Ansible Installation**

* Install pipx
```
sudo apt update
sudo apt install pipx
pipx ensurepath
```
<img width="1482" height="702" alt="image" src="https://github.com/user-attachments/assets/d6a551d0-8c03-4e23-ac73-f4b9ba813f76" />

* Install the full Ansible package using pipx
```
pipx install --include-deps ansible # Run this if you want to install the full Ansible package
pipx install ansible-core           # Run this if you want the minimal ansible-core package
```
<img width="1477" height="356" alt="image" src="https://github.com/user-attachments/assets/edb6c629-dc0c-4447-a21a-eb1c758a5d0e" />

* Verify with `ansible --version`
<img width="1483" height="224" alt="image" src="https://github.com/user-attachments/assets/b23b106b-ed2e-4eda-b054-d69f74b01ab8" />

**2. Project Structure**

* Create a new directory for Ansible in your local computer, the structures will be as follow:
<pre>
ansible/
├── <a href="./ansible/ansible.cfg"><b>ansible.cfg</b></a>                        # Ansible configuration settings
├── <a href="./ansible/inventory"><b>inventory</b></a>                          # Auto-generated from Terraform
├── <a href="./ansible/01-setup-servers.yml"><b>01-setup-servers.yml</b></a>               # Task 3: User creation, UFW, SSH hardening
├── <a href="./ansible/02-gateway.yml"><b>02-gateway.yml</b></a>                     # Task 8: Nginx native, Certbot, SSL wildcard
├── <a href="./ansible/03-docker.yml"><b>03-docker.yml</b></a>                      # Task 5: Docker installation + PostgreSQL staging
├── <a href="./ansible/04-monitoring.yml"><b>04-monitoring.yml</b></a>                  # Task 7: Prometheus, Grafana, Node Exporter
├── <a href="./ansible/04-registry.yml"><b>04-registry.yml</b></a>                    # Task 4: Docker Registry private
├── <a href="./ansible/05-cicd.yml"><b>05-cicd.yml</b></a>                        # Task 6: GitLab Runner, SonarQube
├── <a href="./ansible/06-k3s.yml"><b>06-k3s.yml</b></a>                         # Task 9: k3s cluster, Nginx Ingress, PostgreSQL
├── 📂 <b>group_vars/</b>
│   └── <a href="./ansible/group_vars/all"><b>all</b></a>                            # Global variables and credentials
├── 📂 <b>templates/</b>
│   ├── <a href="./ansible/templates/nginx-gateway.j2"><b>nginx-gateway.j2</b></a>               # Nginx reverse proxy config
│   ├── <a href="./ansible/templates/prometheus.j2"><b>prometheus.j2</b></a>                  # Prometheus scrape config
│   ├── <a href="./ansible/templates/docker-compose-monitoring.j2"><b>docker-compose-monitoring.j2</b></a>   # Monitoring stack
│   ├── <a href="./ansible/templates/docker-compose-registry.j2"><b>docker-compose-registry.j2</b></a>     # Docker Registry
│   └── <a href="./ansible/templates/docker-compose-staging-db.j2"><b>docker-compose-staging-db.j2</b></a>   # PostgreSQL staging
└── <a href="./ansible/.vault_pass"><b>.vault_pass</b></a>                        # Ansible Vault password file 
</pre>

**3. Encrypting content with Ansible Vault**
Ansible Vault is a built-in Ansible feature for encrypting sensitive data such as passwords and credentials directly inside your variable files, so they are safe to store in a repository.

* Create a vault password file and secure it
```
echo "your-vault-password" > .vault_pass
chmod 600 .vault_pass
echo ".vault_pass" >> .gitignore
```
<img width="1477" height="102" alt="image" src="https://github.com/user-attachments/assets/b2a80f24-9646-4bbd-9955-0d8308fc8a3c" />


* Add `vault_password_file = .vault_pass` to `ansible.cfg` under `[defaults]`
<img width="1123" height="132" alt="image" src="https://github.com/user-attachments/assets/0a3585d2-c28a-49b4-8b1e-eb10d0a6f85b" />

* Encrypt sensitive credentials and paste the output into group_vars/all
```
ansible-vault encrypt_string '<password>' --name '<variable_name>' 
```
<img width="1490" height="207" alt="image" src="https://github.com/user-attachments/assets/d5060550-9c55-4a82-8908-58a781e24101" />
<img width="1474" height="250" alt="image" src="https://github.com/user-attachments/assets/aaf8b8f0-8839-44d5-b7bd-52adb554049f" />
<img width="1483" height="205" alt="image" src="https://github.com/user-attachments/assets/2609d74f-bf9f-4d71-9116-151a3b62fc2d" />
<img width="1491" height="199" alt="image" src="https://github.com/user-attachments/assets/f88086d2-bb3e-436c-9814-02636ccf665c" />
<img width="1484" height="477" alt="image" src="https://github.com/user-attachments/assets/fccd1290-fe2d-4b31-98d4-419f6b7d7639" />
<img width="1481" height="197" alt="image" src="https://github.com/user-attachments/assets/9b64653b-75bd-4fc1-b6f9-d1bb6faa3d47" />
<img width="1483" height="472" alt="image" src="https://github.com/user-attachments/assets/22e2fa78-8ac1-4c51-a88e-8a0388319d6a" />

* Too view the encrypted content use the following command:
```
ansible localhost -m debug -e "@group_vars/all" -a "var=<variable_name_in_all>"
```
<img width="1471" height="91" alt="image" src="https://github.com/user-attachments/assets/7cc6b9ee-1aa1-4660-8c19-0adde37a14f2" />
