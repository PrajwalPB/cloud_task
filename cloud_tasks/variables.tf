variable instance_ami {
    type = string
    description = "Server image to use"
    default = "ami-0a481e6d13af82399"
}

variable role_name {
  type = string
  description = "test role"
  default = "demorole"
}

variable instance_size {
    type = string
    description = "ec2 web server size"
    default = "t3.micro"
}
variable Name {
  type = string
  default = "newserver"
}
variable policy_name {
  type = string
  default = "demopolicy"
}
variable aws_iam_instance_profile_name {
  type = string
  default = "demoprofile"
}
variable security_group_name {
  type = string
  default = "demosg"
}
