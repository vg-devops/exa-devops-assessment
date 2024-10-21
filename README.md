# DevOps / Site Reliability Engineer - Technical Assessment
Our tech teams are curious, driven, intelligent, pragmatic, collaborative and open-minded and you should be too.
## Testing Goals
We think infrastructure is best represented as code, and provisioning of resources should be automated as much as possible.	We are testing your ability to implement modern automated infrastructure, as well as general knowledge of operations. In your solution you should emphasize readability, security, maintainability and DevOps methodologies.

## The Task
Your task is to create a CI/CD pipeline that deploys this web application to a load-blanced environment on AWS Fargate / EKS.

You will have approximately 1 week to complete this task and should focus on an MVP but you are free to take this as far as you wish.
## The Solution
You should create the infrastructure you need using Terraform or another Infrastructure as Code tool. You can use any CI/CD system you feel comfortable with (e.g. Jenkins/Circle/etc) with but the team have a preferences for GitHub actions.

Your CI Job should:
- Run when a feature branch is pushed to Github (you should fork this repository to your own Github account).
- Deploy to a target environment when the job is successful.
- The target environment should consist of:
  - A load-balancer accessible via HTTP on port 80.
- The load-balancer should use a round-robin strategy.

**We recommend staying within the free AWS tiers so you don't incur costs as unfortunately these can't be reimbursed**
 ## The Provided Code
 This is a NodeJS application:

- `npm test` runs the application tests
- `npm start` starts the http server

## When you are finished
Create a public Github repository and push your solution including any documentation you feel necessary. Commit often - we would rather see a history of trial and error than a single monolithic push. When you're finished, please send us the URL to the repository.

## Assessment Information

This repository contains the dockerised version of the application running in EKS Fargate environment that was provisioned via IaC (terraform) explained thereafter.
To provide consistent application operation and package installation, -lock.json file was generated. Therefore, the packages are being installed using "npm ci" command, rather than "npm install". Both docker and pipeline installation use the same versions of node/npm as build/running environment to ensure consistency. The dockerised version of the application launched as a non-priveleged user to reduce attack surface/follow least privelege principles. Repository includes 2 GitHub actions pipelines called: BUILD and DEPLOYMENT respectively. 
  a. Pipelines were parametrised with secrets to hide sensitive data.
  b. Build pipeline installs and tests the application
  c. Build pipeline builds docker image, produces its tag and save its tag to artifact, pushes image to AWS ECR.
  d. Deployment pipeline picks the artifact from the latest build and uses it to deploy 
  the application onto Fargate Profile. The user can chose the target deployment environment (assumed 4 dummy env's like: development/testing/staging/production) Deployment utilises K8S yaml template that is being converted to manifest by populating some values from env vars/secrets. Manifest inc deployment, service and ingress object. The latter controls App Load Balancer listening to port 80 (see the attached vide file that proves it from command line when response from the app changes at each request being sent to it, round robin algo by default). 

The complete solution includes 3 repositories. Besides this repository you can check these 2 infrastructure repositories:
  1. https://github.com/vg-devops/infrastructure-main
  2. https://github.com/vg-devops/infrastructure-eks

infrastructure-main contains code required for provisioning of VPC (based on default/related aws module), some related IAM roles/ecr-user - the latter is utilised in the pipelines above. It also provides bastion instance for access of ec2 instances/databases(future) operating in private subnets. Some resource outputs are produced that are utilised by infrastructure-eks repository

infrastructure-eks contains code required for provisioning of EKS cluster, inc Fargate Profile and EC2 node group. Helm chart for AWS Load Balancer Controller, Amendments to the existing "aws-auth" config map for ecr-user to be able to manipulate K8S resources, a number of relevant IAM roles (e.g. role for ALB controller, eks cluster role, fargate pod execution role etc). It demonstrates usage of different providers, like: aws, helm, kubernetes. 

Although, I was trying to adhere to principles of Least Privelege when creating the roles, users etc, both infrastructure repositories may still be improved. AWS Account ID can be parametrised to be able to pick up backend in different aws s3 buckets (pipeline managed), instead of using certain Terraform service user we could utilise the assumed role while the user with min privilege can be located in a sep aws account. VPC can be equipped with more security groups to reduce attack surface. Besides, access to control plane can be made private from bastion server(s) only. For production env't even access to bastions can be organised from AWS Console only without direct ssh access thus mitigating the risk of bulk copying database data. ECR access can also be made private from VPC service endpoint.
