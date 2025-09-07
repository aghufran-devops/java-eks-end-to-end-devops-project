# VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "igp-vpc"
  cidr = var.vpc_cidr

  azs                     = data.aws_availability_zones.azs.names
  public_subnets          = var.public_subnets
  map_public_ip_on_launch = true

  enable_dns_hostnames = true

  tags = {
    Name        = "igp-vpc"
    Terraform   = "true"
    Environment = "pre"
  }

  public_subnet_tags = {
    Name        = "jenkins-subnet"
    Terraform   = "true"
    Environment = "pre"
  }
}

# SG
module "sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "igp-jenkins-sg"
  description = "Security Group for Jenkins Server"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "HTTP"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    Name        = "igp-jenkins-sg"
    Terraform   = "true"
    Environment = "pre"
  }
}

# EC2
module "ec2_instance_jenkins" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "Jenkins-Server"

  ami                         = data.aws_ami.Amazon_Linux_2023.id
  instance_type               = var.instance_type
  availability_zone           = data.aws_availability_zones.azs.names[0]
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [module.sg.security_group_id]
  key_name                    = "IGP-keypair-eks-s3-dynamo-ecr-ec2-user"
  monitoring                  = true
  associate_public_ip_address = true
  user_data                   = file("jenkins-install.sh")


  tags = {
    Name        = "Jenkins-Server"
    Terraform   = "true"
    Environment = "pre"
  }
}

module "ec2_instance_Tomcat" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "Tomcat-Server"

  ami                         = data.aws_ami.Amazon_Linux_2023.id
  instance_type               = var.instance_type
  availability_zone           = data.aws_availability_zones.azs.names[0]
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [module.sg.security_group_id]
  key_name                    = "IGP-keypair-eks-s3-dynamo-ecr-ec2-user"
  monitoring                  = true
  associate_public_ip_address = true
  user_data                   = file("tomcat-install.sh")


  tags = {
    Name        = "Tomcat-Server"
    Terraform   = "true"
    Environment = "pre"
  }
}

module "ec2_instance_Docker" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "Tomcat-Server"

  ami                         = data.aws_ami.Amazon_Linux_2023.id
  instance_type               = var.instance_type
  availability_zone           = data.aws_availability_zones.azs.names[0]
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [module.sg.security_group_id]
  key_name                    = "IGP-keypair-eks-s3-dynamo-ecr-ec2-user"
  monitoring                  = true
  associate_public_ip_address = true
  user_data                   = file("docker-install.sh")


  tags = {
    Name        = "Docker-Host"
    Terraform   = "true"
    Environment = "pre"
  }
}