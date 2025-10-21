variable "module_prefix" {}
variable "vpc_id" {}
variable "internal_alb_ingress_cidrs" {
  type = list(string)
}
variable "app_sg_egress_cidrs" {
  type = list(string)
}
