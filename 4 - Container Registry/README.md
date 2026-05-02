# Container Registry

## Registry Configuration

The private Docker Registry is deployed as a container on the monitoring server using Ansible. It runs on port `5000`.
<img width="1484" height="372" alt="image" src="https://github.com/user-attachments/assets/9f9d8f05-16a0-420f-b518-e01eff13c66b" />

<img width="1480" height="818" alt="image" src="https://github.com/user-attachments/assets/bafb3b46-ebe5-4e08-ad56-221e183f366c" />

## Deployment and Verification

### **1. Run the Ansible playbook to deploy the registry**
```
ansible-playbook setup-registry.yml
```
<img width="1482" height="457" alt="image" src="https://github.com/user-attachments/assets/dcf1e851-c914-4faf-a0e0-6c397ec45726" />

### **2. SSH into the monitoring server**
```
ssh monitoring
```
<img width="1487" height="290" alt="image" src="https://github.com/user-attachments/assets/fc3824a9-0255-4f0f-8a52-11fbffdd9eb4" />

### **3. Verify the registry container is up and running**
```
docker ps
```
<img width="1471" height="157" alt="image" src="https://github.com/user-attachments/assets/f0c6a79f-3774-486e-9aaa-60a52eb41e3d" />


### 4. Reverse Proxy Configuration
The reverse proxy is configured automatically with the Gateway Ansible playbook
<img width="1449" height="706" alt="image" src="https://github.com/user-attachments/assets/fd185e69-c2aa-4c7f-98b0-9a4e43226289" />

### 5. Automated Image Push
Images are built and pushed automatically to this private registry via the Build Stage in GitLab CI/CD pipeline.
<img width="1919" height="867" alt="image" src="https://github.com/user-attachments/assets/6c68e15b-ecc1-4d66-a07c-33318c88dc6f" />

### 6. Verification
To verify that the reverse proxy is working and the images have been pushed successfully, access the registry catalog endpoint directly in the web browser. [https://registry.asykari.studentdumbways.my.id/v2/_catalog](https://registry.asykari.studentdumbways.my.id/v2/_catalog)

<img width="1919" height="436" alt="image" src="https://github.com/user-attachments/assets/0c95d617-24ea-433c-8d97-40c51d3604fc" />
<img width="1919" height="198" alt="image" src="https://github.com/user-attachments/assets/a03a5434-966c-421c-b59a-6a25af6950c7" />

