provider "aws" {
  region = "eu-wast-3"
}

resource "aws_instance" "wordpress" {
  ami           = "ami-069195b1b84c1a70f" # Amazon Linux 2 AMI
  instance_type = "t2.medium"
  key_name      = "parisIAM"

  security_groups = ["wordpress-sg"]
}
/*user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              service docker start
              usermod -a -G docker ec2-user
              docker run -d --name wordpress -p 80:80 -p 443:443 -v /efs/wordpress:/var/www/html wordpress
              docker run -d --name nginx -p 8080:80 --link wordpress:wordpress nginx
              EOF 
} */

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
    cidr_blocks = ["your-admin-ip/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

/* resource "aws_db_instance" "wordpress_db" {
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
}*/
