# Web Server

## Webserver & Gateway Configuration

This task configures the central Gateway server using Nginx, secures all incoming traffic with a Let's Encrypt Wildcard SSL via Cloudflare DNS validation, and routes traffic to the respective internal servers. The full template and playbook can be found at [nginx-gateway.j2]() and [setup-gateway.yml]().

### Cloudflare API Token Preparation

To allow Certbot (and Ansible) to automatically modify DNS records for SSL validation, a Cloudflare API Token is required.

**1. Log in to the Cloudflare Dashboard and go to My Profile > API Tokens.**
<img width="1919" height="910" alt="image" src="https://github.com/user-attachments/assets/30ce32cc-f64a-45ea-8d1a-c2c1eb2d92a9" />

**2. Click Create Token and select the Edit zone DNS template.**
<img width="1919" height="909" alt="image" src="https://github.com/user-attachments/assets/624eff5d-5a2e-4620-9ae2-38aa0d06a23a" />

**3. Under Zone Resources, select Include > Specific Zone > studentdumbways.my.id (or your specific domain).**
<img width="1919" height="917" alt="image" src="https://github.com/user-attachments/assets/04beb21c-a97f-4a92-a30f-a791b06c7844" />

**4. Click Continue to summary and then Create Token.**
<img width="1596" height="161" alt="image" src="https://github.com/user-attachments/assets/231b31eb-f09c-468f-9268-c15b54fe05c0" />
<img width="1597" height="501" alt="image" src="https://github.com/user-attachments/assets/b256b534-93df-4f0e-8772-a3db8cf25d03" />

**5. Copy the generated token.**
<img width="1919" height="716" alt="image" src="https://github.com/user-attachments/assets/65c5669b-570d-411d-87b7-08dc370b7d92" />

**6. Encrypt the Token with Ansible Vault**
<img width="1484" height="248" alt="image" src="https://github.com/user-attachments/assets/816d552d-f7c3-4564-aa39-f1bd6e7f7dfc" />

**7. Add to Ansible Variables in `group_vars/all`**
<img width="1461" height="263" alt="image" src="https://github.com/user-attachments/assets/ab6c8b79-8954-48b4-a130-d58c04249fe5" />

### Execution & Verification

**1. Execute Ansible Playbook**
```
ansible-playbook setup-gateway.yml
```
<img width="1474" height="871" alt="image" src="https://github.com/user-attachments/assets/d0643fe3-703e-46da-9d4a-49c3ab9d2b0d" />
<img width="1475" height="400" alt="image" src="https://github.com/user-attachments/assets/f49f3846-ea9a-4e9d-83fa-782d3fe2e3f2" />

**2. Verify Cloudflare DNS Records**
<img width="1919" height="839" alt="image" src="https://github.com/user-attachments/assets/38fd9871-e63d-4481-81fb-1520d6b51911" />
<img width="1482" height="395" alt="image" src="https://github.com/user-attachments/assets/5839c4ca-4362-47ff-a44e-9a41b906b49d" />

**3. Verify SSL Auto-Renewal Script**
```
# Login to the gateway server
ssh gateway
# Check the script
sudo crontab -l
# Run renewal simulation
sudo certbot renew --dry-run
```
<img width="1489" height="297" alt="image" src="https://github.com/user-attachments/assets/ed2b8797-04bd-4ba2-a7b1-4f55e52077f2" />
<img width="1472" height="69" alt="image" src="https://github.com/user-attachments/assets/09576a4e-2996-4a16-b8c1-243d78f677ab" />
<img width="1474" height="296" alt="image" src="https://github.com/user-attachments/assets/a6fc8e4a-a7ec-4eae-964c-b9bad1b8ff52" />

**4. Test HTTPS Access**
```
curl -I https://api.staging.asykari.studentdumbways.my.id
```
<img width="1482" height="174" alt="image" src="https://github.com/user-attachments/assets/8a520d0a-8c1c-4745-b09d-1eb68e3ff534" />

