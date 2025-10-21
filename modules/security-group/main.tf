# Security Group for the internet-facing ALB
resource "aws_security_group" "web_alb_sg" {
  name        = "${var.module_prefix}-web-alb-sg"
  description = "enable http/https access on port 80/443"
  vpc_id      = var.vpc_id

  ingress {
    description = "http access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Ready for SSL/TLS certificate future use:
  ingress {
    description = "https access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.module_prefix}-web-alb_sg"
  }
}

# Security Group for the internal ALB (beetween web and app tier)
resource "aws_security_group" "internal_alb_sg" {
  name        = "${var.module_prefix}-internal-alb-sg"
  description = "enable http access on port 80"
  vpc_id      = var.vpc_id

  ingress {
    description = "http access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.internal_alb_ingress_cidrs
  }

  tags = {
    Name = "${var.module_prefix}-app-alb_sg"
  }
}

# Security Group for the Web Tier
resource "aws_security_group" "web_sg" {
  name        = "${var.module_prefix}-web-sg"
  description = "enable http access on port 80 for elb sg"
  vpc_id      = var.vpc_id

  ingress {
    description     = "http access"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.module_prefix}-web_sg"
  }
}

# Security Group for the App Tier
resource "aws_security_group" "app_sg" {
  name        = "${var.module_prefix}-app-sg"
  description = "Enable http access on port 80 for elb sg"
  vpc_id      = var.vpc_id

  ingress {
    description     = "http access"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_alb_sg.id]
  }

  egress {
    description = "Enable outbound comm with MySQL DB"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.app_sg_egress_cidrs
  }

  tags = {
    Name = "${var.module_prefix}-app_sg"
  }
}

# Security Group for the Database (Data Tier)
resource "aws_security_group" "db_sg" {
  name        = "${var.module_prefix}-db-sg"
  description = "enable mysql access on port 3306 from web-sg"
  vpc_id      = var.vpc_id

  ingress {
    description     = "mysql access"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.module_prefix}-database_sg"
  }
}

# See:
# - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
