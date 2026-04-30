# Servers

## Server Requirements

**1. Rebuilding Servers**

The infrastructure can be destroyed using `terraform destroy` and recreated using the same Infrastructure Deployment commands as in [Provisioning](https://github.com/askari0102/FinalTask-DevOps26-MuwahidunAsykari/blob/main/1%20-%20Provisioning/README.md) to achieve an identical state.**

* Destroy the infrastructures with ``terraform destroy``
<img width="1481" height="336" alt="image" src="https://github.com/user-attachments/assets/0e79a9f3-74ff-4e84-a9d3-169d35397108" />
<img width="1484" height="379" alt="image" src="https://github.com/user-attachments/assets/839f11df-f06e-4add-a5d1-2d3e7908bd3e" />
<img width="1468" height="435" alt="image" src="https://github.com/user-attachments/assets/b0b0a796-e633-4cac-9ea5-62acd8598d82" />

* Deploy again with `terraform plan` and `terraform apply`
<img width="1479" height="314" alt="image" src="https://github.com/user-attachments/assets/a527952f-fbb1-4680-b57d-6bdee444326f" />
<img width="1477" height="200" alt="image" src="https://github.com/user-attachments/assets/eca0d6db-dfb8-4154-b603-758e7d603d76" />
<img width="1482" height="310" alt="image" src="https://github.com/user-attachments/assets/bad17d80-f56e-4b7f-8d27-b9d51ca76893" />

**2. Operating System (OS) Base**

All servers are provisioned using **Ubuntu 22.04 LTS**.
<img width="1464" height="340" alt="image" src="https://github.com/user-attachments/assets/6ec06d37-da82-43ab-b98c-0285729b5741" />
<img width="1462" height="73" alt="image" src="https://github.com/user-attachments/assets/81724538-f420-429f-962d-431ee50bb313" />

**3. Changing SSH Port**

During the provisioning phase, the default SSH port is automatically modified from 22 to 6969. This is achieved using Terraform's `user_data` script, which executes upon the first boot of every instance
<img width="738" height="461" alt="image" src="https://github.com/user-attachments/assets/4a1fdf34-bffc-48ad-bc45-e722fec614cb" />

**4. SSH Key & SSH Config**

Terraform automatically generates a single RSA key pair (finaltask-key.pem) and injects it into all instances.
<img width="1478" height="456" alt="image" src="https://github.com/user-attachments/assets/86a21718-2bb1-4228-8e45-e0959cca2720" />
<img width="1455" height="36" alt="image" src="https://github.com/user-attachments/assets/b794f2eb-b2fb-4ed2-a51e-6b3bd4724612" />

Terraform also automatically an SSH config file (~/.ssh/config) configured with a ProxyJump to route private network traffic through the Gateway.
<img width="1467" height="468" alt="image" src="https://github.com/user-attachments/assets/36574f6e-0a0f-4e77-9a00-3eb607e48619" />
<img width="1919" height="769" alt="image" src="https://github.com/user-attachments/assets/9b3ba061-677d-4c9c-a73f-c8b0d7754a76" />

**5. Creating New User**

Ansible automatically creates a new user `finaltask-Asykari` for all servers. The new user uses the same ssh key as root.
<img width="1478" height="247" alt="image" src="https://github.com/user-attachments/assets/1e8908d9-df96-4220-98fe-44bb4d46f80b" />
<img width="1475" height="674" alt="image" src="https://github.com/user-attachments/assets/a447d0b0-45f7-446d-a691-59609411bd44" />

**6. UFW Firewall Configuration**
UFW is enabled on all servers. Ansible automatically opens only the ports needed for each server's role:
  * Universal Rule (All Servers):
    - Port `6969` (SSH)
    - Port `9100` (Node Exporter for Monitoring)
  * Role-Specific Rules:
    - Gateway: `80`, `443` (HTTP/HTTPS)
    - Staging: `80`, `5000` (App), `5432` (PostgreSQL), `8080` (cAdvisor)
    - Monitoring: `9090` (Prometheus), `3000` (Grafana), `5000` (Registry), `8080` (cAdvisor)
    - CI/CD: `9000` (SonarQube), `8080` (cAdvisor)
    - K3s Master & Worker: Specific Kubernetes ports (`6443`, `8472`, `10250`, App ports)

<img width="1467" height="649" alt="image" src="https://github.com/user-attachments/assets/f39c23b7-b9bc-4608-b7dc-5288f132b8e6" />
<img width="1479" height="464" alt="image" src="https://github.com/user-attachments/assets/99b5c611-10de-44d9-b84e-a5de44b89368" />

## Execution & Verification 

**1. Execute the Ansible Playbook**

Run the setup-servers.yml playbook to configure the users, SSH keys, and firewall rules across all servers.
```
ansible-playbook setup-servers.yml
```
<img width="1492" height="907" alt="image" src="https://github.com/user-attachments/assets/7afaddf1-cc57-4215-8bd3-6bbae786a3f5" />
<img width="1480" height="189" alt="image" src="https://github.com/user-attachments/assets/88a0bc8e-2611-45f4-98e0-76fd55fe44a5" />

**2. Verify SSH Config & Login**

Test the SSH configuration by connecting directly to a private server from your local machine.
`ssh staging`
<img width="1478" height="301" alt="image" src="https://github.com/user-attachments/assets/bcf931f5-2e08-4dcc-b0a2-ea190338f0cc" />

**3. Verify UFW Rules**

Once logged into the server, verify that UFW is active and only the allowed ports are open.
`sudo ufw status`
<img width="1473" height="390" alt="image" src="https://github.com/user-attachments/assets/bdabccc5-1a2f-489e-8aa2-7ec4af9faef7" />
