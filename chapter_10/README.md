## Chapter 10 : Deploying to an ECS Cluster Using Code Deploy
This chapter focused on explaining what an ECS cluster is and how you can use code deploy service to automatically deploy application updates to ECS cluster.   In this chapter we will touch base on containers and ECS service and deploy a sample application to ECS.

## Code action

Terraform directory conatins the terraform template to create the infrastructure. aws-code-pipeline directory contains the source code for sample microservice.
* Use `terraform init` to initialize the terraform template.
* Use `terraform plan` to see what all resources will be created using terraform.
* Use `terraform apply --auto-approve` to create the terraform resources in your AWS account.
* Use `terraform destroy --auto-approve` to delete the resources managed by the terraform in your AWS account.

### How to build source code
Use `mvn clean install` to build the source code. 
Use `java -j target/aws-code-pipeline*.jar` to run the spring boot application