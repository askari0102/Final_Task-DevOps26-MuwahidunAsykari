# Container Registry

## Registry Configuration**

The private Docker Registry is deployed as a container on the monitoring server using Ansible. It runs on port `5000`.
<img width="1484" height="372" alt="image" src="https://github.com/user-attachments/assets/9f9d8f05-16a0-420f-b518-e01eff13c66b" />

<img width="1480" height="818" alt="image" src="https://github.com/user-attachments/assets/bafb3b46-ebe5-4e08-ad56-221e183f366c" />

## Deployment and Verification

**1. Run the Ansible playbook to deploy the registry**
```
ansible-playbook setup-registry.yml
```
<img width="1482" height="457" alt="image" src="https://github.com/user-attachments/assets/dcf1e851-c914-4faf-a0e0-6c397ec45726" />

**2. SSH into the monitoring server**
```
ssh monitoring
```
<img width="1487" height="290" alt="image" src="https://github.com/user-attachments/assets/fc3824a9-0255-4f0f-8a52-11fbffdd9eb4" />

**3. Verify the registry container is up and running**
```
docker ps
```
<img width="1471" height="157" alt="image" src="https://github.com/user-attachments/assets/f0c6a79f-3774-486e-9aaa-60a52eb41e3d" />


# WAIT FOR CICD STEP BEFORE PUSHING AND WEB SERVER STEP BEFORE REVERSE PROXY
