provider "aws" {
  # Credentials handled by 'export' commands in terminal
}

# 1. Foundation VPC
resource "aws_vpc" "myapp_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

# 2. Subnet Module - Handles IGW and Route Tables
module "myapp-subnet" {
  source                 = "./modules/subnet"
  vpc_id                 = aws_vpc.myapp_vpc.id
  subnet_cidr_block      = var.subnet_cidr_block
  availability_zone      = var.availability_zone
  env_prefix             = var.env_prefix
  default_route_table_id = aws_vpc.myapp_vpc.default_route_table_id
}

# 3. Task 6: Nginx Proxy Server (Instance Suffix 0)
module "myapp-webserver" {
  source            = "./modules/webserver"
  env_prefix        = var.env_prefix
  instance_type     = var.instance_type
  availability_zone = var.availability_zone
  public_key        = var.public_key
  my_ip             = local.my_ip
  vpc_id            = aws_vpc.myapp_vpc.id
  subnet_id         = module.myapp-subnet.subnet.id
  script_path       = "./entry-script.sh" # Task 6 HTTPS Script
  instance_suffix   = "0"
}

# 4. Task 7: Apache Backend Server (Instance Suffix 1)
module "myapp-web-1" {
  source            = "./modules/webserver"
  env_prefix        = var.env_prefix
  instance_type     = var.instance_type
  availability_zone = var.availability_zone
  public_key        = var.public_key
  my_ip             = local.my_ip
  vpc_id            = aws_vpc.myapp_vpc.id
  subnet_id         = module.myapp-subnet.subnet.id
  script_path       = "./apache.sh"       # Task 7 Apache Script
  instance_suffix   = "1"
}
module "myapp-web-2" {
  source            = "./modules/webserver"
  env_prefix        = var.env_prefix
  instance_type     = var.instance_type
  availability_zone = var.availability_zone
  public_key        = var.public_key
  my_ip             = local.my_ip
  vpc_id            = aws_vpc.myapp_vpc.id
  subnet_id         = module.myapp-subnet.subnet.id
  script_path       = "./apache.sh" # Uses the same backend script as web-1
  instance_suffix   = "2"          # Unique suffix for the third instance
}


# Data source for SSH access security
data "http" "my_ip" {
  url = "https://icanhazip.com"
}