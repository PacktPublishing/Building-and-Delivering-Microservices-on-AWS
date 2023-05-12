## Chapter 6 : Automating code reviews Using CodeGuru
This chapter walks through what AWS Code guru AI service is and how it can be used to automatically review code and scan for vulnerabilities. This chapter walkthrough user step by step to enable code reviews on the sample application repository and how easy it is to enable it on any aws code commit repository.
  

## Code action
aws-code-pipeline directory contains the source code for sample microservice.
### How to build source code
Use `mvn clean install` to build the source code. 
Use `java -j target/aws-code-pipeline*.jar` to run the spring boot application