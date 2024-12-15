locals {
  json_file = file("${path.module}/states.json")
}

module "create_state_machine" {
  source                 = "../../modules/step-functions"
  state_machine_name     = "derson-Main"
  state_machine_json     = local.json_file
  iam_state_machine_role = var.iam_state_machine_role
}