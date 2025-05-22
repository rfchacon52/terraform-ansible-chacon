# sg.tf

# --- Data Sources to reference existing VPC and EKS components ---
data "aws_vpc" "selected" {
  id = module.vpc.vpc_id
}

# Get the EKS cluster's automatically generated security group ID
# for control plane to node communication. This becomes available after cluster creation.
data "aws_eks_cluster" "this" {
  name = local.name
}

# --- 1. EKS Control Plane API Access Security Group ---
resource "aws_security_group" "eks_cluster_api_access" {
  name        = "${local.name}-api-access-sg"
  description = "Allows restricted access to the EKS cluster API endpoint"
  vpc_id      = data.aws_vpc.selected.id

  # Allow inbound HTTPS from your Mac for kubectl access to the EKS API
  ingress {
    description = "Allow EKS API access from local Mac"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.allowed_mac_ip] # Your local Mac's IP
  }

  # Allow inbound HTTPS from the EKS Node Group for kubelet and other control plane communication
  ingress {
    description     = "Allow worker nodes to communicate with control plane (kubelet)"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_node_group.id]
  }

  # Egress to worker nodes (for control plane to push configurations, logs, etc.)
  egress {
    description     = "Allow control plane to reach worker nodes"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.eks_node_group.id]
  }

  tags = local.tags
}

# --- 2. EKS Worker Node Security Group ---
# This security group is attached to your EC2 worker instances.
# It controls traffic to/from the worker nodes themselves, including NodePorts.
resource "aws_security_group" "eks_node_group" {
  name        = "${local.name}-node-group-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = data.aws_vpc.selected.id

  # Ingress: Allow traffic from EKS control plane (via its automatically created SG)
  ingress {
    description     = "Allow traffic from EKS control plane"
    from_port       = 1025 # Kubelet port range
    to_port         = 65535 # Kubelet port range
    protocol        = "tcp"
    security_groups = [data.aws_eks_cluster.this.vpc_config[0].cluster_security_group_id]
  }

  # Ingress: Allow all traffic between nodes in the same security group (self-referencing)
  # Essential for Pod-to-Pod communication via CNI
  ingress {
    description = "Allow all traffic between nodes in the same security group"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All protocols
    self        = true # Refers to itself
  }

  # Ingress: Allow your local Mac to access NodePorts on worker nodes
  ingress {
    description = "Allow local Mac to access NodePorts (e.g., ArgoCD 30660)"
    from_port   = 30000 # Standard NodePort range start
    to_port     = 32767 # Standard NodePort range end (30660 falls within this)
    protocol    = "tcp"
    cidr_blocks = [var.allowed_mac_ip] # Your local Mac's IP
  }

  # Ingress: Allow ALB/NLB to send traffic to worker nodes (for target groups)
  ingress {
    description     = "Allow ALB/NLB to send traffic to worker nodes"
    from_port       = 30000 # NodePort range
    to_port         = 32767
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_ingress.id] # Reference the ALB Ingress SG
  }

  # Egress: Allow worker nodes to communicate with the EKS API server
  egress {
    description     = "Allow worker nodes to communicate with EKS API server"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [data.aws_eks_cluster.this.vpc_config[0].cluster_security_group_id]
  }

  # Egress: Allow worker nodes to pull container images from ECR, communicate with S3, etc.
  egress {
    description = "Allow worker nodes outbound internet access (e.g., ECR, S3)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

# --- 3. ALB Ingress Security Group ---
# This SG is for the Application Load Balancer created by the AWS Load Balancer Controller.
# It allows public internet access to your applications.
resource "aws_security_group" "alb_ingress" {
  name        = "${local.name}-alb-ingress-sg"
  description = "Security group for EKS Application Load Balancer ingress"
  vpc_id      = data.aws_vpc.selected.id

  # Ingress: Allow HTTP traffic from anywhere
  ingress {
    description = "Allow HTTP access from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress: Allow HTTPS traffic from anywhere
  ingress {
    description = "Allow HTTPS access from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress: ALBs generally need to initiate connections to targets
  # The ALB controller will manage specific egress rules for target groups.
  # This default rule allows outbound traffic to target nodes.
  egress {
    description = "Allow ALB to send traffic to EKS worker nodes (target groups)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All protocols (or more specific to NodePort range)
    security_groups = [aws_security_group.eks_node_group.id]
  }

  tags = local.tags
}

# Optional: Dedicated SSH access security group (if you want more granular control than allowing from all private nodes)
# resource "aws_security_group" "ssh_access_from_mac" {
#   name        = "${local.name}-ssh-access-from-mac-sg"
#   description = "Allow SSH access from specific IPs/CIDRs for worker node access"
#   vpc_id      = data.aws_vpc.selected.id

#   ingress {
#     description = "Allow SSH from local Mac"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = [var.allowed_mac_ip]
#   }
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   tags = local.tags
# }
