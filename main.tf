// On spécifie ici le provider de notre choix : aws, azure, ...
provider "aws" {
  access_key = var.aws-access-key
  secret_key = var.aws-secret-key
  region = var.aws-region

  version = "~> 2.0"
}

// déclaration des différents modules
// bucket S3 pour héberger notre front react 
// (! P3 !)
/*
module "s3" {
  source = "./s3"
}
*/

// vpc -> endroit isolé du cloud pour mettre en place des ressources aws dans un réseau virtuel
module "vpc" {
  source = "./vpc"
  vpc_cidr = "10.0.0.0/16"
  public_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
  private_cidrs = ["10.0.5.0/24", "10.0.6.0/24"]
}

// création de 2 instances ec2 -> ici qu'on va placer notre bdd

module "ec2" {
  source = "./ec2"
  my_public_key = "./tmp/id_rsa.pub"
  instance_type = "t2.micro"
  vpc_id = module.vpc.vpc_id
  vpc_sg = module.vpc.security_group
  public_subnet3 = module.vpc.subnet3
  public_subnet4 = module.vpc.subnet4
}

module "alb" {
  source = "./alb"
  vpc_id = module.vpc.vpc_id
  subnet1 = module.vpc.subnet1
  subnet2 = module.vpc.subnet2
}

// auto scalling group => appliqué sur les 2 instances EC2 correspondantes à l'app backend
module "auto_scaling" {
  source = "./auto_scaling"
  vpc_id = module.vpc.vpc_id
  master_ip = module.ec2.slave_db
  subnet1 = module.vpc.subnet1
  subnet2 = module.vpc.subnet2
  security_groups = [module.vpc.security_group]
  target_group_arn = module.alb.alb_target_group_arn
}

/*
// DNS route53
module "route53" {
  source   = "./route53"
  hostname = ["test1", "test2"]
  arecord  = ["10.0.1.11", "10.0.1.12"]
  vpc_id   = module.vpc.vpc_id
}
*/