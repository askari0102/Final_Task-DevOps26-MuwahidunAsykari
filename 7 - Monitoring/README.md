# Monitoring

## Infrastructure Monitoring 

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

* **VM Resources Queries (Node Exporter)**

| Metric                | PromQL Query                                                                                                    | Unit          | Threshold |
|-----------------------|-----------------------------------------------------------------------------------------------------------------|---------------|-----------|
| CPU Usage             | 100 - (avg by (alias) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)                                   | Percent (%)   | > 80%     |
| RAM Usage (%)         | (1 - (avg by (alias)(node_memory_MemAvailable_bytes) / avg by (alias)(node_memory_MemTotal_bytes))) * 100       | Percent (%)   | > 80%     |
| RAM Usage (GB)        | avg by (alias) (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / 1024 / 1024                      | Megabytes     | -         |
| Disk Usage            | avg by (alias) (node_filesystem_size_bytes{mountpoint="/"} - node_filesystem_avail_bytes{mountpoint="/"}) / 1024 / 1024 / 1024 | Gigabytes     | -         |
| VM Network (Receive)  | avg by (alias) (irate(node_network_receive_bytes_total{device!~"lo&#124;veth.*&#124;br.*"}[5m]))                          | Bytes/sec(IEC) | - |
| VM Network (Transmit) | avg by (alias) (irate(node_network_transmit_bytes_total{device!~"lo&#124;veth.*&#124;br.*"}[5m]))                         | Bytes/sec(IEC) | - |

* **Container Resources Queries (cAdvisor)**
  
| Metric            | PromQL Query                                                                  | Unit        | Threshold |
|-------------------|-------------------------------------------------------------------------------|-------------|-----------|
| Container Status     | label_replace(time() - container_last_seen{image!="", name!~"cadvisor"}, "host", "$1", "alias", "cAdvisor-(.*)") | Seconds | > 15 (Down)         |
| Container CPU     | sum by (name, host) (label_replace(rate(container_cpu_usage_seconds_total{image!="", name!~"cadvisor"}[5m]), "host", "$1", "alias", "cAdvisor-(.*)")) * 100  | Percent (%) | -         |
| Container RAM | sum by (name, host) (label_replace(container_memory_working_set_bytes{image!="", name!~"cadvisor"}, "host", "$1", "alias", "cAdvisor-(.*)"))          | Percent (%)  | - |

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

### 6. Final Dashboard View
Once all panels for VM and Container resources are configured and organized, the dashboard provides a centralized view of the entire infrastructure health.
* Set as Home Dashboard
  - Go to **Profile** > **Preferences**.
  - Select your dashboard in the Home Dashboard dropdown.
  - Click **Save Preferences**.
  - Auto-Refresh: Set to 5s (top right).
<img width="1919" height="858" alt="image" src="https://github.com/user-attachments/assets/0e1d88c0-d36b-4f2d-be9d-0db2060fc1c2" />

---
<img width="1919" height="960" alt="image" src="https://github.com/user-attachments/assets/982ad3c5-47df-4167-9c86-f6f2c984f806" />
<img width="1919" height="381" alt="image" src="https://github.com/user-attachments/assets/d57c2884-0c62-468e-a145-fb8359b31c7a" />
<img width="1919" height="522" alt="image" src="https://github.com/user-attachments/assets/ce2dd62b-4793-4399-819e-76d2440d7a54" />

## Alerting via Telegram

### 1. Create Telegram Bot
* Open Telegram and search for @BotFather.
<img width="1918" height="910" alt="image" src="https://github.com/user-attachments/assets/35681a43-98dd-429d-a2ec-38623cc090a1" />

* Send /newbot, choose a name and username for the bot. Save the HTTP API Token generated by BotFather.
<img width="1919" height="912" alt="image" src="https://github.com/user-attachments/assets/cf3626a1-aa60-4d3e-93a9-b009e0eaab7a" />

* Start a conversation with your new bot and send a dummy message.
<img width="1393" height="893" alt="image" src="https://github.com/user-attachments/assets/04be2c41-2f6d-4a07-9608-0db9054e80f0" />

* Retrieve your Chat ID by visiting [https://api.telegram.org/bot](https://api.telegram.org/bot)<YOUR_TOKEN>/getUpdates in your browser.
<img width="1919" height="181" alt="image" src="https://github.com/user-attachments/assets/3993f0b1-f1cb-427e-b7b0-800176abe2b0" />

### 2. Configure Grafana Contact Points

* In Grafana, navigate to **Alerting** > **Contact points**.
<img width="1919" height="438" alt="image" src="https://github.com/user-attachments/assets/3f0cbfee-44b3-4359-86b9-c1edb8dfc59a" />

* Click **+ New contact point**.
<img width="1919" height="447" alt="image" src="https://github.com/user-attachments/assets/94888961-2caf-444f-97e6-054769eb8302" />

* Name the contact point and select **Telegram** as the integration type. Enter the **BOT API Token** and **Chat ID**.
<img width="1919" height="799" alt="image" src="https://github.com/user-attachments/assets/0f6848b3-b080-479b-ab19-16bbb7a68f49" />

* Customize Message Format to make the alert notifications cleaner and more readable, expand the **Optional Telegram settings** section.
  - Set** Parse mode** to `HTML`.
  - Paste the following template into the **Message** field:
<img width="1919" height="903" alt="image" src="https://github.com/user-attachments/assets/aa79bebb-e291-4d48-9b09-b67c16c67a26" />

* Click **Test** to ensure the connection works, then click **Save contact point**.
<img width="928" height="339" alt="image" src="https://github.com/user-attachments/assets/12eacbd8-cfdb-4b7c-96c1-327c0676d602" />
<img width="1388" height="911" alt="image" src="https://github.com/user-attachments/assets/9a0b145c-4a79-4dc2-bcad-4732675f36ff" />


### 3. Set Notification Policies
* Go to **Alerting** > **Notification policies**.

* Edit the default policy or create a new specific route.
<img width="1919" height="624" alt="image" src="https://github.com/user-attachments/assets/1a3ef0e8-2b11-44df-9763-363aea30d3d5" />

* Set the **Default contact point** to the Telegram Alerts you just created.
<img width="933" height="461" alt="image" src="https://github.com/user-attachments/assets/71a727d9-16fe-4f21-8fd3-af431969a250" />

### 4. Create Alert Rules
* Go to **Alerting** > **Alert rules** > **+ New alert rule**.
<img width="1917" height="898" alt="image" src="https://github.com/user-attachments/assets/ad2147a6-ab3c-4089-bc4e-e70a02f63d0d" />

* Create rules based on the task requirements. Select the Prometheus data source and use the following conditions:

| Alert Name         | Query Condition                                                                                           | Threshold (A)              |
|--------------------|-----------------------------------------------------------------------------------------------------------|----------------------------|
| High CPU Usage     | 100 - (avg by (alias) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)                             | IS ABOVE 80                |
| High RAM Usage     | (1 - (avg by (alias)(node_memory_MemAvailable_bytes) / avg by (alias)(node_memory_MemTotal_bytes))) * 100 | IS ABOVE 80                |
| Low Free Storage   | (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100          | IS BELOW 20                |
| High NGINX Traffic | avg by (alias) (rate(node_network_receive_bytes_total{alias="Gateway-Server", device!~"lo&#124;veth.*&#124;br.*"}[5m]))           | IS ABOVE 50000000 (50MB/s) |

<img width="1919" height="899" alt="image" src="https://github.com/user-attachments/assets/4326602a-e159-4eb5-bee6-9250a352772f" />

* Select folder and set the evaluation behavior (e.g., evaluate every 1m for 5m).
<img width="1919" height="816" alt="image" src="https://github.com/user-attachments/assets/d73bb76a-b4a7-4c14-959c-c35e9649fcb8" />

* Select **Telegram Alerts** as **Contact point**
<img width="1919" height="430" alt="image" src="https://github.com/user-attachments/assets/1e74f5eb-a9e9-476d-8f26-e607529f0316" />

* Add Summary and Description and click **Save**
Annotations Template Reference:

**1. High CPU Usage**
  * **Summary:** `🚨 High CPU Usage on {{ $labels.alias }}`
  * **Description:** `Warning! Server {{ $labels.alias }} is experiencing high CPU load (above 80%). 
Please check the running processes on the VM immediately.`
    
**2. High RAM Usage**
  * **Summary:** `⚠️ High RAM Usage on {{ $labels.alias }}`
  * **Description:** `RAM capacity on server {{ $labels.alias }} is running low (usage above 80%). 
Beware of potential Out of Memory (OOM) kills on your applications.`
    
**3. Low Free Storage**
  * **Summary:** `💾 Low Free Storage on {{ $labels.alias }}`
  * **Description:** `Free storage on server {{ $labels.alias }} is critically low (below 20%). 
Please clear unused logs or files immediately to prevent server crashes.`
    
**4. High NGINX Traffic**
  * **Summary:** `🌐 High Network Traffic on {{ $labels.alias }}`
  * **Description:** `High incoming network traffic detected (above 50MB/s) on NGINX Gateway ({{ $labels.alias }}). 
    Please verify if this is a legitimate traffic spike or a potential attack.`

<img width="1919" height="738" alt="image" src="https://github.com/user-attachments/assets/84851ac4-23db-4920-a1b1-e55b6be5079b" />
<img width="1919" height="908" alt="image" src="https://github.com/user-attachments/assets/7d08d506-546f-4e0d-837c-337db3425c98" />
<img width="1565" height="585" alt="image" src="https://github.com/user-attachments/assets/5e0fc129-06ff-4b19-995c-43dd8e3e3c75" />

### 5. Testing the Alert

**Manual Threshold Trigger**: Edit an alert rule and temporarily lower the threshold (e.g., set RAM Alert to Above 60%) to trigger the alert
<img width="1919" height="301" alt="image" src="https://github.com/user-attachments/assets/27e029eb-14a1-45d1-9258-794dbe3db20f" />

---
<img width="1387" height="212" alt="image" src="https://github.com/user-attachments/assets/6414b03b-0724-4d7d-9776-fd0bb9d34bc3" />



