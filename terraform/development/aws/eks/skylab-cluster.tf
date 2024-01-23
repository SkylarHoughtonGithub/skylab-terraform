module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  #TODO: Build kubernetes provider to be capable of loop
  # for_each = local.us_east_1

  cluster_version                         = local.cluster_version
  cluster_endpoint_public_access          = local.cluster_endpoint_public_access
  cluster_name                            = local.cluster_name
  cluster_addons                          = try(local.cluster_addons, null)
  create_aws_auth_configmap               = try(local.create_aws_auth_configmap, false)
  manage_aws_auth_configmap               = try(local.manage_aws_auth_configmap, false)
  create_iam_role                         = try(local.create_iam_role, false)
  iam_role_name                           = local.iam_role_name
  aws_auth_roles                          = try(local.aws_auth_roles, null)
  eks_managed_node_groups                 = local.eks_managed_node_groups
  eks_managed_node_group_defaults         = local.eks_managed_node_group_defaults
  cluster_security_group_additional_rules = try(local.cluster_security_group_additional_rules, null)
  node_security_group_additional_rules    = try(local.node_security_group_additional_rules, null)
  subnet_ids                              = local.subnet_ids
  vpc_id                                  = local.vpc_id

  tags = local.tags


  providers = {
    aws = aws.us-east-1
  }
}
