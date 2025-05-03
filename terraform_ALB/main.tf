# Use the hashicorp/vpc module.  If you don't have this,
# you can add it with:
# terraform init
# See: https://registry.terraform.io/modules/hashicorp/vpc/aws
# Create a security group for the ALB.  This security group
# allows traffic on port 80 (HTTP) from anywhere.  You should
# restrict this to only the IP addresses that need to access
# your application.
resource "aws_security_group" "alb" {
  name        = "alb"
  description = "Security group for the ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
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

# Create a security group for the EC2 instances.  This security
# group allows traffic from the ALB security group on port 80.
resource "aws_security_group" "ec2" {
  name        = "ec2"
  description = "Security group for the EC2 instances"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    #  Only allow traffic from the ALB security group.
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create the Application Load Balancer.
resource "aws_lb" "alb" {
  name               = "my-alb"
  internal           = false #  false = public ALB, true = internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = module.vpc.public_subnets[*] #  Place in public subnets
}

# Create a target group for the ALB.  The target group is used
# to route traffic to the EC2 instances.
resource "aws_lb_target_group" "alb" {
  name     = "my-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
}

# Create a listener for the ALB.  This listener listens on port 80
# and forwards traffic to the target group.
resource "aws_lb_listener" "alb" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb.arn
  }
}

# Create two EC2 instances in the private subnets.
resource "aws_instance" "ec2" {
  count         = 2
  ami           = "ami-0c15e602d3d6c6c4a" #  Replace with a valid AMI ID for your region.  This is an Ubuntu AMI.
  instance_type = "t2.micro"             #  Choose an appropriate instance type.
  subnet_id     = module.vpc.private_subnets[count.index] # Place in private subnets
  security_groups = [aws_security_group.ec2.id]
  #  The key_name is required to SSH into the instance.  Replace "my-key"
  #  with the name of your EC2 key pair.  If you don't have one,
  #  you'll need to create one.
  key_name = "key_name"

  #  User data to start a simple web server on each instance.
  user_data = <<-EOF
#!/bin/bash
sudo yum install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx
sudo echo "<!DOCTYPE html>" > /tmp/index.html
sudo echo "<html>" >> /tmp/index.html
sudo echo "<body style=\"background-color:red;\">" >> /tmp/index.html
sudo echo "<h1>This is host my_hostname </h1>" >> /tmp/index.html
sudo echo "</body>" >> /tmp/index.html
sudo echo "</html>" >> /tmp/index.html
host_name=$(/usr/bin/hostname)
sed -i -e s/my_hostname/$host_name/g /tmp/index.html
sudo systemctl stop nginx
sleep 3
sudo rm -f /usr/share/nginx/html/index.html
sudo cp /tmp/index.html /usr/share/nginx/html/
sudo systemctl start nginx
cd /tmp
sudo dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent
EOF

  #  Associate the instances with the target group.
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = "EC2-Instance-${count.index + 1}"
  }
}

#  Register the EC2 instances with the target group.  This is
#  done using the aws_lb_target_group_attachment resource.
resource "aws_lb_target_group_attachment" "ec2" {
  count            = 2
  target_group_arn = aws_lb_target_group.alb.arn
  target_id        = aws_instance.ec2[count.index].id
  port             = 80
}

# Output the ALB's DNS name.  This is the address you'll use to access
# your application.
output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

