# Kubernetes

## Orchestration with k3s

### 1. Setup k3s Kubernetes Cluster
Run the Ansible playbook to provision the k3s cluster across the Master and Worker nodes. This will automatically install k3s, Helm, Nginx Ingress, PostgreSQL, and FluxCD CLI.
```
ansible-playbook setup-k3s.yml
```
<img width="1481" height="827" alt="image" src="https://github.com/user-attachments/assets/17eda5db-e077-4f3c-9cc7-ffd6f8ae24e9" />
<img width="1478" height="813" alt="image" src="https://github.com/user-attachments/assets/770863a1-79e3-49b3-be56-e724b4955f2b" />

### 2. Verify Cluster Access
The playbook automatically fetches the kubeconfig file to your local machine. Since the cluster resides in a private subnet, you must establish an SSH tunnel to securely access the k3s API.

* Create a local port forwarding tunnel using the SSH configuration. This will forward your local port 6443 through the Gateway directly to the k3s Master node. 
*(Keep this terminal open while managing the cluster)*
```
ssh -N -L 6443:127.0.0.1:6443 prod-master
```
<img width="1474" height="118" alt="image" src="https://github.com/user-attachments/assets/b69ab6b0-bf82-4233-b510-4882630e5570" />

* In a new terminal window, export the configuration to your environment:
```
export KUBECONFIG=~/.kube/config-finaltask
```
<img width="1483" height="121" alt="image" src="https://github.com/user-attachments/assets/9ee094d0-a6f8-422a-81e7-88bda5724f01" />

* Verify that both Master and Worker nodes are connected and ready:
```
kubectl get nodes
```
<img width="1487" height="212" alt="image" src="https://github.com/user-attachments/assets/78df8bc3-4708-4b09-8906-1337acfbe983" />

* Verify the Nginx Ingress status (it should run on all nodes):
```
kubectl get pods -n ingress-nginx -o wide
```
<img width="1486" height="140" alt="image" src="https://github.com/user-attachments/assets/e3c949e8-8661-4f77-8fe2-3a3f794c29f8" />

* Verify the PostgreSQL database and persistent volume status:
```
kubectl get all,pvc -n production
```
<img width="1919" height="323" alt="image" src="https://github.com/user-attachments/assets/a55d5e58-d2d5-40a2-aec7-53d8c2032204" />

### 3. GitOps - FluxCD Setup

* Install Flux CLI in local computer
```
curl -s https://fluxcd.io/install.sh | sudo bash
```
<img width="1919" height="172" alt="image" src="https://github.com/user-attachments/assets/735b5926-69d3-4370-9812-2649dd3ae489" />

* Verify that your K3s cluster is ready and meets the prerequisites for Flux.
```
flux check --pre
```
<img width="1919" height="97" alt="image" src="https://github.com/user-attachments/assets/75b15531-b9f0-4807-8b7a-313e425f5cdd" />

* Bootstrap FluxCD to the GitOps repository using your GitLab Personal Access Token (PAT).
```
export GITLAB_TOKEN=<your-gitlab-pat>

flux bootstrap gitlab \
  --hostname=gitlab.com \
  --owner=<YOUR_GITLAB_USERNAME> \
  --repository=finaltask-gitops \
  --branch=main \
  --path=clusters/production \
  --personal
```
<img width="1919" height="34" alt="image" src="https://github.com/user-attachments/assets/684b1911-db27-4e39-8ca7-8e88da45bfcb" />
<img width="1919" height="948" alt="image" src="https://github.com/user-attachments/assets/1020cd58-344a-4c15-830f-2ca453ff042c" />

### 4. Kubernetes Manifests Deployment
After bootstrapping, FluxCD will monitor the `finaltask-gitops` repository. Any manifests pushed to the `clusters/production` directory will be automatically synchronized

* Clone the GitOps repository and navigate to the production directory.
```
git clone git@gitlab.com:askari0102/finaltask-gitops.git
cd finaltask-gitops
```
<img width="1857" height="184" alt="image" src="https://github.com/user-attachments/assets/2f91a945-af75-4094-9961-cf272e5713e1" />
<img width="1477" height="70" alt="image" src="https://github.com/user-attachments/assets/e8fa6518-115b-4b60-9050-605f02997ce3" />

* Create the application manifests (Deployment, Service, and Ingress) for both Frontend and Backend
  
* Commit and push the initial manifests to trigger the first GitOps sync.
```
git add .
git commit -m "initial application manifests deployment"
git push origin main
```
