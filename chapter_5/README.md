## Chapter 5 : Creating Repositories with AWS CodeCommit
This chapter explains what a version control system is and why we needed it, then it explains about git version control systems and what are the available git based version control systems. This chapter explains AWS CodeCommit service and its benefits and then guides users to create a new code commit repository and guides users to check in sample application code to this newly created repository.   

## Code action
aws-code-pipeline directory contains the source code for sample microservice.
### How to build source code
Use `mvn clean install` to build the source code. 
Use `java -j target/aws-code-pipeline*.jar` to run the spring boot application