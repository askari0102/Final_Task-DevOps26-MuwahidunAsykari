# Monitoring

## Monitoring & Alerting

### 1. Setup & Deployment via Ansible
Deploy Prometheus and Grafana using Ansible.
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

* Click **+** > **New Dashboard** > **Add Panel** > **Configure Visualization**.
<img width="1919" height="193" alt="image" src="https://github.com/user-attachments/assets/64ae6a6d-eac7-44eb-8faa-6fcf377d45d7" />
<img width="1919" height="885" alt="image" src="https://github.com/user-attachments/assets/b085090e-deff-4361-aff0-b99429340165" />
<img width="1919" height="643" alt="image" src="https://github.com/user-attachments/assets/67900cfc-056c-4eee-a151-75ef23fcd462" />

* Select **Prometheus** as the source, switch to **Code**, paste the PromQL query, and click **Run query**.
<img width="1919" height="908" alt="image" src="https://github.com/user-attachments/assets/fa6f5a4b-4a7a-466a-bf7a-7e1849524aac" />

### 5. Visualization & Refinement
After running the queries, refine the panels to make the dashboard readable and informative.

* **Select Visualization:** Choose appropriate types such as Time Series (for Network I/O), Gauge, or Bar Gauge (for CPU/RAM/Storage).

<img width="409" height="769" alt="image" src="https://github.com/user-attachments/assets/bd93a50a-f85e-416b-ac31-85a28ddb8305" />

* **Standard Options:**
  - Set the **Unit** according to the queried metric (e.g., Percent (0-100) for CPU/RAM, Gigabytes for Storage, Bytes/sec for Network).
  - Define **Min/Max** values to reflect actual hardware capacity (e.g., Max: 100 for percentage metrics).
  <img width="408" height="357" alt="image" src="https://github.com/user-attachments/assets/c00873ae-c9ec-4192-a774-a06bddf6809e" />

* **Thresholds:** Configure color-coded indicators (e.g., Green, Yellow, Red) based on the threshold rules to provide quick visual alerts.
<img width="403" height="259" alt="image" src="https://github.com/user-attachments/assets/b21009d1-d2b1-496d-90ac-bd441495a30c" />


