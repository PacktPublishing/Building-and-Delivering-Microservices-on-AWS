## Chapter 8 : Building and Testing Using AWS CodeBuild
This chapter focuses on the AWS code build service and explains the benefits of using this serveless service. This chapter explains  about buildspec.yml file and how it can be used to customize build and code testing process.This chapter also deep dive into how you can extend the AWS code build service with your custom docker images. 

## Code action
aws-code-pipeline directory contains the source code for sample microservice.
### How to build source code
Use `mvn clean install` to build the source code. 
Use `java -j target/aws-code-pipeline*.jar` to run the spring boot application