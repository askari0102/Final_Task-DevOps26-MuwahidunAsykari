# Repository

## Repository Setup & Configuration

### 1. GitLab SSH Key Configuration
To comply with the requirement of using only one SSH key for all purposes, configure your GitLab account and local machine to use the master `finaltask-key.pem` key.

* Copy the private key from Ubuntu WSL to Windows.
<img width="1911" height="239" alt="image" src="https://github.com/user-attachments/assets/7dce2ccf-2b6b-4a8a-be9a-1c8617de8a97" />

* Extract the public key from the .pem file.
```
ssh-keygen -y -f ~/.ssh/finaltask-key.pem
```
<img width="1919" height="185" alt="image" src="https://github.com/user-attachments/assets/af26f415-bfaf-48b9-b394-952f6f626f68" />

* Copy the output and add it to your GitLab account: Go to **User Settings** > **Access** > **SSH Keys** > **Add new key**. Paste the key, set the usage type to Authentication & Signing, and click **Add key**.
<img width="1919" height="899" alt="image" src="https://github.com/user-attachments/assets/13787b55-6f3f-49a1-aded-c8c99de128fa" />

* Add Gitlab identifier to `/.ssh/config`
<img width="1050" height="106" alt="image" src="https://github.com/user-attachments/assets/e36622bc-8bab-4a8b-8ce8-ebfd9969fec2" />

* Verify the connection
```
ssh -T git@gitlab.com
```
<img width="1919" height="66" alt="image" src="https://github.com/user-attachments/assets/61910e45-3e00-4159-9efe-0cbc07f28485" />


### **2. Creating Private Repositories on GitLab**
Prepare two private repositories on GitLab before migrating the code.
* Go to GitLab, click the **+ (Plus) icon** and select **New project/repository** -> **Create blank project**.
<img width="1919" height="1017" alt="image" src="https://github.com/user-attachments/assets/6186f893-8f45-4bb3-aa83-3258bf1149e6" />
<img width="1919" height="279" alt="image" src="https://github.com/user-attachments/assets/1b35e458-e75a-4aba-a82f-58ec556f2ee0" />
<img width="1919" height="1017" alt="image" src="https://github.com/user-attachments/assets/57bf3251-999c-47b9-8e54-170c156da6a7" />

* Fill in the project details and click the **Create project** button.
    - **Project name:** `fe-dumbmerch` (for frontend) and `be-dumbmerch` (for backend).
    - **Visibility Level:** Select Private
    - **Project Configuration**: Uncheck the option _"Initialize repository with a README"_ (Because we will push an existing repository).
<img width="1919" height="1022" alt="image" src="https://github.com/user-attachments/assets/06c2ca4d-ff55-4537-8b02-4c9f50bf6cb5" />
<img width="1918" height="902" alt="image" src="https://github.com/user-attachments/assets/2a6b0c4d-b81f-4ddc-b3b9-2ce7c3698022" />
<img width="1919" height="909" alt="image" src="https://github.com/user-attachments/assets/40e00699-aa9f-46c6-90d7-52935833eb9e" />

### **3. Code Migration & Branching Setup**
Clone the original source, link it to the private GitLab repositories, and create the required branches (`staging` and `production`).

* First create a root directory for the app and navigate into it
<img width="1919" height="253" alt="image" src="https://github.com/user-attachments/assets/ef136c4f-2e53-479a-a9b0-5553321b102b" />

**- Frontend Setup**
* Clone and navigate to the frontend directory
```
git clone https://github.com/demo-dumbways/fe-dumbmerch.git
cd fe-dumbmerch
```
<img width="1919" height="237" alt="image" src="https://github.com/user-attachments/assets/8cf5a1d8-ff88-40da-be31-24d20f53c718" />

* Replace the remote origin with your private GitLab repository
```
git remote remove origin
git remote add origin https://gitlab.com/your-username/fe-dumbmerch.git
```
<img width="1919" height="79" alt="image" src="https://github.com/user-attachments/assets/fab84564-6295-4457-aa1b-edba5d8f6470" />

* Rename default branch to 'staging' and push
```
git branch -M staging
git push -u origin staging
```
<img width="1919" height="282" alt="image" src="https://github.com/user-attachments/assets/36452d5d-4ae0-4754-a0ac-c23040de3511" />

* Create 'production' branch from staging and push
```
git checkout -b production
git push -u origin production
```
<img width="1919" height="284" alt="image" src="https://github.com/user-attachments/assets/7b30a2b4-f03a-48de-8ce7-e1de1473f826" />

* Return to root directory
<img width="1919" height="60" alt="image" src="https://github.com/user-attachments/assets/37d5d88f-b6b6-4636-a8c9-c66f9df1f0b6" />

**- Backend Setup**
* Clone and navigate to the backend directory
```
git clone https://github.com/demo-dumbways/be-dumbmerch.git
cd be-dumbmerch
```
<img width="1919" height="252" alt="image" src="https://github.com/user-attachments/assets/894f8f86-9b87-4122-871f-a2926071734b" />

* Replace the remote origin with your private GitLab repository
```
git remote remove origin
git remote add origin https://gitlab.com/your-username/be-dumbmerch.git
```
<img width="1919" height="84" alt="image" src="https://github.com/user-attachments/assets/57a47aeb-f0f9-4c31-b86a-eaa8fa558504" />

* Rename default branch to 'staging' and push
```
git branch -M staging
git push -u origin staging
```
<img width="1919" height="285" alt="image" src="https://github.com/user-attachments/assets/fc0da23e-98de-4cfc-8bad-3229f29d3a8e" />

* Create 'production' branch from staging and push
```
git checkout -b production
git push -u origin production
```
<img width="1919" height="288" alt="image" src="https://github.com/user-attachments/assets/8c63c8b6-a55d-47db-9bf0-2d96b4653254" />

---
<img width="1919" height="1019" alt="image" src="https://github.com/user-attachments/assets/d5ee485a-895e-4e67-ab9c-6864309d4492" />
<img width="1919" height="1021" alt="image" src="https://github.com/user-attachments/assets/788bc119-444b-4726-bdb2-71b698751217" />

### 4. Branch Protection Setup
To secure the pipeline environment variables and ensure code integrity, configure the `production` branch as a Protected Branch in both the frontend and backend repositories.

* Navigate to **Settings** > **Repository** and expand the **Protected branches** section.

* Select the `production` branch from the dropdown.

* Set both **Allowed to merge** and **Allowed to push and merge** to _Maintainers_.

* Click the **Protect** button.
<img width="1545" height="610" alt="image" src="https://github.com/user-attachments/assets/ea5f0677-4651-4957-96a4-4bf11ffd7777" />

  
### **5. Environment Configuration**
For security, `.env` values are securely stored in GitLab CI/CD Variables and injected automatically during deployment.
* **Frontend**: Configured `REACT_APP_BASEURL` to connect to the Backend API.

* **Backend**: Configured all required environment variables for full database and application integration.
<img width="1417" height="97" alt="image" src="https://github.com/user-attachments/assets/5b6a8e3a-dc44-4ced-a988-c9be906c3ee9" />

### 6. GitOps Repository Setup
To implement a secure Continuous Deployment pipeline for the production environment, a separate repository is required to store the Kubernetes manifests

* Create a third blank private repository named `finaltask-gitops`
<img width="1917" height="639" alt="image" src="https://github.com/user-attachments/assets/146bedaa-9f98-4919-94c5-0734d54f111e" />

* Generate a GitLab Personal Access Token (PAT). This token will be used later to bootstrap FluxCD into the cluster.
    - Click on your **User Avatar** in the top right corner of GitLab and select **Edit profile** (or **Preferences**).
    - On the left sidebar, click on **Access** > **Personal access tokens**.
    - Click **Generate token** and select **Legacy token** from the dropdown menu.
    - Set the **Token name** (e.g., `fluxcd-bootstrap`).
    - Under **Scopes**, check the boxes for `api`, `read_repository`, and `write_repository`.
    - Click `Create personal access token`.
    - Copy the generated token immediately and save it to your notepad
<img width="1919" height="458" alt="image" src="https://github.com/user-attachments/assets/5a994780-992c-40dd-8e8d-0edc9cd5b8a1" />

