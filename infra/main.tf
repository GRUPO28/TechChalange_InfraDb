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
    cluster_family          = "docdb5.0"
    engine_version          = "5.0.0"
    master_username         = var.DB_USER
    master_password         = var.DB_PASSWORD
    instance_class          = "db.t3.medium"
    vpc_id                  = data.aws_vpc.default-vpc.id
    subnet_ids              = data.aws_subnets.subnets.ids
    allowed_cidr_blocks     = ["0.0.0.0/0"]
    cluster_parameters      = [{
                                apply_method = "pending-reboot"
                                name         = "tls"
                                value        = "disabled"
                              }]
    # allowed_security_groups = ["sg-xxxxxxxx"]
}

# Security Group para permitir acesso ao RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow MySQL access"
  vpc_id = data.aws_vpc.default-vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Instância MySQL elegível ao Free Tier
resource "aws_db_instance" "mysql_free_tier" {
  allocated_storage    = 20                      # Free Tier nao mudar
  storage_type         = "gp2"                   # Free Tier nao mudar
  engine               = "mysql"                 
  engine_version       = "8.0.28"                
  instance_class       = "db.t2.micro"           # Free Tier nao mudar
  db_name              = "pedido"            
  username             = var.DB_USER            
  password             = var.DB_PASSWORD
  publicly_accessible  = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id] # configurar VPC
  backup_retention_period = 7                    
  skip_final_snapshot     = true                 
  multi_az                = false                # Free Tier nao mudar

  tags = {
    name = "MySQL-FreeTier"
  }
}