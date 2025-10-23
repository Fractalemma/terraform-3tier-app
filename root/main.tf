#----- Network
module "route53" {
  source             = "../modules/r53"
  alb_dns_name       = module.web_alb.alb_dns_name
  alb_hosted_zone_id = module.web_alb.alb_hosted_zone_id
  sub_domain         = var.sub_domain
  hosted_zone_name   = var.hosted_zone_name
}

module "network" {
  source              = "../modules/network"
  region              = var.region
  module_prefix       = var.project_name
  vpc_cidr            = var.vpc_cidr
  pub_sub_a_cidr      = var.pub_sub_a_cidr
  pub_sub_b_cidr      = var.pub_sub_b_cidr
  pri_sub_app_a_cidr  = var.pri_sub_app_a_cidr
  pri_sub_app_b_cidr  = var.pri_sub_app_b_cidr
  pri_sub_data_a_cidr = var.pri_sub_data_a_cidr
  pri_sub_data_b_cidr = var.pri_sub_data_b_cidr
}

module "security-group" {
  source                     = "../modules/security-group"
  module_prefix              = var.project_name
  vpc_id                     = module.network.vpc_id
}



#----- Web Tier
module "web_alb" {
  source        = "../modules/alb"
  module_prefix = "${var.project_name}-web"
  alb_sg_id     = module.security-group.web_alb_sg_id
  sub_a_id      = module.network.pub_sub_a_id
  sub_b_id      = module.network.pub_sub_b_id
  vpc_id        = module.network.vpc_id
  is_internal   = false
}

module "web_asg" {
  source        = "../modules/asg"
  module_prefix = "${var.project_name}-web"
  sg_id         = module.security-group.web_sg_id
  sub_a_id      = module.network.pub_sub_a_id
  sub_b_id      = module.network.pub_sub_b_id
  tg_arn        = module.web_alb.tg_arn
  user_data     = filebase64("${path.module}/user-data-scripts/simple-apache.sh")
}



#----- App Tier
module "internal_alb" {
  source        = "../modules/alb"
  module_prefix = "${var.project_name}-internal"
  alb_sg_id     = module.security-group.internal_alb_sg_id
  sub_a_id      = module.network.pri_sub_app_a_id
  sub_b_id      = module.network.pri_sub_app_b_id
  vpc_id        = module.network.vpc_id
  is_internal   = true
}

module "app_asg" {
  source        = "../modules/asg"
  module_prefix = "${var.project_name}-app"
  sg_id         = module.security-group.app_sg_id
  sub_a_id      = module.network.pri_sub_app_a_id
  sub_b_id      = module.network.pri_sub_app_b_id
  tg_arn        = module.internal_alb.tg_arn
  user_data     = ""
}


#----- Data Tier
module "rds" {
  source            = "../modules/rds"
  module_prefix     = var.project_name
  db_sg_id          = module.security-group.db_sg_id
  pri_sub_data_a_id = module.network.pri_sub_data_a_id
  pri_sub_data_b_id = module.network.pri_sub_data_b_id
  db_username       = var.db_username
  db_password       = var.db_password
}
