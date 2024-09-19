data "aws_subnet" "subnet" {
  filter {
    name   = "tag:Name"
    values = ["default-1a"]
  }
}

module "documentdb_cluster" {
    source = "cloudposse/documentdb-cluster/aws"
    version = "0.27.0"
    
    name                    = "docdb"
    cluster_size            = 1
    master_username         = var.DB_USERNAME
    master_password         = var.DB_PASSWORD
    instance_class          = "db.t3.medium"
    vpc_id                  = data.aws_subnet.subnet.vpc_id
    subnet_ids              = [data.aws_subnet.subnet.id]
    # allowed_security_groups = ["sg-xxxxxxxx"]
}