data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "app" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  vpc_security_group_ids             = [aws_security_group.ec2.id]

  subnet_id = aws_subnet.subnet_a.id
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/user_data.sh", {
    db_username = var.db_username
    db_password = var.db_password
    db_host     = aws_db_instance.mysql.address
  })

  tags = {
    Name      = "docker-app"
    CreatedBy = "terraform"
  }
}