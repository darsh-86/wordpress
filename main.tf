provider "aws" {
  region = "eu-west-3"
}

resource "aws_security_group" "wordpress-sg" {
  name = "wordpress-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "wordpress_db" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t2.micro"
  name                 = "wordpressdb"
  username             = "admin"
  password             = "admin4321"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
}

resource "aws_instance" "wordpress" {
  ami           = "ami-069195b1b84c1a70f" # Amazon Linux 2 AMI
  instance_type = "t2.medium"
  key_name      = "parisIAM"

  security_groups = [aws_security_group.wordpress-sg.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo -i
              yum update -y
              yum install -y docker
              systemctl enable --now docker
              docker network create wordpress-network

              docker run -d --name wordpress --network wordpress-network \\
                -e WORDPRESS_DB_HOST=${aws_db_instance.wordpress_db.endpoint}:3306 \\
                -e WORDPRESS_DB_USER=admin \\
                -e WORDPRESS_DB_PASSWORD=admin4321 \\
                -e WORDPRESS_DB_NAME=wordpress \\
                -p 8080:8080 wordpress
                EOF 
}