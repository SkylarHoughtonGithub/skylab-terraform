module "ec2_us_east_1" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.5.0"

  for_each = local.us_east_1

  name = each.key

  ami                         = each.value.ami
  associate_public_ip_address = each.value.associate_public_ip_address
  availability_zone           = each.value.availability_zone
  enable_volume_tags          = each.value.enable_volume_tags
  iam_instance_profile        = try(each.value.iam_instance_profile, null)
  instance_type               = each.value.instance_type
  key_name                    = each.value.key_name
  placement_group             = try(each.value.placement_group, null)
  root_block_device           = lookup(each.value, "root_block_device", [])
  subnet_id                   = each.value.subnet_id
  user_data_base64            = base64encode(each.value.user_data)
  user_data_replace_on_change = false
  vpc_security_group_ids      = each.value.vpc_security_group_ids

  tags = each.value.tags

  providers = {
    aws = aws.us-east-1
  }
}
