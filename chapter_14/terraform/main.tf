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

resource "aws_iam_user" "chap_14_on_prem_user" {
    name = "chap-14-on-prem-user"
}
resource "aws_iam_user_policy_attachment" "attach_code_deploy" {
  user       = aws_iam_user.chap_14_on_prem_user.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess"
}

resource "aws_iam_user_policy_attachment" "attach_s3_access" {
  user       = aws_iam_user.chap_14_on_prem_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

// IAM role used by the code deploy service to EC2 instances. 
resource "aws_iam_role" "chap_14_pipeline_role" {
  name                = "chap-14-pipeline-role"
  assume_role_policy  = <<EOF
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
//Managed Code Deploy service policy
  managed_policy_arns = ["arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess","arn:aws:iam::aws:policy/AmazonS3FullAccess"]
}

// IAM instance profile to attache the code deploy agent role
resource "aws_iam_instance_profile" "chap_14_instance_profile" {
  name = "chap_14_deploy_instance_profile"
  role = aws_iam_role.chap_14_pipeline_role.name
}

// EC2 Auto scalling Group 
resource "aws_autoscaling_group" "chap_14_asg" {
  name               = "chap-14_asg"
  min_size           = 1
  max_size           = 1
  desired_capacity   = 1
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  launch_template {
    id      = aws_launch_template.chap_14_ec2_launch_template.id
    version = "$Latest"
  }
  health_check_type = "ELB"
}

//EC2 Launch template to create EC2 instances , change Image ID and key name 
resource "aws_launch_template" "chap_14_ec2_launch_template" {
  instance_type = "t2.micro"
  image_id      = "ami-0ed9277fb7eb570c9"
  name          = "chap_14-ec2-launch-template"
  key_name      = "packt_key"
  iam_instance_profile {
    name = aws_iam_instance_profile.chap_14_instance_profile.name
  }
  security_group_names = [aws_security_group.chap_14_ins_sg.name]
  user_data = filebase64("user_data.sh")
}


// Security group for EC2 instance to provide access to http,https and ssh port 
resource "aws_security_group" "chap_14_ins_sg" {
  description = "security group for http/https and ssh access"
  name        = "chap_14-instance-security-group"
  ingress {
    description = "Http access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  } 
  ingress {
    description = "Http access"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ssh address"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// Service role used by the code deploy service to On-prem instances. 
resource "aws_iam_role" "chap_14_code_deploy_role" {
  name                = "chap-14-code-deploy-role"
  assume_role_policy  = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "codedeploy.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
//Managed Code Deploy service policy
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole","arn:aws:iam::aws:policy/AmazonS3FullAccess"]
}

/**
* AWS CODE DEPLOY Application for deployment to On_Prem Instance provider= linode_server_2
*/
resource "aws_codedeploy_app" "chap-14-on-prem-code-deploy" {
  name             = "chap-14-on-prem-code-deploy"
  compute_platform = "Server"
}

/**
* AWS CODE DEPLOY Deployment Group to deploy to On prem instance with tage 
*/
resource "aws_codedeploy_deployment_group" "chap-14-on-prem-deploy-group" {
  app_name               = aws_codedeploy_app.chap-14-on-prem-code-deploy.name
  deployment_group_name  = "chap-14-on-prem-deploy-group"
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
  service_role_arn       = aws_iam_role.chap_14_code_deploy_role.arn

 on_premises_instance_tag_filter {
   key = "provider"
   type = "KEY_AND_VALUE"
   value = "linode_2"
 }
}