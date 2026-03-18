resource "aws_db_instance" "mysql" {
  allocated_storage       = 20
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  skip_final_snapshot     = true
  publicly_accessible     = false
  vpc_security_group_ids  = [aws_security_group.rds.id]
  db_subnet_group_name = aws_db_subnet_group.main.name
  deletion_protection     = false
  backup_retention_period = 7
  multi_az                = false
}
