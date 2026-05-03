# Kubernetes

## Orchestration with k3s

### 1. Setup k3s Kubernetes Cluster
Run the Ansible playbook to provision the k3s cluster across the Master and Worker nodes. This will automatically install k3s, Helm, Nginx Ingress, PostgreSQL, and FluxCD CLI.
```
ansible-playbook setup-k3s.yml
```
<img width="1479" height="900" alt="image" src="https://github.com/user-attachments/assets/8d331ef8-a729-462f-974d-3b9109302687" />
<img width="1477" height="719" alt="image" src="https://github.com/user-attachments/assets/9c217d39-397a-4ca7-837c-712e3228de6c" />

### 2. Verify Cluster Access
The playbook automatically fetches the kubeconfig file to your local machine. Use it to access the cluster remotely.
* Export the configuration to your environment:
```
export KUBECONFIG=~/.kube/config-finaltask
```
<img width="1482" height="65" alt="image" src="https://github.com/user-attachments/assets/11937878-b2c3-4fd7-a69e-58aedfbc508b" />

* Verify that both Master and Worker nodes are connected and ready:
```
kubectl get nodes
```

* Verify the Nginx Ingress status (it should run on all nodes):
```
kubectl get pods -n ingress-nginx -o wide
```
