resource "aws_security_group" "main_sg" {
  name        = "${var.project_name}-main-sg"
  description = "Base security group for internal communication"
  vpc_id      = aws_vpc.MY_Network.id

  ingress {
    description = "Allow all internal traffic within VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-security-group"
  }
}
