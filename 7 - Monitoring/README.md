# Monitoring

## Monitoring & Alerting

### 1. Setup & Deployment via Ansible
Deploy Prometheus and Grafana seamlessly using Ansible.
```
ansible-playbook setup-monitoring.yml
```
<img width="1481" height="490" alt="image" src="https://github.com/user-attachments/assets/e191b3b1-5955-480f-9981-041fad6f0ed7" />

### 2. Prometheus Basic Auth
Secure the Prometheus dashboard by enabling Basic Authentication at the Nginx on Gateway server.
<img width="1461" height="526" alt="image" src="https://github.com/user-attachments/assets/51afd95d-223b-4822-9909-d6232201228e" />

---
<img width="1459" height="214" alt="image" src="https://github.com/user-attachments/assets/f8de8391-3226-424b-b858-17cc5bc677fe" />

---
<img width="1919" height="626" alt="image" src="https://github.com/user-attachments/assets/ab64ffc6-8c2a-45f3-80f8-bd52aeb012a8" />

---
<img width="1919" height="1016" alt="image" src="https://github.com/user-attachments/assets/8c5f25e2-a2e9-4cdd-b0a0-e236640080b0" />

### 3. Connecting Prometheus to Grafana

* Open the Grafana Dashboard in browser.
<img width="1919" height="1018" alt="image" src="https://github.com/user-attachments/assets/5b35a81e-1ce2-49fa-afc9-d2d4dec14a6e" />

* Go to **Connections** > **Data Sources** > **Add data source** and select **Prometheus**.
<img width="1919" height="1021" alt="image" src="https://github.com/user-attachments/assets/143cb86d-d1bd-4148-b449-771977c06f59" />
<img width="1919" height="1007" alt="image" src="https://github.com/user-attachments/assets/76dd8315-3d55-45a4-8f02-77627d25753e" />

* Set the URL to the internal Docker service: http://prometheus:9090
<img width="1919" height="1017" alt="image" src="https://github.com/user-attachments/assets/a27d1a9a-17ce-48a7-b263-39d31ccf78e1" />

* Click Save & Test.
<img width="1919" height="421" alt="image" src="https://github.com/user-attachments/assets/f502c842-4f61-491f-bbf4-c4baa6195367" />
<img width="1915" height="187" alt="image" src="https://github.com/user-attachments/assets/a00ec350-6b8e-4e35-abf3-b6c448439867" />
<img width="1919" height="505" alt="image" src="https://github.com/user-attachments/assets/16477a33-6705-4862-94ec-9206de777745" />

### **4. Create & Configure Panel (VM & Containers)**








