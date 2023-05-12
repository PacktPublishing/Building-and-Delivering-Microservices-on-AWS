## Chapter 13 Automated Deployment to an EKS Cluster
This chapter focused on understanding Kubernetes and learning about the Elastic Kubernetes service  provided by AWS. In this chapter you will learn about Kubenetes and EKS architecture and different configuration files. This chapter also explains how you can set up CodePipeline to deploy to EKS cluster.


## Code action

Terraform directory conatins the terraform template to create the infrastructure. aws-code-pipeline directory contains the source code for sample microservice.
* Use `terraform init` to initialize the terraform template.
* Use `terraform plan` to see what all resources will be created using terraform.
* Use `terraform apply --auto-approve` to create the terraform resources in your AWS account.
* Use `terraform destroy --auto-approve` to delete the resources managed by the terraform in your AWS account.

### How to build source code
Use `mvn clean install` to build the source code. 
Use `java -j target/aws-code-pipeline*.jar` to run the spring boot application