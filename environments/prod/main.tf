resource "aws_instance" "web_server" {
  ami           = "ami-abc123"
  instance_type = "t3.micro"
}