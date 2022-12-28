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
  default = ["us-east-1a", "us-east-1b", "us-east-1c","us-east-1d","us-east-1e"]
}

/*
* List of subnets within the VPC and where you want to create infrastructure.
*/ 
variable "subnets" {
  type        = list(any)
  description = "Provide list of subnets"
  default     = ["subnet-5f4d9016", "subnet-1b1af940", "subnet-56502833"]
}

/**
* Container image URI for deployment
*/ 
variable "container_image_uri" {
  type        = string
  description = "Please provide ECR container image URI for deployment"
  default     = "279522866734.dkr.ecr.us-east-1.amazonaws.com/packt-ecr-repo:aws-code-pipeline"
}

/**
* Code deploy service role for deployment to ECS and load data from S3
*/
resource "aws_iam_role" "chap_10_code_deploy_service_role" {
  name                = "chap_10_code_deploy_service_role"
  assume_role_policy = jsonencode({
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
})
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess", "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess", "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"]
}

/**
* Application Load Balancer to front face traffic for the ECS service
*/ 
resource "aws_alb" "chap_10_alb" {
  name               = "chap-10-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.chap_10_lb_sg.id]
  subnets            = var.subnets
}

/**
* Application Load Balancer listener to connect on port 80
*/
resource "aws_alb_listener" "chap_10_alb_listner" {
  load_balancer_arn = aws_alb.chap_10_alb.arn
  port              = 80
  default_action {
    target_group_arn = aws_alb_target_group.chap_10_blue_alb_tgt_group.arn
    type             = "forward"
  }
}
/**
* Application load balancer BLUE target group for ECS
*/ 
resource "aws_alb_target_group" "chap_10_blue_alb_tgt_group" {
  port        = 80
  target_type = "ip"
  vpc_id      = var.vpc_id
  name        = "chap-10-blue-alb-tgt-group"
  protocol    = "HTTP"
  health_check {
    protocol = "HTTP"
    path     = "/"
  }
}


/**
* Application load balancer GREEN target group for ECS
*/ 
resource "aws_alb_target_group" "chap_10_green_alb_tgt_group" {
  port        = 80
  target_type = "ip"
  vpc_id      = var.vpc_id
  name        = "chap-10-green-alb-tgt-group"
  protocol    = "HTTP"
  health_check {
    protocol = "HTTP"
    path     = "/"
  }
}

/**
* Application Load Balancer TEST listener to connect on port 8080 
* to test traffic before live.
*
*/
/*resource "aws_alb_listener" "chap_10_green_alb_listner" {
  load_balancer_arn = aws_alb.chap_10_alb.arn
  port              = 8080
  default_action {
    target_group_arn = aws_alb_target_group.chap_10_green_alb_tgt_group.arn
    type             = "forward"
  }
}*/

/**
* Security group for Load Balancer to provide access to 
* http traffic on port 80 and 8080
*
*/ 
resource "aws_security_group" "chap_10_lb_sg" {
  description = "Security group for load balancer Http access"
  name        = "chap_10-load-balancer-security-group"
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
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

/*
*
* ECS Cluster configuration
*/
resource "aws_ecs_cluster" "chap_10_ecs_cluster" {
  name = "chap_10_ecs_cluster"
  tags = {
  resource-group="chap_10"
  }
}

/*
* ECS Cluster capacity providers, set to AWS FARGATE
*/
resource "aws_ecs_cluster_capacity_providers" "chap_10_ecs_capacity_providers" {
  cluster_name=aws_ecs_cluster.chap_10_ecs_cluster.name
    capacity_providers = ["FARGATE","FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base = 0
    weight = 1
    capacity_provider = "FARGATE" 
  }
}

/**
*   ECS Task definition to define containers mage, port mapping, image and FARGATE capabilities
*/
resource "aws_ecs_task_definition" "chap_10_task_definition" {
  family = "chap_10_task_definition"
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu = 512
  memory    = 3072
  execution_role_arn = "arn:aws:iam::279522866734:role/ecsTaskExecutionRole"
  container_definitions = jsonencode([
    {
      name      = "chap_10_aws_code_pipeline_container"
      image     = var.container_image_uri
      cpu       = 512
      memory    = 3072
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
])
}

/**
* ECS Service configuration to run the tasks behind the load balancer and CODE_DEPLOY controller
*/
resource "aws_ecs_service" "chap_10_ecs_service" {
  name = "chap_10_ecs_service"
  cluster = aws_ecs_cluster.chap_10_ecs_cluster.id
  task_definition = aws_ecs_task_definition.chap_10_task_definition.arn
  desired_count = 1
  deployment_controller {
    type = "CODE_DEPLOY"
  }
  
  network_configuration {
    security_groups = [aws_security_group.chap_10_lb_sg.id]
    subnets = var.subnets
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.chap_10_green_alb_tgt_group.arn
    container_name = "chap_10_aws_code_pipeline_container"
    container_port = "80"
  }
}


/**
* AWS CODE DEPLOY Application for deployment to ECS
*/
resource "aws_codedeploy_app" "chap_10_code_deploy_app" {
  name = "chap_10_code_deploy_app"
  compute_platform = "ECS"
}