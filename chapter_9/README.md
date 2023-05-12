## Chapter 9 : Deploying to an EC2 Instance Using CodeDeploy
This chapter explains what AWS CodeDeploy service is and how it can be used to deploy your application to the EC2 instances and on premises servers.This chapter takes a deep dive into different deployment strategies and configurations available to deploy applications.
## Code action

Terraform directory conatins the terraform template to create the infrastructure. aws-code-pipeline directory contains the source code for sample microservice.
* Use `terraform init` to initialize the terraform template.
* Use `terraform plan` to see what all resources will be created using terraform.
* Use `terraform apply --auto-approve` to create the terraform resources in your AWS account.
* Use `terraform destroy --auto-approve` to delete the resources managed by the terraform in your AWS account.

### How to build source code
Use `mvn clean install` to build the source code. 
Use `java -j target/aws-code-pipeline*.jar` to run the spring boot application