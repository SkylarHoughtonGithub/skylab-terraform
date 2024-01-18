locals {
  sgs_us_east_1_id = {
    for name, sg in module.sgs_us_east_1 : name => sg.security_group_id
  }
}
