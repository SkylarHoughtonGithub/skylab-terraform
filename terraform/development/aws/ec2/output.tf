output "ec2_us_east_1_public_ip" {
  value = {
    for instance_name, instance in module.ec2_us_east_1 : instance_name => instance.public_ip
  }
}
