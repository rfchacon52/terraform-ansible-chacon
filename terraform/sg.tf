resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = module.vpc.vpc_id
ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
cidr_blocks = [
      "10.0.0.0/16",
    ]
  }
}
resource "aws_security_group" "worker_group_mgmt_two" {
  name_prefix = "worker_group_mgmt_two"
  vpc_id      = module.vpc.vpc_id
ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
cidr_blocks = [
      "10.0.0.0/16",
    ]
  }
}
resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = module.vpc.vpc_id
ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
cidr_blocks = [
      "10.0.0.0/16",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}


resource "aws_security_group" "eks_worker_node_ingress_argocd_http" {
  name        = "eks-argocd-http-nodeport-ingress"
  description = "Allow HTTP access to ArgoCD NodePort service in EKS"
  vpc_id      = module.vpc.vpc_id # Replace with your EKS cluster's VPC ID

  ingress {
    description = "Allow HTTP access to ArgoCD NodePort"
    from_port   = 30660 # The NodePort for HTTP
    to_port     = 30660 # The NodePort for HTTP
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Be cautious: 0.0.0.0/0 means open to the world.
                                # Restrict this to known IP ranges if possible.
  }

  ingress {
    description = "Allow HTTPS access to ArgoCD NodePort"
    from_port   = 30279 # The NodePort for HTTPS
    to_port     = 30279 # The NodePort for HTTPS
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Be cautious: 0.0.0.0/0 means open to the world.
                                # Restrict this to known IP ranges if possible.
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "eks-argocd-nodeport-sg"
    Environment = "production" # Or your environment
  }
}


