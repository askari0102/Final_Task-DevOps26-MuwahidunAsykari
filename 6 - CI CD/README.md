# CI/CD

## Automated CI/CD Pipeline

**1. Server Provisioning**

The first step is to prepare the CI/CD server. 
```
ansible-playbook setup-cicd.yml
```
<img width="1476" height="914" alt="image" src="https://github.com/user-attachments/assets/8f6d6dd9-c06d-4012-8208-0f25b753ef68" />

**2. Accessing SonarQube & Token Generation**

Since the server is inside a private network, an encrypted tunnel must be used to access the dashboard from a local machine.
* Open SSH Tunnel
```
ssh -L 9000:localhost:9000 cicd
```
<img width="1914" height="74" alt="image" src="https://github.com/user-attachments/assets/7e76e7f1-4043-49e4-af28-afcd4abef24e" />

* Access Dashboard with `http://localhost:9000` in your local browser
<img width="1918" height="1019" alt="image" src="https://github.com/user-attachments/assets/2011b47f-b4d3-46b9-8a5d-5e31c96c016f" />
<img width="1919" height="965" alt="image" src="https://github.com/user-attachments/assets/6b032dc0-bc23-416f-8dea-00d77a48d842" />

* Generate Token by going to **User** > **My Account** > **Security**, then generate a **User Token**.
<img width="1919" height="914" alt="image" src="https://github.com/user-attachments/assets/29babc25-d49e-43b5-8e1d-d22bbddd23de" />

**3. GitLab Runner Registration**

To run the pipeline, we need to register the GitLab Runner on the CI/CD server.

* Get Registration Token: Go to **GitLab** > **Settings** > **CI/CD** > **Runners**. Click **New project runner**. Add the `cicd` tag. Copy the registration command.
<img width="1919" height="776" alt="image" src="https://github.com/user-attachments/assets/84407d61-ee62-430e-a18d-0c32fd0153f6" />
<img width="1919" height="452" alt="image" src="https://github.com/user-attachments/assets/1ab7b621-b543-4ce6-91cc-f291a2784d1c" />
<img width="1919" height="898" alt="image" src="https://github.com/user-attachments/assets/cdc5b075-7b88-4978-8ba8-cb1957008723" />

* Register on Server: SSH into the CI/CD server and paste the copied command
<img width="1919" height="72" alt="image" src="https://github.com/user-attachments/assets/a1f3416d-2d32-4d7f-b667-679fc46d26f4" />
<img width="1919" height="426" alt="image" src="https://github.com/user-attachments/assets/b879c2c0-ddb0-4504-89da-0cff03c297c7" />

**4. GitLab Runner Configuration**

To allow the runner to build Docker images, we must grant it privileged access.
* SSH into the CI/CD server and edit the configuration file
```
sudo nano /etc/gitlab-runner/config.toml
```
<img width="1710" height="31" alt="image" src="https://github.com/user-attachments/assets/317c6a80-951b-43f8-a03f-db72d5197961" />

* Under the `[runners.docker]` section, modify the file to include `privileged = true` and add `/certs/client` to the volumes
<img width="1205" height="276" alt="image" src="https://github.com/user-attachments/assets/3ef3af82-145a-4545-a794-ac9968b3e64b" />

* Restart the runner to apply changes
```
sudo gitlab-runner restart
```
<img width="1706" height="56" alt="image" src="https://github.com/user-attachments/assets/2a81bb94-3c9b-4a5b-97a2-7938ad8ef1bb" />

**5. GitLab Variables Setup**

* Go to your Frontend repository and navigate to **Settings > CI/CD > Variables**.  

* Add the following required credentials and configurations:
   * `SSH_PRIVATE_KEY` (Type: File) - Private key for SSH access.
   * `STAGING_IP` - IP address of the Staging server.
   * `STAGING_USER` - SSH username for the Staging server.
   * `REGISTRY_URL` - Private Docker Registry URL.
   * `REGISTRY_USER` - Username for the Docker Registry.
   * `REGISTRY_PASS` - Password for the Docker Registry.
   * `SONAR_URL` - URL of the SonarQube dashboard.
   * `SONAR_TOKEN` - Access token for SonarQube authentication.
   * `TEST_URL` - Public URL to verify the deployment.
   * `DOCKER_COMPOSE` (Type: File) - The `docker-compose.yml` script.
   * `ENV_FILE` (Type: File) - The `.env` variables.

* Open your Backend repository and navigate to **Settings > CI/CD > Variables**.
 
* Repeat the process to add the exact same variables, make sure `DOCKER_COMPOSE` and `ENV_FILE` contain the scripts specifically made for the Backend.

<img width="1709" height="842" alt="image" src="https://github.com/user-attachments/assets/77c8de24-d15f-4850-8406-a0d132214ae1" />

**6. Pipeline Execution**
This pipeline is fully dynamic and utilizes GitLab predefined variables (like `$CI_PROJECT_NAME`), allowing the **exact same `.gitlab-ci.yml` script** to be used across both Frontend and Backend repositories. The deployment behavior changes based on the branch:

* **Staging Branch:** Deployed directly to the Staging server using SSH.
* **Production Branch:** Prepared for a GitOps workflow (FluxCD/K3s) by updating Kubernetes manifests.

- Create a `.git-ci.yml` on both Frontend and Backend repositories:
```
stages:
  - test
  - build
  - deploy
  - verify

variables:
  IMAGE_TAG: $CI_COMMIT_BRANCH
  DOCKER_HOST: tcp://docker:2375
  DOCKER_TLS_CERTDIR: ""

# 1. TESTING STAGE
sonarqube_check:
  stage: test
  image: sonarsource/sonar-scanner-cli:latest
  script:
    - sonar-scanner -Dsonar.projectKey=$CI_PROJECT_NAME -Dsonar.host.url=$SONAR_URL -Dsonar.login=$SONAR_TOKEN
  rules:
    - if: '$CI_COMMIT_BRANCH == "staging" || $CI_COMMIT_BRANCH == "production"'
  tags:
    - cicd

# 2. BUILD & PUSH STAGE
build_image:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  before_script:
    - echo "$REGISTRY_PASS" | docker login $REGISTRY_URL -u "$REGISTRY_USER" --password-stdin
  script:
    - docker build -t $REGISTRY_URL/$CI_PROJECT_NAME:$IMAGE_TAG .
    - docker push $REGISTRY_URL/$CI_PROJECT_NAME:$IMAGE_TAG
  rules:
    - if: '$CI_COMMIT_BRANCH == "staging" || $CI_COMMIT_BRANCH == "production"'
  tags:
    - cicd

deploy_staging:
  stage: deploy
  image: alpine:latest
  before_script:
    - apk add --no-cache openssh-client
    - eval $(ssh-agent -s)
    - chmod 400 "$SSH_PRIVATE_KEY"
    - ssh-add "$SSH_PRIVATE_KEY"
    - mkdir -p ~/.ssh && chmod 700 ~/.ssh
  script:
    - cp $ENV_FILE .env.deploy
    - echo "" >> .env.deploy
    - echo "REGISTRY_URL=$REGISTRY_URL" >> .env.deploy
    - echo "CI_PROJECT_NAME=$CI_PROJECT_NAME" >> .env.deploy
    - echo "IMAGE_TAG=$IMAGE_TAG" >> .env.deploy

    # Create directory and transfer Compose & Env files
    - ssh -o StrictHostKeyChecking=no -p 6969 $STAGING_USER@$STAGING_IP "mkdir -p ~/app/$CI_PROJECT_NAME"
    - scp -o StrictHostKeyChecking=no -P 6969 $DOCKER_COMPOSE $STAGING_USER@$STAGING_IP:~/app/$CI_PROJECT_NAME/docker-compose.yml
    - scp -o StrictHostKeyChecking=no -P 6969 .env.deploy $STAGING_USER@$STAGING_IP:~/app/$CI_PROJECT_NAME/.env
    
    # Restart the application containers 
    - ssh -o StrictHostKeyChecking=no -p 6969 $STAGING_USER@$STAGING_IP "
        echo '$REGISTRY_PASS' | docker login $REGISTRY_URL -u '$REGISTRY_USER' --password-stdin &&
        cd ~/app/$CI_PROJECT_NAME &&
        export REGISTRY_URL=$REGISTRY_URL &&
        export CI_PROJECT_NAME=$CI_PROJECT_NAME &&
        export IMAGE_TAG=$IMAGE_TAG &&
        docker compose pull &&
        docker compose up -d"
  rules:
    - if: '$CI_COMMIT_BRANCH == "staging"'
  tags:
    - cicd

# 3b. DEPLOY STAGE (PRODUCTION GITOPS PREPARATION)
deploy_production_gitops:
  stage: deploy
  image: alpine:latest
  script:
    - echo "GitOps workflow triggered for Production branch."
    - echo "In a complete setup, this job will clone the gitops-manifest repo, update the image tag, and push the changes for K3s/FluxCD to sync."
  rules:
    - if: '$CI_COMMIT_BRANCH == "production"'
  tags:
    - cicd

# 4. VERIFICATION STAGE (STAGING ONLY)
verify_staging:
  stage: verify
  image: alpine:latest
  before_script:
    - apk add --no-cache curl
  script:
    - echo "Verifying staging deployment..."
    - sleep 10
    - curl -s -o /dev/null -w "%{http_code}" $TEST_URL | grep -E '^[2345]' || (echo "Deployment Failed" && exit 1)
    - echo "Deployment Verified Successfully."
  rules:
    - if: '$CI_COMMIT_BRANCH == "staging"'
  tags:
    - cicd
```
* Push the `.gitlab-ci.yml` to their respective repositories to trigger the pipelines
<img width="1483" height="349" alt="image" src="https://github.com/user-attachments/assets/80393fa9-478b-473a-b1a1-05675f143c00" />
<img width="1424" height="287" alt="image" src="https://github.com/user-attachments/assets/177ba823-2f97-4467-8c7a-31135c1f527f" />

**7. Pipeline Monitoring & Logs**

After pushing the `.gitlab-ci.yml`, you can monitor the progress in **GitLab** > **Build** > **Pipelines**.

* **Test Stage**: Runs SonarQube analysis to ensure code quality and security.
* **Build Stage**: Builds the Docker image and pushes it to the Private Registry.
* **Deploy Stage**: Connects to the Staging server via SSH, pulls the new image, and restarts containers using Docker Compose.
* **Verify Stage**: Verify Stage: Uses `wget --spider` to confirm the application is live.

<img width="1919" height="605" alt="image" src="https://github.com/user-attachments/assets/1abddb57-c435-48ee-9f96-cb65cf5a1544" />
<img width="1919" height="616" alt="image" src="https://github.com/user-attachments/assets/eaa74d4a-7ddb-4a97-93f7-261a594b5c46" />

**8. Final Results & Verification**

Once the pipeline shows a green "Passed" status, verify the deployment by accessing the public URL
<img width="1919" height="908" alt="image" src="https://github.com/user-attachments/assets/dc988492-1306-4343-bab0-35f3ef3ef386" />
<img width="1919" height="1016" alt="image" src="https://github.com/user-attachments/assets/eed4a985-b86e-4b7c-adc1-ebf90c79d2c2" />
