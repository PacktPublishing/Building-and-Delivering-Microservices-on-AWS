## Chapter 14: Extending CodePipeline Beyond AWS
This chapter focused on extending the AWS CodePipeline beyond AWS related infrastructure and services. In this chapter you will learn to integrate code pipeline with Git hub, Bit bucket or other git based remote repositories. This chapter also explains how you can set up to deploy on premises servers with the help of AWS code pipeline.

## Code action

Terraform directory conatins the terraform template to create the infrastructure. aws-code-pipeline directory contains the source code for sample microservice.
* Use `terraform init` to initialize the terraform template.
* Use `terraform plan` to see what all resources will be created using terraform.
* Use `terraform apply --auto-approve` to create the terraform resources in your AWS account.
* Use `terraform destroy --auto-approve` to delete the resources managed by the terraform in your AWS account.
* To create the identity mapping use the command `eksctl create iamidentitymapping \
    --cluster chap-14-eks-cluster \
    --region us-east-1 \
    --arn arn:aws:iam::xxxxxxxxxxxxx:role/chap-14-codebuild-eks-role \
    --group system:masters \
    --no-duplicate-arns \
    --username chap-14-codebuild-eks-role`

### How to build source code
Use `mvn clean install` to build the source code. 
Use `java -j target/aws-code-pipeline*.jar` to run the spring boot application