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
    device_name = "App01-Staging_volume"
  }


  tags = {
    Name = "App01-Stagging"
    Team = "Ops"
    Product = "Vprofile"
  }
}

# Définition de la ressource EC2 (instance) pour le server backend
resource "aws_instance" "backend_server" {
  ami             = "ami-07761f3ae34c4478d"  # ID AMI d'Amazon Linux 2
  instance_type   = "t2.micro"
  key_name        = "ci-vprofile-key"  #  nom de la clé SSH

  # Définition du groupe de sécurité (SG) existant
  vpc_security_group_ids = ["sg-0723c6460a7a860e6"]
   ebs_block_device  {
    volume_size = 20
    volume_type = "gp2"
    encrypted   = true # Chiffrement du volume EBS
    device_name = "backend_server_volume"
  }

  # Configuration du user-data
   user_data = <<-EOF
                #!/bin/bash
DATABASE_PASS='admin123'
yum update -y
yum install epel-release -y
yum install mariadb-server -y
yum install wget git unzip -y

#mysql_secure_installation
sed -i 's/^127.0.0.1/0.0.0.0/' /etc/my.cnf

# starting & enabling mariadb-server
systemctl start mariadb
systemctl enable mariadb

#restore the dump file for the application
cd /tmp/
wget https://raw.githubusercontent.com/devopshydclub/vprofile-repo/vp-rem/src/main/resources/db_backup.sql
mysqladmin -u root password "$DATABASE_PASS"
mysql -u root -p"$DATABASE_PASS" -e "UPDATE mysql.user SET Password=PASSWORD('$DATABASE_PASS') WHERE User='root'"
mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User=''"
mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"
mysql -u root -p"$DATABASE_PASS" -e "create database accounts"
mysql -u root -p"$DATABASE_PASS" -e "grant all privileges on accounts.* TO 'admin'@'localhost' identified by 'admin123'"
mysql -u root -p"$DATABASE_PASS" -e "grant all privileges on accounts.* TO 'admin'@'%' identified by 'admin123'"
mysql -u root -p"$DATABASE_PASS" accounts < /tmp/db_backup.sql
mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"

# Restart mariadb-server
systemctl restart mariadb
# SETUP MEMCACHE
yum install memcached -y
systemctl start memcached
systemctl enable memcached
systemctl status memcached
memcached -p 11211 -U 11111 -u memcached -d
sleep 30
yum install socat -y
yum install wget -y
wget https://www.rabbitmq.com/releases/rabbitmq-server/v3.6.10/rabbitmq-server-3.6.10-1.el7.noarch.rpm
rpm --import https://www.rabbitmq.com/rabbitmq-release-signing-key.asc
yum update
rpm -Uvh rabbitmq-server-3.6.10-1.el7.noarch.rpm
systemctl start rabbitmq-server
systemctl enable rabbitmq-server
systemctl status rabbitmq-server
echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config
rabbitmqctl add_user test test
rabbitmqctl set_user_tags test administrator
systemctl restart rabbitmq-server



               EOF

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
    device_name = "prod_server_volume"
  }



  tags = {
    Name = "App01-production"
    Team = "Ops"
    Product = "Vprofile"
  }
}


