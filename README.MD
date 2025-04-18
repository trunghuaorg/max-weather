**PROJECT DIAGRAM**

**PROJECT STRUCTURE**

1. app.api → Contains the API implementation with a self-implemented OAuth2 system. The codebase is written in Python.
2. app.tf → Contains Terraform scripts for provisioning infrastructure.
3. app.eksconfig → Contains the configuration and setup for the EKS cluster.
4. logs → This folder is automatically created after running the application.
5. .github → Contains the CI/CD pipeline configuration.
6. report-resources → Contains the images for reporting

**GIT REPO**

The repository has two branches: dev and main.

**CICD PIPELINE**

the cicd pipeline
![alt text](report-resources/cicd.png)

**POSTMAN TEST**

1. authentication!
   ![alt text](report-resources/cicd.png)
2. query with valid token
   ![alt text](report-resources/valid-token.png)
3. invalid token
   ![alt text](report-resources/invalid-token.png)

**EKS DEPLOYMENT**

all environment is deployment to eks
![alt text](report-resources/eks-deploy.png)

**SIMPLE API GATEWAY**

![alt text](report-resources/api-gateway.png)