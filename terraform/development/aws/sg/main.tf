module "sgs_us_east_1" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  for_each = var.sgs

  name                     = each.value.name
  description              = try(each.value.description, each.value.name)
  vpc_id                   = "vpc-0f6c219833fe92be7"
  ingress_cidr_blocks      = each.value.ingress_cidr_blocks
  ingress_rules            = each.value.ingress_rules
  ingress_with_cidr_blocks = each.value.ingress_with_cidr_blocks
  egress_rules             = each.value.ingress_rules
  egress_with_cidr_blocks  = each.value.egress_with_cidr_blocks

  tags = try(each.value.tags, null)

  providers = {
    aws = aws.us-east-1
  }
}

# module "public_sgs_us_east_2" {
#   source  = "terraform-aws-modules/security-group/aws"
#   version = "~> 5.0"

#   for_each = var.sgs

#   name                     = each.value.name
#   description              = try(each.value.description, each.value.name)
#   vpc_id                   = each.value.vpc_id
#   ingress_cidr_blocks      = each.value.ingress_cidr_blocks
#   ingress_rules            = each.value.ingress_rules
#   ingress_with_cidr_blocks = each.value.ingress_with_cidr_blocks
#   egress_rules             = each.value.ingress_rules
#   egress_with_cidr_blocks  = each.value.egress_with_cidr_blocks

#   tags = try(each.value.tags, null)

#   providers = {
#     aws = aws.us-east-2
#   }
# }
