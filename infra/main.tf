# Configuration du fournisseur AWS
provider "aws" {
  region = "us-east-1"
}

# Définition de la ressource EC2 (instance) pour le server de Stagging
resource "aws_instance" "staging_server" {
  ami             = "ami-07d9b9ddc6cd8dd30"  # ID AMI d'Ubuntu
  instance_type   = "t2.micro"
  key_name        = "ci-vprofile-key"  # nom de la clé SSH

  # Définition du groupe de sécurité (SG) Stagging existant
  vpc_security_group_ids = ["sg-0ed359c95d65d390d"]

    ebs_block_device  {
    volume_size = 20
    volume_type = "gp2"
    encrypted   = true # Chiffrement du volume EBS
    device_name = "/dev/sdb"
  }


  tags = {
    Name = "App01-Stagging"
    Team = "Ops"
    Product = "Vprofile"
  }
}

# Définition de la ressource EC2 (instance) pour le server backend
resource "aws_instance" "backend_server" {
  ami             = "ami-07d9b9ddc6cd8dd30"  #  ID AMI de Ubuntu - CentOS(ami-002070d43b0a4f171)
  instance_type   = "t2.micro"
  key_name        = "ci-vprofile-key"  #  nom de la clé SSH

  # Définition du groupe de sécurité (SG) existant
  vpc_security_group_ids = ["sg-0723c6460a7a860e6"]
   ebs_block_device  {
    volume_size = 20
    volume_type = "gp2"
    encrypted   = true # Chiffrement du volume EBS
    device_name = "/dev/sdb"
  }

  # Configuration du user-data
   

  tags = {
    Name = "Backend-app-server"
    Team = "Ops"
    Product = "Vprofile"
  }
}


# Définition de la ressource EC2 (instance) pour le server de production
resource "aws_instance" "prod_server" {
  ami             = "ami-07d9b9ddc6cd8dd30"  # ID AMI d'Ubuntu
  instance_type   = "t2.micro"
  key_name        = "ci-vprofile-key"  #  nom de la clé SSH

  # Définition du groupe de sécurité (SG) Prod existant
  vpc_security_group_ids = ["sg-0ed359c95d65d390d"]
   ebs_block_device  {
    volume_size = 20
    volume_type = "gp2"
    encrypted   = true # Chiffrement du volume EBS
    device_name = "/dev/sdb"
  }



  tags = {
    Name = "App01-production"
    Team = "Ops"
    Product = "Vprofile"
  }
}


