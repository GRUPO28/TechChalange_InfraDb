data "aws_vpc" "default-vpc" {
  filter {
    name   = "tag:Name"
    values = ["default-us-east-1"]
  }
}

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default-vpc.id]
  }
}

module "documentdb_cluster" {
    source = "cloudposse/documentdb-cluster/aws"
    version = "0.27.0"
    
    name                    = "docdb"
    cluster_size            = 1
    master_username         = var.DB_USER
    master_password         = var.DB_PASSWORD
    instance_class          = "db.t3.medium"
    vpc_id                  = data.aws_vpc.default-vpc.id
    subnet_ids              = data.aws_subnets.subnets.ids
    # allowed_security_groups = ["sg-xxxxxxxx"]
}