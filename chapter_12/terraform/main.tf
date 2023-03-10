provider "aws" {
  //access_key = "YOUR_ACCESS_KEY"
  // secret_key = "YOUR_SECRET_KEY"
}

/*
* VPC ID , change the VPC ID for your infrastructure
*/
variable "vpc_id" {
  type        = string
  description = "VPC id for your AWS environment"
  default     = "vpc-1a5f0f7d"
}

/*
* List of availability zone where you want to create the infrastructure
*/
variable "availability_zones" {
  type    = list(any)
  default = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e"]
}

/*
* List of subnets within the VPC and where you want to create infrastructure.
*/
variable "subnets" {
  type        = list(any)
  description = "Provide list of subnets"
  default     = ["subnet-5f4d9016", "subnet-1b1af940", "subnet-56502833"]
}

//IAM policy to provide access to update Lambda
resource "aws_iam_policy" "chapter_12_code_build_policy" {
  name   = "chapter-12-code-build-policy"
  policy = file("code_build_policy.json")
}

/**
* Lambda service role
*/
resource "aws_iam_role" "chapter-12_lambda_service_role" {
  name = "chapter-12_lambda_service_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
}
/**
* Code deploy service role for code build to ECS and load data from S3
*/
resource "aws_iam_role" "chapter-12_code_build_service_role" {
  name = "chapter-12_code_build_service_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codebuild.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  managed_policy_arns = [aws_iam_policy.chapter_12_code_build_policy.arn, "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess", "arn:aws:iam::aws:policy/AmazonS3FullAccess", "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRoleForLambda", "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"]
}

/**
* Code_build_project to build and deploy lambda function.
*/
resource "aws_codebuild_project" "chapter-12_code_build" {
  name         = "chapter-12_code_build"
  service_role = aws_iam_role.chapter-12_code_build_service_role.arn
  description  = "Code build project to run the maven build and generate java artifacts"
  artifacts {
    type = "CODEPIPELINE"
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    type         = "LINUX_CONTAINER"
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
  }
}

resource "aws_lambda_function" "chapter_12_lambda_function" {
  function_name = "chapter_12_lambda_function"
  role = aws_iam_role.chapter-12_lambda_service_role.arn
  filename = "aws-lambda-pipeline-1.0-SNAPSHOT.jar"
  handler = "com.packt.aws.books.pipeline.awslambdapipeline.CreateEmployeeHandler::handleRequest"
  runtime = "java11"
}