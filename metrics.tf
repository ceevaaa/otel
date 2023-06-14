# main.tf

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.21"
}

variable "volume_size" {
  description = "Size of the persistent volume"
  type        = number
  default     = 10
}

variable "volume_type" {
  description = "Type of the persistent volume"
  type        = string
  default     = "gp2"
}

variable "lb_port" {
  description = "Load balancer port"
  type        = number
  default     = 80
}

variable "lb_protocol" {
  description = "Load balancer protocol"
  type        = string
  default     = "HTTP"
}

provider "aws" {
  region = var.region
}

resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids = var.subnet_ids
  }
}

resource "aws_iam_role" "cluster" {
  name = "${var.cluster_name}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "${var.cluster_name}-nodes"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.subnet_ids
}

resource "aws_iam_role" "node" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "node" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name

  depends_on = [aws_iam_role.node]
}

resource "aws_iam_role_policy_attachment" "cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name

  depends_on = [aws_iam_role.node]
}


resource "aws_db_instance" "my_rds_instance" {
  identifier            = "my-rds-instance"
  engine                = "mysql"  # Specify the desired database engine
  instance_class        = "db.t3.micro"  # Specify the desired instance type
  allocated_storage     = 20  # Specify the desired allocated storage in GB
  multi_az              = false  # Set to true for multi-AZ deployment
  storage_type          = "gp2"  # Specify the storage type
  publicly_accessible  = false  # Set to true if you want the instance to be publicly accessible

  # Specify the desired username and password for the master user
  username              = "admin"
  password              = "mypassword"

  # Specify the desired VPC and subnet group for the RDS instance
  vpc_security_group_ids = ["sg-xxxxxxxx"]
  db_subnet_group_name  = "my-db-subnet-group"

  # Additional optional configurations can be specified here
  # ...

  # Specify the desired tags for the RDS instance
  tags = {
    Name = "MyRDSInstance"
  }
}

resource "null_resource" "install_otel_collector" {
  provisioner "remote-exec" {
    inline = [
      "wget -qO- https://example.com/otel-collector-install.sh | sh",
      "sudo systemctl enable otel-collector",
      "sudo systemctl start otel-collector",
      # Additional configuration steps as needed
    ]
  }

  # Specify the connection details to the EKS cluster nodes
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
    host        = aws_instance.my_eks_node.public_ip
  }
}

resource "null_resource" "install_cribl_pipeline" {
  provisioner "remote-exec" {
    inline = [
      "wget -qO- https://example.com/cribl-pipeline-install.sh | sh",
      "sudo systemctl enable cribl-pipeline",
      "sudo systemctl start cribl-pipeline",
      # Additional configuration steps as needed
    ]
  }

  # Specify the connection details to the EKS cluster nodes
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
    host        = aws_instance.my_eks_node.public_ip
  }
}

data "template_file" "otel_collector_config" {
  template = file("otel-collector-config.tpl")

  vars = {
    datadog_api_key         = var.datadog_api_key
    cribl_pipeline_address  = var.cribl_pipeline_address
  }
}

output "otel_collector_config" {
  value = data.template_file.otel_collector_config.rendered
}


