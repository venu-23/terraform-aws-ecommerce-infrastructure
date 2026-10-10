#----------------
# ALB Security Group
#----------------
resource "aws_security_group" "alb" {
  name        = "ecommerce-${var.environment}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "ecommerce-${var.environment}-alb-sg"
    Environment = var.environment
    Project     = "ecommerce"
    Tier        = "alb"
  }
}



#--------------------------------------
# EC2 or EKS APPlication Security Group
#--------------------------------------


resource "aws_security_group" "app" {
  name        = "ecommerce-${var.environment}-app-sg"
  description = "Security group for application servers"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Application traffic from ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "ecommerce-${var.environment}-app-sg"
    Environment = var.environment
    Project     = "ecommerce"
    Tier        = "application"
  }
}



#----------------
# DB Security Group
#----------------


resource "aws_security_group" "db" {
  name        = "ecommerce-${var.environment}-db-sg"
  description = "Security group for database"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL traffic from application servers"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "ecommerce-${var.environment}-db-sg"
    Environment = var.environment
    Project     = "ecommerce"
    Tier        = "database"
  }
}

