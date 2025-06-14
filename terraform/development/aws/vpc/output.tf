output "skylab-use1-vpc-id" { value = module.vpc_use2["skylab"].vpc_id }
output "skylab-use1-private-subnet-ids" { value = module.vpc_use2["skylab"].private_subnets }
output "skylab-use1-public-subnet-ids" { value = module.vpc_use2["skylab"].public_subnets }
