output "skylab-use2-vpc-id" { value = module.vpc_use2["skylab"].vpc_id }
output "skylab-use2-private-subnet-ids" { value = module.vpc_use2["skylab"].private_subnets }
output "skylab-use2-public-subnet-ids" { value = module.vpc_use2["skylab"].public_subnets }
