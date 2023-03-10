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
resource "aws_iam_role" "chapter-11_code_deploy_service_role" {
  name = "chapter-11_code_deploy_service_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codedeploy.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess", "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess", "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"]
}
/**
* Code deploy service role for code build to ECS and load data from S3
*/
resource "aws_iam_role" "chapter-11_code_build_service_role" {
  name = "chapter-11_code_build_service_role"
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
  managed_policy_arns = ["arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess", "arn:aws:iam::aws:policy/AmazonS3FullAccess", "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds", "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"]
}



/**
* Application Load Balancer to front face traffic for the ECS service
*/
resource "aws_alb" "chapter-11_alb" {
  name               = "chapter-11-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.chapter-11_lb_sg.id]
  subnets            = var.subnets
}

/**
* Application Load Balancer listener to connect on port 80
*/
resource "aws_alb_listener" "chapter-11_alb_listner" {
  load_balancer_arn = aws_alb.chapter-11_alb.arn
  port              = 80
  default_action {
    target_group_arn = aws_alb_target_group.chapter-11_blue_alb_tgt_group.arn
    type             = "forward"
  }
}
/**
* Application load balancer BLUE target group for ECS
*/
resource "aws_alb_target_group" "chapter-11_blue_alb_tgt_group" {
  port        = 80
  target_type = "ip"
  vpc_id      = var.vpc_id
  name        = "chapter-11-blue-alb-tgt-group"
  protocol    = "HTTP"
  health_check {
    protocol = "HTTP"
    path     = "/"
  }
}


/**
* Application load balancer GREEN target group for ECS
*/

resource "aws_alb_target_group" "chapter-11_green_alb_tgt_group" {
  port        = 80
  target_type = "ip"
  vpc_id      = var.vpc_id
  name        = "chapter-11-green-alb-tgt-group"
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
/*
resource "aws_alb_listener" "chapter-11_green_alb_listner" {
  load_balancer_arn = aws_alb.chapter-11_alb.arn
  port              = 8080
  default_action {
    target_group_arn = aws_alb_target_group.chapter-11_green_alb_tgt_group.arn
    type             = "forward"
  }
}
*/

/**
* Security group for Load Balancer to provide access to 
* http traffic on port 80 and 8080
*
*/
resource "aws_security_group" "chapter-11_lb_sg" {
  description = "Security group for load balancer Http access"
  name        = "chapter-11-load-balancer-security-group"
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
resource "aws_ecs_cluster" "chapter-11_ecs_cluster" {
  name = "chapter-11_ecs_cluster"
  tags = {
    resource-group = "chapter-11"
  }
}

/*
* ECS Cluster capacity providers, set to AWS FARGATE
*/
resource "aws_ecs_cluster_capacity_providers" "chapter-11_ecs_capacity_providers" {
  cluster_name       = aws_ecs_cluster.chapter-11_ecs_cluster.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  default_capacity_provider_strategy {
    base              = 0
    weight            = 1
    capacity_provider = "FARGATE"
  }
}

/**
*   ECS Task definition to define containers mage, port mapping, image and FARGATE capabilities
*/

resource "aws_ecs_task_definition" "chapter-11_task_definition" {
  family                   = "chapter-11_task_definition"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 3072
  execution_role_arn       = "arn:aws:iam::279522866734:role/ecsTaskExecutionRole"
  container_definitions = jsonencode([
    {
      name      = "chapter-11_aws_code_pipeline_container"
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
resource "aws_ecs_service" "chapter-11_ecs_service" {
  name            = "chapter-11_ecs_service"
  cluster         = aws_ecs_cluster.chapter-11_ecs_cluster.id
  task_definition = aws_ecs_task_definition.chapter-11_task_definition.arn
  desired_count   = 1
  deployment_controller {
    type = "CODE_DEPLOY"
  }

  network_configuration {
    security_groups  = [aws_security_group.chapter-11_lb_sg.id]
    subnets          = var.subnets
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.chapter-11_blue_alb_tgt_group.arn
    container_name   = "chapter-11_aws_code_pipeline_container"
    container_port   = "80"
  }
}


/**
* AWS CODE DEPLOY Application for deployment to ECS
*/
resource "aws_codedeploy_app" "chapter-11_code_deploy_app" {
  name             = "chapter-11_code_deploy_app"
  compute_platform = "ECS"
}

resource "aws_codebuild_project" "chapter-11_code_maven_build" {
  name         = "chapter-11_code_maven_build"
  service_role = aws_iam_role.chapter-11_code_build_service_role.arn
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

resource "aws_codebuild_project" "chapter-11_docker_build" {
  name         = "chapter-11_docker_build"
  service_role = aws_iam_role.chapter-11_code_build_service_role.arn
  description  = "Code build project to generate the docker image."

  artifacts {
    type      = "CODEPIPELINE"
    packaging = "NONE"
    location  = "s3://codepipeline-us-east-1-492193347648/test-2/"
    path      = "chapter-11_docker_build"
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = "docker_buildspec.yml"
  }
  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    type            = "LINUX_CONTAINER"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    privileged_mode = true
  }
}

resource "aws_codedeploy_deployment_group" "chapter-11_code_deploy_group" {
  app_name               = aws_codedeploy_app.chapter-11_code_deploy_app.name
  deployment_group_name  = "chapter-11_code_deploy_group"
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  service_role_arn       = aws_iam_role.chapter-11_code_deploy_service_role.arn

  ecs_service {
    service_name = aws_ecs_service.chapter-11_ecs_service.name
    cluster_name = aws_ecs_cluster.chapter-11_ecs_cluster.name
  }
  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }
  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }
    terminate_blue_instances_on_deployment_success {
      termination_wait_time_in_minutes = 5
      action                           = "TERMINATE"
    }
  }
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_alb_listener.chapter-11_alb_listner.arn]
      }
      target_group {
        name = aws_alb_target_group.chapter-11_blue_alb_tgt_group.name
      }
      target_group {
        name = aws_alb_target_group.chapter-11_green_alb_tgt_group.name
      }
    }
  }
}







// IAM role used by the EC2 aws instance to be assumed to connect to S3 to download package
resource "aws_iam_role" "chapter_11_test_env_deploy_agent_role" {
  name               = "chapter_11_test_env_deploy_agent_role"
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



//IAM policy to provide access to S3
resource "aws_iam_policy" "chapter_11_test_env_deploy_policy" {
  name   = "chapter-11-test-env-deploy-policy"
  policy = file("code-deploy-policy.json")
}

//IAM EC2 Role and S3 Policy association
resource "aws_iam_policy_attachment" "chapter_11_test_env_deploy_policy_attach" {
  name       = "chapter-11-deploy-policy-attach"
  policy_arn = aws_iam_policy.chapter_11_test_env_deploy_policy.arn
  roles      = [aws_iam_role.chapter_11_test_env_deploy_agent_role.name]
}

// IAM instance profile to attache the code deploy agent role
resource "aws_iam_instance_profile" "chapter_11_test_env_instance_profile" {
  name = "chapter_11_test_env_deploy_instance_profile"
  role = aws_iam_role.chapter_11_test_env_deploy_agent_role.name
}

// EC2 Auto scalling Group 
resource "aws_autoscaling_group" "chapter_11_test_env_asg" {
  name               = "chapter-11_test_asg"
  min_size           = 1
  max_size           = 2
  desired_capacity   = 2
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  launch_template {
    id      = aws_launch_template.chapter_11_test_env_ec2_launch_template.id
    version = "$Latest"
  }
  health_check_type = "ELB"
}

//EC2 Launch template to create EC2 instances , change Image ID and key name 
resource "aws_launch_template" "chapter_11_test_env_ec2_launch_template" {
  instance_type = "t2.micro"
  image_id      = "ami-0ed9277fb7eb570c9"
  name          = "chapter-11-ec2-launch-template"
  key_name      = "packt_key"
  iam_instance_profile {
    name = aws_iam_instance_profile.chapter_11_test_env_instance_profile.name
  }
  security_group_names = [aws_security_group.chapter-11_lb_sg.name]
  user_data            = filebase64("user_data.sh")
}

// EC2 Load Balancer 
resource "aws_alb" "chapter_11_test_env_alb" {
  name               = "chapter-11-test-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.chapter-11_lb_sg.id]
  subnets            = var.subnets
}

//Application Load Balancer listener to connect on port 80
resource "aws_alb_listener" "chapter_11_test_env_alb_listner" {
  load_balancer_arn = aws_alb.chapter_11_test_env_alb.arn
  port              = 80
  default_action {
    target_group_arn = aws_alb_target_group.chapter_11_test_env_alb_tgt_group.arn
    type             = "forward"
  }
}

// Aapplication load balancer target group , to detect EC2 instances running on port 80
resource "aws_alb_target_group" "chapter_11_test_env_alb_tgt_group" {
  port        = 80
  target_type = "instance"
  vpc_id      = var.vpc_id
  name        = "chapter-11-test-alb-tgt-group"
  protocol    = "HTTP"
  health_check {
    protocol = "HTTP"
    path     = "/"
  }
}

// Security group for EC2 instance to provide access to http,https and ssh port 
/*resource "aws_security_group" "chapter_11_test_env_ins_sg" {
  description = "security group for http/https and ssh access"
  name        = "chapter-11-instance-security-group"
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
}*/

resource "aws_codedeploy_app" "chapter_11_test_env_app" {
  compute_platform = "Server"
  name             = "chapter_11_test_env_app"
}

resource "aws_codedeploy_deployment_group" "chapter_11_test_env_deploy_group" {
  deployment_group_name = "chapter_11_test_env_deploy_group"
  app_name              = aws_codedeploy_app.chapter_11_test_env_app.name
  service_role_arn      = aws_iam_role.chapter-11_code_deploy_service_role.arn
  autoscaling_groups    = [aws_autoscaling_group.chapter_11_test_env_asg.name]
  deployment_style {
    deployment_type = "IN_PLACE"
  }
  load_balancer_info {
    target_group_info {
      name = aws_alb.chapter_11_test_env_alb.name
    }
  }
}


