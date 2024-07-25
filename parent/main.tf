 provider "aws" {
   region     = var.web_region
   
}

module "jhooq-webserver-1" {
  source = ".//module-1"
  key_name = var.key_name
  key_name2 = var.key_name2
  web_region = var.web_region
   availability_zone1 = var.availability_zone1 
  availability_zone2 = var.availability_zone2
}

module "jhooq-webserver-2" {
  source = ".//module-2"
  key_name = var.key_name
  key_name2 = var.key_name2
  web_region = var.web_region
  availability_zone1 = var.availability_zone1 
  availability_zone2 = var.availability_zone2
}
 
