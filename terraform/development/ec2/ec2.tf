resource "aws_placement_group" "web" {
  name     = local.name
  strategy = "cluster"
}

resource "aws_kms_key" "this" {
}

resource "aws_network_interface" "this" {
  subnet_id = element(module.vpc.private_subnets, 0)
}

module "ec2_multiple" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.5.0"

  for_each = local.multiple_instances

  name = each.key

  ami                         = each.value.ami
  associate_public_ip_address = each.value.associate_public_ip_address
  availability_zone           = each.value.availability_zone
  create_iam_instance_profile = each.value.create_iam_instance_profile
  enable_volume_tags          = false
  iam_role_description        = each.value.create_iam_instance_profile ? each.value.iam_role_description : null
  iam_role_policies           = each.value.create_iam_instance_profile ? each.value.iam_role_policies : null
  instance_type               = each.value.instance_type
  placement_group             = each.value.placement_group
  root_block_device           = lookup(each.value, "root_block_device", [])
  subnet_id                   = each.value.subnet_id
  user_data_base64            = base64encode(each.value.user_data)
  user_data_replace_on_change = true
  vpc_security_group_ids      = [module.security_group.security_group_id]

  tags = local.tags
}
