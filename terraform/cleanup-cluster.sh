#!/bin/bash

# This script automates the cleanup of an Amazon EKS cluster by deleting resources
# in a recommended order to minimize issues during deprovisioning.

# IMPORTANT:
# 1. Replace "your-eks-cluster-name" with the actual name of your EKS cluster.
# 2. Ensure you have 'kubectl' and 'eksctl' installed and configured with
#    appropriate AWS credentials and permissions to manage your EKS cluster.
# 3. This script is destructive and irreversible. All data and resources
#    within the specified cluster will be permanently deleted.
# 4. The 'sleep' commands are delays to allow AWS and Kubernetes to process
#    deletions. You might need to adjust these based on your cluster size
#    and AWS region.

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---

my_cluster_string=$(kubectl config current-context | cut -d '@' -f2)
export EKS_CLUSTER_NAME=$(basename $my_cluster_string)
export REGION=$(echo $my_cluster_string | awk -F : '{print $4}')

echo $EKS_CLUSTER_NAME
echo $REGION


# --- Helper Functions for Logging ---
log_info() {
  echo "INFO: $1"
}

log_error() {
  echo "ERROR: $1" >&2
}


if [ -z "$EKS_CLUSTER_NAME" ]; then
  log_error "EKS_CLUSTER_NAME not provided as an argument."
  exit 1
fi


log_info "--- Starting EKS Cluster Cleanup ---"
log_info "Target Cluster: ${EKS_CLUSTER_NAME}"
log_info ""
log_info "This script will perform the following cleanup steps in order:"
log_info "1. Delete all pods across all namespaces."
log_info "2. Delete AWS VPC CNI (aws-node DaemonSet)."
log_info "3. Delete all node groups associated with the cluster."
log_info "4. Delete the EKS cluster control plane itself."
log_info ""
log_info "!!! WARNING: This action is irreversible and will permanently delete !!!"
log_info "!!! all resources associated with the cluster. Proceed with extreme !!!"
log_info "!!! caution.                                                      !!!"
log_info ""


# Ensure kubectl is configured to use the correct context for the cluster.
# This command updates your kubeconfig. It's good practice to run it before
# kubectl commands if your kubeconfig might be outdated or pointing elsewhere.
log_info "Updating kubeconfig for cluster: ${EKS_CLUSTER_NAME}..."
aws eks update-kubeconfig --name "${EKS_CLUSTER_NAME}" || log_error "Failed to update kubeconfig. Ensure AWS CLI is configured and cluster name is correct."

# --- Step 1: Delete all pods in the cluster ---
log_info "Step 1/4: Deleting all pods across all namespaces..."
# This command attempts to forcefully delete all pods. Pods managed by controllers
# (like Deployments, StatefulSets) might be recreated until their controllers are removed.
# However, clearing pods first helps reduce active workloads.
kubectl delete pods --all-namespaces  --force --grace-period=0 || log_error "Failed to delete all pods. Some pods might remain, but cleanup will continue."
log_info "Waiting for 30 seconds for pods to terminate..."
sleep 30

# --- Step 2: Delete AWS VPC CNI (aws-node DaemonSet) ---
log_info "Step 2/4: Deleting AWS VPC CNI (aws-node DaemonSet)..."
# The AWS VPC CNI is typically deployed as a DaemonSet named 'aws-node' in the 'kube-system' namespace.
# Deleting it ensures the networking component is removed before nodes are terminated,
# which can prevent stuck deletions.
kubectl delete daemonset aws-node -n kube-system || log_error "Failed to delete aws-node DaemonSet. Continuing anyway, but this might cause issues."
log_info "Waiting for 15 seconds for VPC CNI to be removed..."
sleep 15

# --- Step 3: Delete all node groups ---
log_info "Step 3/4: Deleting all node groups for cluster: ${EKS_CLUSTER_NAME}..."
# This command deletes all managed and unmanaged nodegroups associated with the cluster.
# This operation can take a significant amount of time as EC2 instances are terminated.
eksctl delete nodegroup --cluster "${EKS_CLUSTER_NAME}" --all --approve || log_error "Failed to delete nodegroups. Continuing anyway, but manual cleanup might be needed."
log_info "Node group deletion initiated. This may take several minutes. Waiting for 120 seconds for initial termination..."
sleep 120 # Give some time for nodegroups to start terminating

# --- Step 4: Delete the EKS cluster ---
log_info "Step 4/4: Deleting EKS cluster control plane: ${EKS_CLUSTER_NAME}..."
# This is the final and most critical step. It deletes the EKS control plane
# and waits for its complete removal.
eksctl delete cluster --name "${EKS_CLUSTER_NAME}" --approve || log_error "Failed to delete EKS cluster. Manual intervention required."

log_info "--- EKS Cluster Cleanup Script Finished ---"
log_info "Please verify in your AWS console that all resources related to '${EKS_CLUSTER_NAME}' have been removed."
log_info "It may take additional time for all AWS resources to fully deprovision."

