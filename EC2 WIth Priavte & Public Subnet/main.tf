provider "aws" {
  access_key = "ACCESS KEY"
  secret_key = "SECRET KEY"
  region = "ap-south-1"
}

// Create VPC
resource "aws_vpc" "PersonalVPC" {
  cidr_block = "10.0.0.0/16"
  tags = {
      Name = "AslamVPC"
  }
}

// Create Public Subnet in that VPC
resource "aws_subnet" "AslamPublicSubnet" {
  cidr_block = "10.0.0.0/24"
  tags = {
    "Name" = "Aslam Public Subnet"
  }
  vpc_id = aws_vpc.PersonalVPC.id
  availability_zone = "ap-south-1a"
}

// Create Privte Subnet in that VPC
resource "aws_subnet" "AslamPrivateSubnet" {
  cidr_block = "10.0.1.0/24"
  tags = {
    "Name" = "Aslam private Subnet"
  }
  vpc_id = aws_vpc.PersonalVPC.id
  availability_zone = "ap-south-1b"
}

// Create Internet Gateway for Private Subnet
resource "aws_internet_gateway" "AslamIGW" {
  tags = {
    "Name" = "AslamIGW"
  }
  vpc_id = aws_vpc.PersonalVPC.id
}

// Create Elastic IP for Nat Gateway
resource "aws_eip" "AslamEIP" {
  tags = {
    "Name" = "AslamEIP"
  }
}

// Create NAT Gateway
resource "aws_nat_gateway" "AslamNATG" {
 subnet_id = aws_subnet.AslamPublicSubnet.id
 allocation_id = aws_eip.AslamEIP.id
 tags = {
   "Name" = "AslamNAT"
 }
}

// Create Route Table for Public Subnet
resource "aws_route_table" "AslamPublicRoute" {
  tags = {
    "Name" = "Aslam Public Route Table"
  }
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.AslamIGW.id
  }
  vpc_id = aws_vpc.PersonalVPC.id
}

// Create Route Table for Private Subnet
resource "aws_route_table" "AslamPrivateRoute" {
  vpc_id = aws_vpc.PersonalVPC.id
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_nat_gateway.AslamNATG.id
  }
  tags = {
    "Name" = "Aslam Private Route Table"
  }
}

// Public Route Associate With Public Subnet
resource "aws_route_table_association" "publicToPublic" {
  subnet_id = aws_subnet.AslamPublicSubnet.id
  route_table_id = aws_route_table.AslamPublicRoute.id
}

// Private Route Associate with Private Subnet
resource "aws_route_table_association" "PrivateToPrivate" {
  subnet_id = aws_subnet.AslamPrivateSubnet.id
  route_table_id = aws_route_table.AslamPrivateRoute.id
}


// The Key Pair is Already Created Manually in AWS account with the Name " TerraWindow "

// Creating Window Server Instance in that Public Subnet
resource "aws_instance" "aslamPublicEC2" {
    ami = "ami-0509f816fdd94dec7"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.AslamPublicSubnet.id
    key_name = "TerraWindow"
    tags = {
      "Name" = "Public Machine"
    }
    associate_public_ip_address = true
}

// Creating Window Server Insttance in that Private Subnet
resource "aws_instance" "aslamPrivateEC2" {
    ami = "ami-0509f816fdd94dec7"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.AslamPrivateSubnet.id
    key_name = "TerraWindow"
    tags = {
      "Name" = "Private Machine"
    }
}