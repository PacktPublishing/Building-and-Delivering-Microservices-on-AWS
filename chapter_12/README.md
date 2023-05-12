## Chapter 12 Setting Up Automated Serverless Deployment
This chapter focused on setting up a CodePipeline for the serverless deployment. This chapter introduced you  to serveless ecosystems and how AWS provides scalable solutions through Lambda and how you can set up automated serverless Lambda deployment.

## Code action

Terraform directory conatins the terraform template to create the infrastructure. aws-code-pipeline directory contains the source code for sample microservice.
* Use `terraform init` to initialize the terraform template.
* Use `terraform plan` to see what all resources will be created using terraform.
* Use `terraform apply --auto-approve` to create the terraform resources in your AWS account.
* Use `terraform destroy --auto-approve` to delete the resources managed by the terraform in your AWS account.

### How to build source code
Use `mvn clean install` to build the source code. 