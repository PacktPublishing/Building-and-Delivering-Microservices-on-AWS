provider "aws" {
  //access_key = "YOUR_ACCESS_KEY"
  // secret_key = "YOUR_SECRET_KEY"
}
// VPC ID , change the VPC ID for your infrastructure
variable "vpc_id" {
  type        = string
  description = "VPC id for your AWS environment"
  default     = "vpc-1a5f0f7d"
}
//List of availability zone where you want to create the infrastructure
variable "availability_zones" {
  type    = list(any)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

// List of subnets within the VPC and where you want to create infrastructure.
variable "subnets" {
  type        = list(any)
  description = "Provide list of subnets"
  default     = ["subnet-5f4d9016", "subnet-1b1af940", "subnet-56502833"]
}

//IAM policy to provide access to update Lambda
resource "aws_iam_policy" "chap_14_code_build_policy" {
  name   = "chap-14-code-build-policy"
  policy = file("eks-role-policy.json")
}

// IAM role used by the code build service to get information from ECR and deploy to kubernetes. 
resource "aws_iam_role" "chap_14_codebuild_eks_role" {
  name               = "chap-14-codebuild-eks-role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "codebuild.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
  //Managed Code Deploy service policy
  managed_policy_arns = [aws_iam_policy.chap_14_code_build_policy.arn,"arn:aws:iam::aws:policy/CloudWatchLogsFullAccess", "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess", "arn:aws:iam::aws:policy/AWSCodeCommitFullAccess", "arn:aws:iam::aws:policy/AmazonS3FullAccess", "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"]
}

resource "aws_iam_role" "chap_14_ecs_cluster_role" {
  name = "chap-14-ecs-cluster-role"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "eks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
managed_policy_arns = [ "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy" ]
}
resource "aws_eks_cluster" "chap_14_eks_cluster" {
  name = "chap-14-eks-cluster"
  role_arn = aws_iam_role.chap_14_ecs_cluster_role.arn
  vpc_config {
    subnet_ids = var.subnets
  }
}

resource "aws_iam_role" "chap_14_ecs_worker_role" {
  name = "chap-14-ecs-worker-role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy","arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy","arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]
}