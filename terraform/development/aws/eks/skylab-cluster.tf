module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_version                         = local.us_east_1.cluster_version
  cluster_endpoint_public_access          = local.us_east_1.cluster_endpoint_public_access
  cluster_name                            = local.us_east_1.cluster_name
  cluster_addons                          = try(local.us_east_1.cluster_addons, null)
  create_aws_auth_configmap               = try(local.us_east_1.create_aws_auth_configmap, false)
  manage_aws_auth_configmap               = try(local.us_east_1.manage_aws_auth_configmap, false)
  create_iam_role                         = try(local.us_east_1.create_iam_role, false)
  iam_role_name                           = local.us_east_1.iam_role_name
  aws_auth_roles                          = try(local.us_east_1.aws_auth_roles, null)
  eks_managed_node_groups                 = local.us_east_1.eks_managed_node_groups
  eks_managed_node_group_defaults         = local.us_east_1.eks_managed_node_group_defaults
  cluster_security_group_additional_rules = try(local.us_east_1.cluster_security_group_additional_rules, null)
  node_security_group_additional_rules    = try(local.us_east_1.node_security_group_additional_rules, null)
  subnet_ids                              = local.us_east_1.subnet_ids
  vpc_id                                  = local.us_east_1.vpc_id

  tags = local.us_east_1.tags


  providers = {
    aws = aws.us-east-1
  }
}
