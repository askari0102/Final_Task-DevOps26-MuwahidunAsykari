# Deployment 

## Application & Database Deployment

The source code for the frontend and backend is hosted on a private GitLab repository. The actual build and push processes are automated via the CI/CD pipeline.

**1. Image Optimization & Environment Injection**

**Docker Multi-stage builds** are implemented to keep the final images as small as possible. For security, `.env` secrets are not hardcoded into the image. Instead, environment variables are injected dynamically at runtime. Below are the source code modifications required to achieve this.

* **Frontend (Serve Static with Nginx)**
  Navigate to the frontend repository directory and ensure the active branch is `staging`.
  <img width="1919" height="35" alt="image" src="https://github.com/user-attachments/assets/f1767aca-57e3-4505-9f7f-7d061ec1960b" />

  - Update `public/index.html`
  Add the script tag to load the generated environment variables:
  <img width="1483" height="133" alt="image" src="https://github.com/user-attachments/assets/eecf27f5-082b-451a-b9e2-0a04fc482769" />
  
  - Update API Configuration (api.js) to include `window._env_`
  <img width="1475" height="428" alt="image" src="https://github.com/user-attachments/assets/a24417f9-e4b2-4515-954d-75451dda2c1f" />

  - Dockerfile (Multi-stage & Non-Root)
  Create Dockerfile
  ```Dockerfile
  # Stage 1: Build 
  FROM node:16-alpine AS builder
  
  WORKDIR /app
  
  # Cache package.json
  COPY package*.json ./
  
  # Install dependency without audit/fund and clean cache
  RUN npm install --no-audit --no-fund && npm cache clean --force
  
  # Copy only the needed source code
  COPY public/ ./public
  COPY src/ ./src
  
  # Build
  RUN npm run build
  
  # Stage 2: Serve with Nginx
  FROM nginx:stable-alpine
  
  # Copy entrypoint script & Nginx config
  COPY entrypoint.sh /entrypoint.sh
  COPY nginx.conf /etc/nginx/conf.d/default.conf
  
  # Give executable permission to entrypoint
  RUN chmod +x /entrypoint.sh
  
  # Create a non-root user to prevent the container from running as root
  RUN addgroup -g 10001 -S frontendgroup && \
      adduser -u 10001 -S frontenduser -G frontendgroup
  
  # Grant the non-root user access to Nginx system folders and the entrypoint script
  RUN touch /var/run/nginx.pid && \
      chown -R 10001:10001 /var/run/nginx.pid /var/cache/nginx /var/log/nginx /etc/nginx/conf.d /usr/share/nginx/html /entrypoint.sh
  
  # Switch to the non-root user
  USER frontenduser
  
  # Copy the build output from Stage 1
  COPY --from=builder --chown=10001:10001 /app/build /usr/share/nginx/html
  
  # Expose port 8080
  EXPOSE 8080
  
  ENTRYPOINT ["/entrypoint.sh"]
  ```
  
  - Create `entrypoint.sh`
  This script extracts the environment variable and writes it to env-config.js before running Nginx.
  <img width="1488" height="247" alt="image" src="https://github.com/user-attachments/assets/31918743-be11-4425-a63f-d27e91a892e6" />

  - Create `nginx.conf`
  <img width="1479" height="664" alt="image" src="https://github.com/user-attachments/assets/37b14401-5ed0-4f0c-bbe4-9170bf75b820" />

  - Commit and Push to Staging Branch

**2. Infrastructure Configuration (Ansible & Docker Compose)**
The PostgreSQL database and Nginx Load Balancer are deployed automatically with Ansible.
  - The database volume is mapped to `/home/{{ staging_db_user }}/staging/db_data`
  - Ports are exposed to allow remote database access and application load balancing.
<img width="1484" height="893" alt="image" src="https://github.com/user-attachments/assets/c6ef42cf-7fd1-42c3-a18b-167fa4a89bf6" />
<img width="1479" height="739" alt="image" src="https://github.com/user-attachments/assets/0d50cedf-9f09-455f-b21e-7ff680c3787e" />
<img width="1481" height="826" alt="image" src="https://github.com/user-attachments/assets/47582b1d-71e5-4e6a-b971-e85275d2c16e" />

