provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "EC2DemoInstance" {
  instance_type = "t2.micro"
  ami = var.aws_ami_id
}

variable "aws_region"{
    type = string
    description = "Provide an aws region to apply the changes."
}

variable "aws_ami_id"{
    type = string
    description = "Provide an aws AMI id to create EC2 instance."
    default = "ami-0ed9277fb7eb570c9"
}

output "demo_instance_ip_address" {
    value = aws_instance.EC2DemoInstance.public_ip
    description = "Public ip of the EC2 isntance."
}