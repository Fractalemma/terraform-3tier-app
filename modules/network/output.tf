output "region" {
  value = var.region
}
output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "pub_sub_a_id" {
  value = aws_subnet.pub_sub_a.id
}
output "pub_sub_b_id" {
  value = aws_subnet.pub_sub_b.id
}

output "pri_sub_app_a_id" {
  value = aws_subnet.pri_sub_app_a.id
}
output "pri_sub_app_b_id" {
  value = aws_subnet.pri_sub_app_b.id
}
output "pri_sub_data_a_id" {
  value = aws_subnet.pri_sub_data_a.id
}
output "pri_sub_data_b_id" {
  value = aws_subnet.pri_sub_data_b.id
}

output "igw_id" {
  value = aws_internet_gateway.internet_gateway.id
}
