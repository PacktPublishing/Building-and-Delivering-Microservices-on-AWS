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

// IAM role used by the EC2 aws instance to be assumed to connect to S3 to download package
resource "aws_iam_role" "chapter_9_deploy_agent_role" {
  name               = "chapter_9_deploy_agent_role"
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ec2.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

// IAM role used by the code deploy service to EC2 instances. 
resource "aws_iam_role" "chapter_9_deployer_role" {
  name                = "chapter-10-deployer-role"
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
       te }
    ]
}
EOF
//Managed Code Deploy service policy
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"]
}

//IAM policy to provide access to S3
resource "aws_iam_policy" "chapter_9_deploy_policy" {
  name   = "chapter-10-deploy-policy"
  policy = file("code-deploy-policy.json")
}

//IAM EC2 Role and S3 Policy association
resource "aws_iam_policy_attachment" "chapter_9_deploy_policy_attach" {
  name       = "chapter-10-deploy-policy-attach"
  policy_arn = aws_iam_policy.chapter_9_deploy_policy.arn
  roles      = [aws_iam_role.chapter_9_deploy_agent_role.name]
}

// IAM instance profile to attache the code deploy agent role
resource "aws_iam_instance_profile" "chapter_9_instance_profile" {
  name = "chapter_9_deploy_instance_profile"
  role = aws_iam_role.chapter_9_deploy_agent_role.name
}

// EC2 Auto scalling Group 
resource "aws_autoscaling_group" "chapter_9_asg" {
  name               = "chapter9_asg"
  min_size           = 1
  max_size           = 2
  desired_capacity   = 2
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  launch_template {
    id      = aws_launch_template.chapter_9_ec2_launch_template.id
    version = "$Latest"
  }
  health_check_type = "ELB"
}

//EC2 Launch template to create EC2 instances , change Image ID and key name 
resource "aws_launch_template" "chapter_9_ec2_launch_template" {
  instance_type = "t2.micro"
  image_id      = "ami-0ed9277fb7eb570c9"
  name          = "chapter-10-ec2-launch-template"
  key_name      = "packt_key"
  iam_instance_profile {
    name = aws_iam_instance_profile.chapter_9_instance_profile.name
  }
  security_group_names = [aws_security_group.chapter_9_ins_sg.name]
  user_data = filebase64("user_data.sh")
}

// EC2 Load Balancer 
resource "aws_alb" "chapter_9_alb" {
  name               = "chapter-10-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.chapter_9_lb_sg.id]
  subnets            = var.subnets
}

//Application Load Balancer listener to connect on port 80
resource "aws_alb_listener" "chapter_9_alb_listner" {
  load_balancer_arn = aws_alb.chapter_9_alb.arn
  port              = 80
  default_action {
    target_group_arn = aws_alb_target_group.chapter_9_alb_tgt_group.arn
    type             = "forward"
  }
}

// Aapplication load balancer target group , to detect EC2 instances running on port 80
resource "aws_alb_target_group" "chapter_9_alb_tgt_group" {
  port        = 80
  target_type = "instance"
  vpc_id      = var.vpc_id
  name        = "chapter-10-alb-tgt-group"
  protocol    = "HTTP"
  health_check {
    protocol = "HTTP"
    path     = "/"
  }
}

// Security group for EC2 instance to provide access to http,https and ssh port 
resource "aws_security_group" "chapter_9_ins_sg" {
  description = "security group for http/https and ssh access"
  name        = "chapter-10-instance-security-group"
  ingress {
    description = "Http access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Https access"
    from_port   = 443
    to_port     = 443
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

// Security group for Load Balancer to provide access to http traffic on port 80
resource "aws_security_group" "chapter_9_lb_sg" {
  description = "Security group for load balancer Http access"
  name        = "chapter-10-load-balancer-security-group"
  ingress {
    description = "Http access"
    from_port   = 80
    to_port     = 80
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

// Chapter_10 specific setting 

resource "aws_ecs_cluster" "chapter_10_ecs_cluster" {
  name = "chapter_10_ecs_cluster"
  tags = {
  resource-group=chapter-10
  }
}

resource "aws_ecs_capacity_provider" "chapter_10_ecs_capacity_provider" {
  name="chapter_10_ecs_capacity_provider"
}

resource "aws_ecs_cluster_capacity_providers" "chapter_10_ecs_capacity_providers" {
  cluster_name=aws_ecs_cluster.chapter_10_ecs_cluster.name
  capacity_providers = ["FARGATE","FARGATE_SPOT"]
}
