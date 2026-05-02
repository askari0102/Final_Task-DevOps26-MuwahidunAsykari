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

**3. GitLab Variables Setup**

Configure variables in **GitLab** > **Settings** > **CI/CD** > **Variables** to allow the pipeline to communicate with the registry and staging server.
<img width="1661" height="838" alt="image" src="https://github.com/user-attachments/assets/3653a0ef-d799-40b8-b1ef-250f1a339625" />

**4. Pipeline Execution**
This pipeline works differently based on the branch. The staging branch is deployed directly to the server using SSH and Docker Compose. Meanwhile, the production branch is set up for GitOps (FluxCD) using Kubernetes manifests.

* Create a `.git-ci.yml` on both branches. Commit and push to `staging` branch.
```
stages:
  - test
  - build
  - deploy
  - verify

variables:
  IMAGE_TAG: $CI_COMMIT_BRANCH

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
    - docker login -u $REGISTRY_USER -p $REGISTRY_PASS $REGISTRY_URL
  script:
    - docker build -t $REGISTRY_URL/$CI_PROJECT_NAME:$IMAGE_TAG .
    - docker push $REGISTRY_URL/$CI_PROJECT_NAME:$IMAGE_TAG
  rules:
    - if: '$CI_COMMIT_BRANCH == "staging" || $CI_COMMIT_BRANCH == "production"'
  tags:
    - cicd

# 3a. DEPLOY STAGE (STAGING ONLY)
deploy_staging:
  stage: deploy
  image: alpine:latest
  before_script:
    - apk add --no-cache openssh-client
    - eval $(ssh-agent -s)
    - echo "$SSH_PRIVATE_KEY" | tr -d '\r' | ssh-add -
    - mkdir -p ~/.ssh && chmod 700 ~/.ssh
  script:
    # Create directory and securely transfer Compose & Env files
    - ssh -o StrictHostKeyChecking=no $STAGING_USER@$STAGING_IP "mkdir -p ~/app/$CI_PROJECT_NAME"
    - scp -o StrictHostKeyChecking=no $DOCKER_COMPOSE $STAGING_USER@$STAGING_IP:~/app/$CI_PROJECT_NAME/docker-compose.yml
    - scp -o StrictHostKeyChecking=no $ENV_FILE $STAGING_USER@$STAGING_IP:~/app/$CI_PROJECT_NAME/.env
    # Restart the application containers
    - ssh -o StrictHostKeyChecking=no $STAGING_USER@$STAGING_IP "
        docker login -u $REGISTRY_USER -p $REGISTRY_PASS $REGISTRY_URL &&
        cd ~/app/$CI_PROJECT_NAME &&
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
  script:
    - echo "Verifying staging deployment..."
    - wget --spider -q -t 5 --waitretry=5 http://$STAGING_IP || (echo "Deployment Failed - Host Unreachable" && exit 1)
    - echo "Deployment Verified Successfully."
  rules:
    - if: '$CI_COMMIT_BRANCH == "staging"'
  tags:
    - cicd
```
<img width="1483" height="349" alt="image" src="https://github.com/user-attachments/assets/80393fa9-478b-473a-b1a1-05675f143c00" />

