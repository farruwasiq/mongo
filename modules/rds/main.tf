
#create a RDS Database Instance
resource "aws_db_instance" "myinstance" {
  engine               = var.engine
  db_name              = var.db_name
  identifier           = var.identifier
  allocated_storage    =  var.storage
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  username             = var.user
  password             = var.passwd
  parameter_group_name = "default.mysql5.7"

  skip_final_snapshot  = true
  publicly_accessible =  true
}