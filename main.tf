// On spécifie ici le provider de notre choix : aws, azure, ...
provider "aws" {
  access_key = var.aws-access-key
  secret_key = var.aws-secret-key
  region = var.aws-region

  version = "~> 2.0"
}

// déclaration des différents modules
// bucket S3 pour héberger notre front react 
// EXCLUSIF Platform 3
/*
module "s3" {
  source = "./s3"
}
*/
// vpc -> endroit isolé du cloud pour mettre en place des ressources aws dans un réseau virtuel
module "vpc" {
  source = "./vpc"
  vpc_cidr = "10.0.0.0/16"
  public_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  private_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
}

// instance ec2 -> ici qu'on va placer notre application java + notre front + notre bdd
module "ec2" {
  source = "./ec2"
  my_public_key = "./tmp/id_rsa.pub"
  instance_type = "t2.micro"
  security_group = module.vpc.security_group
  subnets = module.vpc.private_subnets
}