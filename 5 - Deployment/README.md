# Deployment 

## Application & Database Deployment

The source code for the frontend and backend is hosted on a private GitLab repository. The actual build and push processes are automated via the CI/CD pipeline.

## Image Optimization

**Docker Multi-stage builds** are implemented to keep the final images as small as possible. For security, `.env` secrets are not hardcoded into the image. Instead, environment variables are injected dynamically at runtime. Below are the source code modifications required to achieve this.

**1. Frontend (Serve Static with Nginx)**

  Navigate to the frontend repository directory and ensure the active branch is `staging`.
  <img width="1919" height="35" alt="image" src="https://github.com/user-attachments/assets/f1767aca-57e3-4505-9f7f-7d061ec1960b" />

  - Update `public/index.html`
  - 
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
  <img width="1487" height="468" alt="image" src="https://github.com/user-attachments/assets/05b2d3ee-2d2a-4209-8df2-6865a3444c7a" />
  <img width="1483" height="618" alt="image" src="https://github.com/user-attachments/assets/72141e6c-1569-4a18-8669-5fab6743a9e9" />

**2. Backend (Go)**

  Navigate to the backend repository directory and ensure the active branch is `staging`.
  <img width="1919" height="39" alt="image" src="https://github.com/user-attachments/assets/47a7fbe1-079d-4691-bb5a-28bb2a4dc637" />

  - Update Environment Loading Logic in `main.go`
    
  From
  ```go
	errEnv := godotenv.Load()
    if errEnv != nil {
		panic("Failed to load env file")
    }
  ```
  To
  ```go
  errEnv := godotenv.Load()
    if errEnv != nil {
    fmt.Println("Info: .env file not found, using OS/Docker's variables.")
	}
  ```
  <img width="1398" height="157" alt="image" src="https://github.com/user-attachments/assets/a1c85adb-4343-40a1-ae23-0568fed68700" />

  - Dockerfile (Multi-stage & Non-Root)
    
  Create Dockerfile. 
  ```Dockerfile
  # Stage 1: Build Dependency & Binary
  FROM golang:1.16-alpine AS builder
  
  WORKDIR /app
  
  # Download dependencies for caching layer
  COPY go.mod go.sum ./
  RUN go mod download
  
  # Copy source code and build
  COPY . .
  RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o backend-api main.go
  
  # Stage 2: Minimalist Runtime
  FROM alpine:latest
  
  WORKDIR /app
  
  # Install ca-certificates for external APIs (Midtrans/Email) & setup non-root user
  RUN apk --no-cache add ca-certificates && \
      addgroup -g 10001 -S gogroup && \
      adduser -u 10001 -S gouser -G gogroup && \
      mkdir -p uploads && \
      chown -R gouser:gogroup /app
  
  # Switch to non-root user for security
  USER gouser
  
  # Copy only the compiled binary from the builder stage
  COPY --from=builder --chown=gouser:gogroup /app/backend-api .
  
  EXPOSE 5000
  
  CMD ["./backend-api"]
  ```
  <img width="1483" height="892" alt="image" src="https://github.com/user-attachments/assets/545b2445-95b9-478c-9a6c-3a816b23c37a" />

  - Ignore Local Env (`.dockerignore`)
  To ensure environment secrets are not hardcoded into the image, a `.dockerignore` file is implemented to exclude the `.env` file during the build process

  <img width="1485" height="165" alt="image" src="https://github.com/user-attachments/assets/a290e086-77f4-4a1e-9d10-fb0e6c67ca6e" />

  - Commit and Push Backend to Staging Branch
  <img width="1482" height="692" alt="image" src="https://github.com/user-attachments/assets/1472bc77-1673-4f82-a2a3-93caaf9ed8ef" />
  
## Infrastructure Configuration (Ansible & Docker Compose)

The PostgreSQL database and Nginx Load Balancer are deployed automatically with Ansible.
  - The database volume is mapped to `/home/{{ staging_db_user }}/staging/db_data`
  - Ports are exposed to allow remote database access and application load balancing.
<img width="1484" height="893" alt="image" src="https://github.com/user-attachments/assets/c6ef42cf-7fd1-42c3-a18b-167fa4a89bf6" />
<img width="1479" height="739" alt="image" src="https://github.com/user-attachments/assets/0d50cedf-9f09-455f-b21e-7ff680c3787e" />
<img width="1481" height="826" alt="image" src="https://github.com/user-attachments/assets/47582b1d-71e5-4e6a-b971-e85275d2c16e" />

## Deployment and Verification

**1. Execute Ansible Playbook**
```
ansible-playbook setup-staging.yml
```
<img width="1475" height="521" alt="image" src="https://github.com/user-attachments/assets/da170b9f-66ba-4b94-b60c-aa3eb597ba56" />


**2. CI/CD Pipeline Deployment (Application)**

The building of the images, pushing to the private registry, and the actual deployment of the Frontend and Backend containers are fully automated via the GitLab CI/CD pipeline. The pipeline accesses the staging server and executes the application's Docker Compose configuration. The compose is stored as a GitLab CI/CD Variable (File type) and injected directly into the server during the deployment stage.





