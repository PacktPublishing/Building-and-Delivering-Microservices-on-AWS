#!/bin/bash
sudo yum update -y
cd /home/ec2-user
sudo amazon-linux-extras install java-openjdk11 -y
sudo yum install maven -y
wget https://get.jenkins.io/war-stable/2.375.3/jenkins.war
java -jar jenkins.war
