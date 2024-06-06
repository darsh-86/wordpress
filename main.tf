provider "aws" {
  region = "eu-west-3"
}

resource "aws_security_group" "wordpress_sg" {
  name = "wordpress_sg"

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
  instance_class       = "db.t3.micro"
  db_name              = "wordpressdb"
  username             = "admin"
  password             = "admin4321"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
}

resource "aws_instance" "wordpress" {
  ami           = "ami-0e69eec55f2854bee" # Amazon Linux 2 AMI
  instance_type = "t2.medium"
  key_name      = "parisIAM"
  tags  = {
             name = "wordpress"
   }

  security_groups = [aws_security_group.wordpress_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y docker
              sudo systemctl enable --now docker
              sudo docker network create wordpress-network

              sudo docker run -d --name wordpress --network wordpress-network -e WORDPRESS_DB_HOST=${aws_db_instance.wordpress_db.endpoint}:3306 -e WORDPRESS_DB_USER=admin -e WORDPRESS_DB_PASSWORD=admin4321 -e WORDPRESS_DB_NAME=wordpress -p 8080:80 wordpress
              EOF 
}
resource "aws_instance" "wp_proxy" {
  ami           = "ami-0e69eec55f2854bee" # Amazon Linux 2 AMI
  instance_type = "t2.medium"
  key_name      = "parisIAM"
  tags   = {
    name = "wp_proxy"
  }
  security_groups = [aws_security_group.wordpress_sg.name]

user_data = <<-EOF
              #!/bin/bash
              sudo -i
              yum update -y
              yum install -y docker
              systemctl enable --now docker
              docker network create wordpress-network
              
              docker run -d --name wp-proxy --network wordpress-network -p 80:80
               
              cat > /home/ec2-user/nginx.conf <<EOL
              user  nginx;
              worker_processes  auto;

              error_log  /var/log/nginx/error.log notice;
              pid        /var/run/nginx.pid;

              events {
                  worker_connections  1024;
              }

              http {
                  include       /etc/nginx/mime.types;
                  default_type  application/octet-stream;

                  log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                                    '\$status \$body_bytes_sent "\$http_referer" '
                                    '"\$http_user_agent" "\$http_x_forwarded_for"';

                  access_log  /var/log/nginx/access.log  main;

                  sendfile        on;
                  keepalive_timeout  65;

                  upstream wordpress {
                      server wordpress:80;
                  }

                  server {
                      listen 80;

                      location / {
                          proxy_pass http://${aws_instance.wordpress.public_ip}:8080;
                          proxy_set_header Host \$host;
                          proxy_set_header X-Real-IP \$remote_addr;
                          proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                          proxy_set_header X-Forwarded-Proto \$scheme;
                      }

                      location /wp-admin {
                          allow 58.84.60.89;  # Replace with your specific IP address
                          deny all;
                          proxy_pass http://${aws_instance.wordpress.public_ip}:808};
                          proxy_set_header Host \$host;
                          proxy_set_header X-Real-IP \$remote_addr;
                          proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                          proxy_set_header X-Forwarded-Proto \$scheme;
                      }

                      location /wp-login.php {
                          allow 58.84.60.89;  # Replace with your specific IP address
                          deny all;
                          proxy_pass http://${aws_instance.wordpress.public_ip}:8080;
                          proxy_set_header Host \$host;
                          proxy_set_header X-Real-IP \$remote_addr;
                          proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                          proxy_set_header X-Forwarded-Proto \$scheme;
                      }
                  }
              }
              EOL

              docker run -d --name nginx --network wordpress-network -p 80:80 -v /home/ec2-user/nginx.conf:/etc/nginx/nginx.conf:ro nginx
              EOF
}