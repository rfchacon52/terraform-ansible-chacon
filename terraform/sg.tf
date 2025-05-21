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
    Environment = "Dev" # Or your environment
  }
}

# main.tf or security_groups.tf

# --- Local Values ---
# Define common tags and other variables for consistency
locals {
  cluster_name = var.cluster_name # Replace with your cluster name
  vpc_id       = module.vpc.vpc_id  # Replace with your VPC ID
  # Example: CIDR blocks allowed to access the EKS API endpoint publicly
  allowed_api_cidrs = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24","10.0.3.0/24","10.0.0.0/16" ] # Replace with your office/VPN CIDRs
}

# --- 1. EKS Control Plane Security Group ---
# This SG is created by EKS automatically. However, you can associate
# additional security groups with the cluster to restrict access to the
# public API endpoint or to allow specific traffic to the private endpoint.
# The `cluster_security_group_id` output from the aws_eks_cluster resource
# will give you the ID of the EKS-managed security group.
# For security best practices, you often want to restrict inbound access
# to the EKS API endpoint from the public internet.

resource "aws_security_group" "eks_cluster_api_access" {
  name        = "${local.cluster_name}-api-access"
  description = "Allows access to the EKS cluster API endpoint"
  vpc_id      = local.vpc_id

  ingress {
    description = "Allow EKS worker nodes to communicate with control plane"
    from_port   = 443 # Kubernetes API server port
    to_port     = 443
    protocol    = "tcp"
    # This should be the security group of your worker nodes
    security_groups = [aws_security_group.eks_node_group.id]
  }

  # Ingress rules for public API endpoint (if public access is enabled)
  dynamic "ingress" {
    for_each = local.allowed_api_cidrs
    content {
      description = "Allow specific CIDRs to access EKS API"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  # Egress rule for control plane to reach worker nodes
  egress {
    description = "Allow control plane to reach worker nodes (kubelet, CNI)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All protocols
    # This should be the security group of your worker nodes
    security_groups = [aws_security_group.eks_node_group.id]
  }

  tags = {
    Name        = "${local.cluster_name}-api-access"
    Environment = "production" # Or your environment
  }
}

# --- 2. EKS Worker Node Security Group ---
# This security group is attached to your EC2 worker instances (managed node groups or self-managed).
# It defines how worker nodes can communicate with the control plane, with each other,
# and potentially with other AWS services.

resource "aws_security_group" "eks_node_group" {
  name        = "${local.cluster_name}-node-group"
  description = "Security group for EKS worker nodes"
  vpc_id      = local.vpc_id

  # Ingress: Allow traffic from control plane
  ingress {
    description = "Allow traffic from EKS control plane"
    from_port   = 1025 # Kubelet port range
    to_port     = 65535 # Kubelet port range
    protocol    = "tcp"
    # Reference the EKS cluster's managed security group (output from aws_eks_cluster)
    # This is crucial for control plane to node communication
    security_groups = [data.aws_eks_cluster.this.vpc_config[0].cluster_security_group_id]
  }

  # Ingress: Allow traffic between nodes in the same security group (self-referencing)
  # This allows Pod-to-Pod communication and node-to-node communication
  ingress {
    description = "Allow all traffic between nodes in the same security group"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All protocols
    self        = true # Refers to itself
  }

  # Ingress: Optional - Allow SSH access to worker nodes (for troubleshooting/admin)
  # It's highly recommended to restrict this to specific CIDRs, VPN, or bastion hosts.
  # For managed node groups, you can specify `remote_access` in the node group config.
  ingress {
    description = "Allow SSH from specific IPs/CIDRs for worker node access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.vpc_id_cidr_block] # Example: Allow from within the VPC
    # cidr_blocks = ["YOUR_TRUSTED_IP/32"] # Replace with specific IPs
  }

  # Egress: Allow worker nodes to communicate with the EKS API server
  egress {
    description = "Allow worker nodes to communicate with EKS API server"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    # Reference the EKS cluster's managed security group
    security_groups = [data.aws_eks_cluster.this.vpc_config[0].cluster_security_group_id]
  }

  # Egress: Allow worker nodes to pull container images from ECR, communicate with S3, etc.
  # This typically means allowing outbound to the internet (or NAT Gateway).
  egress {
    description = "Allow worker nodes to communicate with the internet (e.g., ECR, S3)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.cluster_name}-node-group"
    # IMPORTANT: These tags are required by EKS for the worker nodes to register correctly
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }
}

# --- 3. Security Group for Ingress (e.g., ALB) ---
# This SG is for your Application Load Balancer (ALB) or Network Load Balancer (NLB)
# created by the AWS Load Balancer Controller.
# It defines what inbound traffic is allowed to your applications.

resource "aws_security_group" "alb_ingress" {
  name        = "${local.cluster_name}-alb-ingress"
  description = "Security group for EKS Application Load Balancer ingress"
  vpc_id      = local.vpc_id

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

  # Egress: Allow ALB to send traffic to worker nodes (target groups)
  egress {
    description = "Allow ALB to send traffic to EKS worker nodes"
    from_port   = 30000 # Typical NodePort range, or target group health checks
    to_port     = 32767 # Or specific service ports exposed by your applications
    protocol    = "tcp"
    # The worker node security group is the destination
    security_groups = [aws_security_group.eks_node_group.id]
  }

  tags = {
    Name        = "${local.cluster_name}-alb-ingress"
    Environment = "production"
    # Required tag for ALB controller to discover and manage this SG
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }
}

# --- 4. (Optional) Security Group for Pods (SGfP) ---
# If you enable Security Groups for Pods (ENABLE_POD_ENI=true on VPC CNI),
# you will create specific security groups for your Pods. This is a powerful
# feature for fine-grained network segmentation.
# These security groups are typically defined and associated with Pods via
# a Kubernetes `SecurityGroupPolicy` Custom Resource, but you define the
# actual `aws_security_group` here.

resource "aws_security_group" "app_pod_sg" {
  name        = "${local.cluster_name}-app-pod-sg"
  description = "Security Group for specific application Pods"
  vpc_id      = local.vpc_id

  # Ingress: Example - Allow traffic from ALB Ingress SG to your app Pods
  ingress {
    description     = "Allow traffic from ALB Ingress"
    from_port       = 8080 # Your application's listening port
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_ingress.id]
  }

  # Ingress: Example - Allow traffic from other Pods in the same SG (e.g., microservices)
  ingress {
    description = "Allow traffic from other Pods in this SG"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # Egress: Allow Pods to reach other services (e.g., RDS, DynamoDB, S3)
  egress {
    description = "Allow outbound to other AWS services"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Be more restrictive if possible (e.g., VPC CIDR, service endpoints)
  }

  tags = {
    Name        = "${local.cluster_name}-app-pod-sg"
    Environment = "production"
    # This tag is often required by the ALB controller if SGfP is enabled
    # "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }
}

# --- Data Source to get EKS cluster's managed security group ID ---
# This is needed to reference the automatically created EKS cluster security group
# for communication between the control plane and worker nodes.
#data "aws_eks_cluster" "this" {
#  name = local.cluster_name
# }

# --- Data Source to get VPC CIDR Block ---
# Used for example SSH ingress to worker nodes from within the VPC.
data "aws_vpc" "selected" {
  id = local.vpc_id
}

locals {
  vpc_id_cidr_block = data.aws_vpc.selected.cidr_block
}