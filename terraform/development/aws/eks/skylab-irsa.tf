#TODO: Modularize and integrate with eks module
# module "vpc_cni_ipv4_irsa_role" {
#   source                = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#   version               = "5.28.0"
#   role_name             = "vpc-cni-ipv4"
#   attach_vpc_cni_policy = true
#   vpc_cni_enable_ipv4   = true
#   oidc_providers = {
#     cni = {
#       provider_arn               = module.eks.oidc_provider_arn
#       namespace_service_accounts = ["kube-system:aws-node"]
#     }
#   }
# }

# module "load_balancer_controller_irsa_role" {
#   source                                 = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#   version                                = "5.28.0"
#   role_name                              = "aws-load-balancer-controller"
#   attach_load_balancer_controller_policy = true
#   oidc_providers = {
#     lb = {
#       provider_arn               = module.eks.oidc_provider_arn
#       namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
#     }
#   }
# }

# module "external_dns_irsa_role" {
#   source                        = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#   version                       = "5.28.0"
#   role_name                     = "external-dns"
#   attach_external_dns_policy    = true
#   external_dns_hosted_zone_arns = ["arn:aws:route53:::hostedzone/Z088685221RW4JITTODNL"]
#   oidc_providers = {
#     dns = {
#       provider_arn               = module.eks.oidc_provider_arn
#       namespace_service_accounts = ["kube-system:external-dns"]
#     }
#   }
# }

# module "efs_csi_irsa_role" {
#   source                = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#   version               = "5.28.0"
#   role_name             = "efs-csi"
#   attach_efs_csi_policy = true
#   oidc_providers = {
#     csi = {
#       provider_arn               = module.eks.oidc_provider_arn
#       namespace_service_accounts = ["kube-system:efs-csi"]
#     }
#   }
# }
