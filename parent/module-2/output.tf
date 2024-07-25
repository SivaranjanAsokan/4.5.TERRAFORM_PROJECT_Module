# Define Output Values
# Attribute Reference: EC2 Instance Public IP
output "ec2_instance_publicip" {
  description = "EC2 Instance Public IP"
  value = aws_instance.ec2.public_ip 
}

# Argument Reference: EC2 Instance Private IP
# output "ec2_instance_privateip" {
#   description = "EC2 Instance Private IP"
#   value = aws_instance.my-ec2-vm.private_ip 
# }

# Argument Reference: Security Groups associated to EC2 Instance
output "ec2_security_groups" {
  description = "List Security Groups associated with EC2 Instance"
  value = aws_instance.ec2.security_groups
}