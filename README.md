# Assignment: DevOps Pipeline for a Task Tracker App

## Objective
Your assignment is to build out the DevOps CI/CD pipeline and containerization strategy for this Node.js Task Tracker application. We have removed all DevOps-related artifacts, so you will need to create them from scratch.

## Assignment Details

### 1. Docker Requirements
You must write a `Dockerfile` with the following requirements:
- Use a **multi-stage build** to optimize the image size.
- Incorporate basic **Docker security features** (e.g., using a non-root user, minimal base image like alpine, running as a non-root user).

### 2. Docker Compose Requirements
You must write a `docker-compose.yml` file to spin up the application easily using `docker-compose up`.

### 3. Jenkins Pipeline Requirements
You must write a `Jenkinsfile` for the CI/CD pipeline. The pipeline should include:
- Usage of the `environment` block to define variables.
- The following stages:
  - **SCM Pull**: Checkout the code from your repository.
  - **Install Dependencies and Run Tests**: Run `npm install` and `npm test`.
  - **Build**: Build the multi-stage Docker image.
  - **Deploy**: Run the application using Docker Compose.
  - **Curl**: Verify the deployment by sending a curl request to the health endpoint.
  - **Cleanup**: Tear down the deployment (e.g. `docker compose down`), remove dangling images, and clean the workspace.

### 4. Deployment Expected Output
Your deployment verification should show the output of all 3 application endpoints
- `http://localhost:3000/`
- `http://localhost:3000/health`
- `http://localhost:3000/api/tasks`

## Time Allotted
You have **4 hours** to complete this assignment.

## Evaluation Weightage
- **Dockerization (Multi-stage & Security):** 30%
- **Docker Compose:** 10%
- **Jenkins Pipeline implementation (Stages & Env):** 40%
- **Deployment Verification (Outputs):** 10%
- **Code Quality & Documentation:** 10%

## Submission
Please submit:
1. The URL to your GitHub repository containing the source code along with your new `Dockerfile`, `docker-compose.yml`, and `Jenkinsfile`.
2. Screenshots of successful Jenkins pipeline runs.
3. Screenshots of the endpoints working as expected post-deployment.
