# Deployment 

## Application & Database Deployment

The source code for the frontend and backend is hosted on a private GitLab repository. The actual build and push processes are automated via the CI/CD pipeline.

**1. Image Optimization & Environment Injection**

**Docker Multi-stage builds** are implemented to keep the final images as small as possible. For security, `.env` secrets are not hardcoded into the image. Instead, environment variables are injected dynamically at runtime. Below are the source code modifications required to achieve this.

* **Frontend (Serve Static with Nginx)**
  - Update `public/index.html`
  Add the script tag to load the generated environment variables:
  
   

**2. Infrastructure Configuration (Ansible & Docker Compose)**
The PostgreSQL database and Nginx Load Balancer are deployed automatically with Ansible.
  - The database volume is mapped to `/home/{{ staging_db_user }}/staging/db_data`
  - Ports are exposed to allow remote database access and application load balancing.
<img width="1484" height="893" alt="image" src="https://github.com/user-attachments/assets/c6ef42cf-7fd1-42c3-a18b-167fa4a89bf6" />
<img width="1479" height="739" alt="image" src="https://github.com/user-attachments/assets/0d50cedf-9f09-455f-b21e-7ff680c3787e" />
<img width="1481" height="826" alt="image" src="https://github.com/user-attachments/assets/47582b1d-71e5-4e6a-b971-e85275d2c16e" />

