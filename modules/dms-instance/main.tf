resource "aws_dms_replication_instance" "replication_instance" {
  replication_instance_id      = "dms-cdc-${var.owner_name}"
  allocated_storage            = 50
  apply_immediately            = true
  engine_version               = var.engine_version
  multi_az                     = var.multi_az
  publicly_accessible          = var.publicly_accessible
  preferred_maintenance_window = "sun:01:00-sun:02:00"
  replication_instance_class   = var.replication_instance_class
  replication_subnet_group_id  = "default-vpc-425454da" # mudar vpc
  vpc_security_group_ids       = var.vpc_security_group_ids

  tags = {
    Project   = "DersonLake"
    Managedby = "Terraform"
    Author    = "AndersonSantana"
  }
}
