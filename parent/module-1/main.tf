terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider & AWS Secret & Access key: 
provider "aws" {
  region = var.web_region
  
}



# Create a VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "vpc"
  }
}

#Internet-gateway
 resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw"
  }
}

#pub-Subnet 
resource "aws_subnet" "pub-subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = var.availability_zone1

  tags = {
    Name = "pub-Subnet-1"
  }
}


#Pub-Route Table
resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id 
  }

    tags = {
    Name = "pub-rt-1"
  }
}
#Associate
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.pub-subnet.id
  route_table_id = aws_route_table.pub-rt.id
}



#pub-Subnet-2 
resource "aws_subnet" "pub-subnet-2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = var.availability_zone2

  tags = {
    Name = "pub-Subnet-2"
  }
}


#Pub-Route Table
resource "aws_route_table" "pub-rt-2" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id 
  }

    tags = {
    Name = "pub-rt-2"
  }
}
#Associate
resource "aws_route_table_association" "a-2" {
  subnet_id      = aws_subnet.pub-subnet-2.id
  route_table_id = aws_route_table.pub-rt-2.id
}


# RSA key of size 4096 bits
resource "tls_private_key" "rsa-4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#variable


#key-pair
resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.rsa-4096.public_key_openssh
}

resource "local_file" "private-key"{
  filename = var.key_name
  content = tls_private_key.rsa-4096.private_key_pem
}

#EC2
resource "aws_instance" "ec2" {
  ami           = "ami-0a0e5d9c7acc336f1"
  instance_type = "t2.micro"
  subnet_id =   aws_subnet.pub-subnet.id
  associate_public_ip_address = "true"
  key_name  = aws_key_pair.key_pair.key_name

  tags = {
    Name = "HelloWorld"
  }
  #userData
  user_data = file("/module-1/scripts.sh")

  #security group for the instance
  # Correct way to assign multiple security groups
  vpc_security_group_ids = [
    aws_security_group.allow_ssh.id,
    aws_security_group.allow_tls.id
  ]
}


#SG
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
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
    Name = "allow_tls"
  }
}

#SG-ssh
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
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
    Name = "allow_tls"
  }
}


#Pri-Subnet creation
resource "aws_subnet" "pri-subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = var.availability_zone1

  tags = {
    Name = "pri-subnet"
  }
}

#Pri-Route Table
resource "aws_route_table" "pri-rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw.id
  }

    tags = {
    Name = "pri-rt-1"
  }
}
#Associtae
resource "aws_route_table_association" "pri-a" {
  subnet_id      = aws_subnet.pri-subnet.id
  route_table_id = aws_route_table.pri-rt.id
}
#EIP
resource "aws_eip" "eip" {
  #instance = aws_instance.web.id
  vpc      = true
}

#Nat-gateway
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.pub-subnet.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  #depends_on = [aws_internet_gateway.eip]
}


#EC2
#SG


