
resource "aws_security_group" "web-security-group" {
  name        = "web-security-group"
  description = "Allow HTTPS traffic"
  vpc_id      = data.aws_vpc.vpc.id
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "web-security-group"
  }
}

resource "aws_security_group_rule" "http_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web-security-group.id
}

resource "aws_security_group_rule" "https_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web-security-group.id
}

resource "aws_s3_bucket" "app_bucket" {
  bucket = var.bucket_name
  tags = {
    Name = var.bucket_name
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_app_instance" {
  bucket = aws_s3_bucket.app_bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_app_instance_policy.json
}

resource "aws_launch_template" "app_lt" {
  name = "employee-directory-app-launch-template"
  iam_instance_profile {
    name = "S3DynamoDBFullAccessRole"
  }

  image_id = data.aws_ami.amzn-linux-2023-ami.id

  instance_initiated_shutdown_behavior = "terminate"

  instance_type = "t2.micro"

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web-security-group.id]
    subnet_id                   = data.aws_subnet.subnet.id
  }

  # vpc_security_group_ids = [aws_security_group.web-security-group.id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "employee-directory-app-launch-template"
    }
  }
  user_data = base64encode(templatefile("${path.module}/templates/template.sh", {
    bucket_name = var.bucket_name
    region      = var.region
  }))
}


resource "aws_autoscaling_group" "app_asg" {
  name               = "app-asg"
  availability_zones = [data.aws_subnet.subnet.availability_zone]
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "app-asg"
    propagate_at_launch = true
  }
}
