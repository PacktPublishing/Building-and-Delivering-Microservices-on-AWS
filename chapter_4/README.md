## Chapter 4 : CI/CD Principles and Microservice Development
This chapter explains what infrastructure as a code and what tools and technologies you can use to provision different resources you require to deploy the sample application in AWS cloud. For this book we will be creating infrastructure using the AWS console, but in this chapter we will explain what all tools are available to you in order to create these resources.

## Code action
### How to use  code
CF_template.json file contains the cloud formation template used in the chapter. Terraform directory conatins the terraform template to create the infrastructure. 
* Use `terraform init` to initialize the terraform template.
* Use `terraform plan` to see what all resources will be created using terraform.
* Use `terraform apply --auto-approve` to create the terraform resources in your AWS account.
* Use `terraform destroy --auto-approve` to delete the resources managed by the terraform in your AWS account.