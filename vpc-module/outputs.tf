output "vpc" {
  value = {
    vpc_id            = aws_vpc.vpc.id
    public_subnet_id  = aws_subnet.public_subnet[*].id
    private_subnet_id = aws_subnet.private_subnet[*].id
    security_group_id = aws_security_group.sg[*].id
  }
}
