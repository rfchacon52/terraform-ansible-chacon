//EKS Master Cluster Security Group

//This security group controls networking access to the Kubernetes masters.
//Needs to be configured also with an ingress rule to allow traffic from the worker nodes.

resource "aws_security_group" "eks-control-plane-sg" {
  name        = "${var.cluster_name}-control-plane"
  description = "Cluster communication with worker nodes [${var.cluster_name}]"
  vpc_id      = module.vpc.vpc_id 

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

