resource "aws_instance" "example" {
  ami           = "ami-0f34c5ae932e6f0e4"
  instance_type = "t2.micro"
  tags = {
    Name = "first-instance"
  }
}