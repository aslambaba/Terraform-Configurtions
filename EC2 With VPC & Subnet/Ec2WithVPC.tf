provider "aws" {
  region     = "REGION"
  access_key = "ACCESS KEY"
  secret_key = "SECRET KEY"
}

resource "aws_vpc" "MainVPC" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "MainVPC"
  }
}

resource "aws_subnet" "MainSubnet" {
  vpc_id = aws_vpc.MainVPC.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "MainSubnet"
  }
  availability_zone = "ap-south-1a"
}

resource "aws_instance" "TerraEC2" {
    ami = "ami-0cfedf42e63bba657"
    instance_type = "t2.micro"
    tags = {
        Name = "TerraEC2Instance"
    }
    subnet_id = aws_subnet.MainSubnet.id
}