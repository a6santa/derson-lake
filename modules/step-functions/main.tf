resource "aws_sfn_state_machine" "this" {
  name     = "${var.state_machine_name}"
  role_arn = "${var.iam_state_machine_role}"
  
  tags = {
    Project = "DersonLake"
    Managedby = "Terraform"
    Author = "AndersonSantana"
  }

  definition = <<EOF
  ${var.state_machine_json}
EOF

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.this.arn}:*"
    include_execution_data = true
    level                  = "ERROR"
  }
  depends_on = [
    aws_cloudwatch_log_group.this
  ]
}

resource "aws_cloudwatch_log_group" "this" {   
  name = "/aws/vendedlogs/states/${var.state_machine_name}-Logs"   
  retention_in_days = 7 
}