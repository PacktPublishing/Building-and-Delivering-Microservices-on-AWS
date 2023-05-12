# Building and Delivering Microservices on AWS: ### Master software architecture patterns to develop and deliver microservices to AWS Cloud
This book provides a step-by-step guide to developing a Java Spring Boot microservice and guides you
through the process of automated deployment using AWS CodePipeline. It starts with an introduction to
software architecture and different architecture patterns, then dives into microservices architecture and
related patterns. This book will also help you to write the source code and commit it to CodeCommit
repositories, review the code using CodeGuru, build artifacts, provision infrastructure using Terraform
and CloudFormation, and deploy using AWS CodeDeploy to Elastic Compute Cloud (EC2) instances,
on-prem instances, ECS services, and Kubernetes clusters.

##  Who this book is for
This book is for software architects, DevOps engineers, site reliability engineers (SREs), and cloud
engineers who want to learn more about automating their release pipelines to modify features and release
updates. Some knowledge of AWS cloud, Java, Maven, and Git will come in handy to get the most out
of this book.
## What this book covers
### Chapter 1 : Software Architecture Patterns
In this chapter, you will learn about software architecture and what makes software architecture. You will learn about software architecture patterns and understand different major software architecture patterns that exist to develop software. After reading this chapter you will have a solid understanding of Layered architecture, Microkernel Archichitecture, Pipeline Architecture, Service Oriented Architecture, Event Driven Architecture, Microservice architecture and other few major architecture patterns. This chapter will discuss the real word examples for each of the architecture patterns.   

### Chapter 2 : Microservices Fundamentals and Design Patterns
This chapter describes what microservice is and how this can be useful to solve some of the software delivery challenges. This chapter explains different strategies and design patterns to break a monolithic application into a microservice. After reading this chapter you will get a fair understanding of microservices and what challenges that brings to the table. In this chapter, you will learn what a monolithic and microservice architecture really means. I will be explaining the different microservice patterns which can help you to design good manageable microservices. 

### Chapter 3 : CI/CD Principles and Microservice Development
In this chapter we create a sample java spring boot application to be deployed as a microservices and expose a rest endpoint to ensure that our users are able to access this endpoint.This chapter explains the different tools and technologies used to develop the application and provide the sample code to users.  

### Chapter 4 : Infrastructure as Code
This chapter explains what infrastructure as a code and what tools and technologies you can use to provision different resources you require to deploy the sample application in AWS cloud. For this book we will be creating infrastructure using the AWS console, but in this chapter we will explain what all tools are available to you in order to create these resources. 

### Chapter 5 : Creating Repositories with AWS CodeCommit
This chapter explains what a version control system is and why we needed it, then it explains about git version control systems and what are the available git based version control systems. This chapter explains AWS CodeCommit service and its benefits and then guides users to create a new code commit repository and guides users to check in sample application code to this newly created repository. 

### Chapter 6 : Automating code reviews Using CodeGuru
This chapter walks through what AWS Code guru AI service is and how it can be used to automatically review code and scan for vulnerabilities. This chapter walkthrough user step by step to enable code reviews on the sample application repository and how easy it is to enable it on any aws code commit repository.

### Chapter 7 : Managing Artifacts Using CodeArtifact
This chapter explains to the reader about AWS CodeArtifact service , their usage and benefits. This chapter walks through users about different generated artifacts and how they can be securely stored with code Artifact.  

### Chapter 8 : Building and Testing Using AWS CodeBuild
This chapter focuses on the AWS code build service and explains the benefits of using this serveless service. This chapter explains  about buildspec.yml file and how it can be used to customize build and code testing process.This chapter also deep dive into how you can extend the AWS code build service with your custom docker images. 
### Chapter 9 : Deploying to an EC2 Instance Using CodeDeploy
This chapter explains what AWS CodeDeploy service is and how it can be used to deploy your application to the EC2 instances and on premises servers.This chapter takes a deep dive into different deployment strategies and configurations available to deploy applications.
### Chapter 10 : Deploying to an ECS Cluster Using Code Deploy
This chapter focused on explaining what an ECS cluster is and how you can use code deploy service to automatically deploy application updates to ECS cluster.   In this chapter we will touch base on containers and ECS service and deploy a sample application to ECS.
### Chapter 11 : Setting Up CodePipeline
This chapter explains what is code pipeline and how it can help us to orcharatetrate other aws services to set up continuous development and delivery of the software. This chapter covers how AWS CodeCommit , CodeBuild and CodeDeploy services create a pipeline to deliver automated software releases.

### Chapter 12 Setting Up Automated Serverless Deployment
This chapter focused on setting up a CodePipeline for the serverless deployment. This chapter introduced you  to serveless ecosystems and how AWS provides scalable solutions through Lambda and how you can set up automated serverless Lambda deployment.

## Chapter 13 Automated Deployment to an EKS Cluster
This chapter focused on understanding Kubernetes and learning about the Elastic Kubernetes service  provided by AWS. In this chapter you will learn about Kubenetes and EKS architecture and different configuration files. This chapter also explains how you can set up CodePipeline to deploy to EKS cluster.

### Chapter 14: Extending CodePipeline Beyond AWS
This chapter focused on extending the AWS CodePipeline beyond AWS related infrastructure and services. In this chapter you will learn to integrate code pipeline with Git hub, Bit bucket or other git based remote repositories. This chapter also explains how you can set up to deploy on premises servers with the help of AWS code pipeline.
### Chapter 15: Appendix
This chapter focuses on creating Identity and Access Management (IAM) users and tools needed for the application development such as Docker Desktop, Git, and Maven, which are important but not part of the core chapters.

## Download the example code files
You can download the example code files for this book from GitHub at https://github.com/PacktPublishing/Delivering-Microservices-with-AWS. If there’s an update to the code, it will be updated in the GitHub repository.
![Building and Delivering Microservices on AWS](Delivering.png)