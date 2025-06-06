# sg.tf

# --- Data Sources to reference existing VPC components ---
# Keep this as VPC is created by a separate module and is available earlier
data "aws_vpc" "selected" {
  id = module.vpc.vpc_id
}

# REMOVE THIS ENTIRE BLOCK - WE WILL USE module.eks.cluster_security_group_id DIRECTLY
# data "aws_eks_cluster" "this" {
#   name = local.name
# }


# --- 1. EKS Control Plane API Access Security Group ---
resource "aws_security_group" "eks_cluster_api_access" {
  name        = "${local.name}-api-access-sg"
  description = "Allows restricted access to the EKS cluster API endpoint"
  vpc_id      = data.aws_vpc.selected.id
  tags        = local.tags
}

# Rule: Allow inbound HTTPS from your Mac to EKS API SG
resource "aws_security_group_rule" "eks_api_ingress_from_mac" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.114/32"]
  security_group_id = aws_security_group.eks_cluster_api_access.id
  description       = "Allow EKS API access from local Mac"
}

# Rule: Allow inbound HTTPS from EKS Node Group to EKS API SG
resource "aws_security_group_rule" "eks_api_ingress_from_nodes" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_node_group.id
  security_group_id        = aws_security_group.eks_cluster_api_access.id
  description              = "Allow worker nodes to communicate with control plane (kubelet)"
}

# Rule: Allow egress from EKS API SG to EKS Node Group
resource "aws_security_group_rule" "eks_api_egress_to_nodes" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.eks_node_group.id
  security_group_id        = aws_security_group.eks_cluster_api_access.id
  description              = "Allow control plane to reach worker nodes"
}


# --- 2. EKS Worker Node Security Group ---
resource "aws_security_group" "eks_node_group" {
  name        = "${local.name}-node-group-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = data.aws_vpc.selected.id
  tags        = local.tags

  # Egress: Allow worker nodes to pull container images from ECR, communicate with S3, etc.
  egress {
    description = "Allow worker nodes outbound internet access (e.g., ECR, S3)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Rule: Ingress from EKS Control Plane to Worker Node SG
resource "aws_security_group_rule" "eks_node_ingress_from_control_plane" {
  type                     = "ingress"
  from_port                = 1025 # Kubelet port range
  to_port                  = 65535 # Kubelet port range
  protocol                 = "tcp"
  # CORRECTED: Reference the EKS module's output directly
  source_security_group_id = module.eks.cluster_security_group_id
  security_group_id        = aws_security_group.eks_node_group.id
  description              = "Allow traffic from EKS control plane"
}

# Rule: Ingress from nodes to themselves (self-referencing)
resource "aws_security_group_rule" "eks_node_ingress_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.eks_node_group.id
  description       = "Allow all traffic between nodes in the same security group"
}

# Rule: Ingress from local Mac to NodePort range on Worker Node SG
resource "aws_security_group_rule" "eks_node_ingress_from_mac_nodeport" {
  type              = "ingress"
  from_port         = 30000
  to_port           = 32767
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.114/32"]
  security_group_id = aws_security_group.eks_node_group.id
  description       = "Allow local Mac to access NodePorts (e.g., ArgoCD 30660)"
}

# Rule: Ingress from ALB Ingress SG to NodePort range on Worker Node SG
resource "aws_security_group_rule" "eks_node_ingress_from_alb" {
  type                     = "ingress"
  from_port                = 30000
  to_port                  = 32767
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_ingress.id
  security_group_id        = aws_security_group.eks_node_group.id
  description              = "Allow ALB/NLB to send traffic to worker nodes"
}

# Rule: Egress from Worker Node SG to EKS API Server
resource "aws_security_group_rule" "eks_node_egress_to_api" {
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  # CORRECTED: Reference the EKS module's output directly
  security_group_id        = aws_security_group.eks_node_group.id
  source_security_group_id = aws_security_group.alb_ingress.id
  description              = "Allow worker nodes to communicate with EKS API server"
}


# --- 3. ALB Ingress Security Group ---
resource "aws_security_group" "alb_ingress" {
  name        = "${local.name}-alb-ingress-sg"
  description = "Security group for EKS Application Load Balancer ingress"
  vpc_id      = data.aws_vpc.selected.id
  tags        = local.tags

  ingress {
    description = "Allow HTTP access from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS access from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Rule: Egress from ALB Ingress SG to Worker Node SG
resource "aws_security_group_rule" "alb_egress_to_nodes" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.alb_ingress.id
  source_security_group_id = aws_security_group.alb_ingress.id
  description              = "Allow ALB to send traffic to EKS worker nodes (target groups)"
}
