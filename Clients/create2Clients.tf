provider "aws" {
    region = "eu-north-1"
}

resource "aws_instance" "Client1" {
  ami           = "ami-01dad638e8f31ab9a"
  instance_type = "t3.micro"
   tags = {
    Name = "Clients"
  }
}

resource "aws_instance" "Client2" {
  ami           = "ami-01dad638e8f31ab9a"
  instance_type = "t3.micro"
   tags = {
    Name = "Clients"
  }
}