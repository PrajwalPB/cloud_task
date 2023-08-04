terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.10.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

data "aws_caller_identity" "current" {}
output "account_id" {
  value = data.aws_caller_identity.current.account_id
}


resource "aws_iam_policy" "policy" {
  name        = var.policy_name
  description = "My test policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
    ]
}
EOF
}

resource "aws_iam_role" "role" {
  name = var.role_name

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

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_instance_profile" "profile" {
  name = var.aws_iam_instance_profile_name
  role = aws_iam_role.role.name
}


resource "aws_instance" "prajwal_task" {
   ami           = var.instance_ami
   instance_type = var.instance_size
   key_name = "pbsinga"
   iam_instance_profile = aws_iam_instance_profile.profile.name
   vpc_security_group_ids = [aws_security_group.allow_tls.id]
   ser_data = <<EOF
               #!/bin/bash
               BUCKET=my-s3-bucket-prajwal
               sudo dnf install java-11-amazon-corretto -y
               wget https://dlcdn.apache.org/tomcat/tomcat-8/v8.5.91/bin/apache-tomcat-8.5.91.zip
               sudo unzip apache-tomcat-8.5.91.zip
               sudo mv apache-tomcat-8.5.91 /mnt/tomcat
               KEY=`aws s3 ls $BUCKET --recursive | sort | tail -n 1 | awk '{print $4}'`
               aws s3 cp s3://$BUCKET/$KEY /mnt/tomcat/webapps/
               sudo chmod 0755 /mnt/tomcat/bin/*
               sudo ./bin/catalina.sh start
               EOF

  tags = {
  Name = var.Name
  }
}


resource "aws_security_group" "allow_tls" {
  name        = "demoallow_tls"
  description = "Allow TLS inbound traffic"
  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "TLS1 from VPC"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.security_group_name
  }
}
