# terragrunt.hcl - Root configuration for all environments

# Define common inputs that apply to all environments.  These can be overridden
# in the specific environment files (e.g., dev/terragrunt.hcl).
inputs = {
  region = "us-east-1" #  Change this to your desired AWS region
  environment_name = "" # This will be set in each environment's terragrunt.hcl
  project_name = "my-vpc-app" #  Change to your project name
  
  // VPC Configuration
  vpc_cidr = "10.0.0.0/16"
  
  // Public Subnet Configuration
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  
  // Private Subnet Configuration
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  
  // Instance Type
  instance_type = "t2.micro"
  
  // Number of EC2 instances
  instance_count = 2
  
  // ALB Name
  alb_name = "" # Will be set per-environment
  
  // AMI ID -  Important:  Use a current, correct AMI for your region.
  ami_id = "ami-0c55b956cb0f9e57a" # Example:  Amazon Linux 2 in us-east-1.  Change this!
}

# Blocks of configurations
include {
  path = find_in_parent_folders()
}

# Configure the source of the Terraform module.  This should point to
# a module in a Git repository, Terraform Registry, or a local path.
terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws?version=5.1.0" # Example.  Use a specific version.
}

# Define the variables that will be passed to the Terraform module.  These
# should align with the variables defined in the module.
inputs = {
  region = "${local.region}"
  environment_name = "${local.environment_name}"
  project_name = "${local.project_name}"
  vpc_cidr = "${local.vpc_cidr}"
  public_subnet_cidrs = "${local.public_subnet_cidrs}"
  private_subnet_cidrs = "${local.private_subnet_cidrs}"
  instance_type = "${local.instance_type}"
  instance_count = "${local.instance_count}"
  alb_name = "${local.alb_name}"
  ami_id   = "${local.ami_id}"
}
```hcl
# terragrunt.hcl -  dev/terragrunt.hcl
include {
  path = find_in_parent_folders("root")
}

locals {
  environment_name = "dev"
  alb_name = "dev-alb"
}
```hcl
# terragrunt.hcl - staging/terragrunt.hcl
include {
  path = find_in_parent_folders("root")
}

locals {
  environment_name = "staging"
  alb_name = "staging-alb"
}
```hcl
# terragrunt.hcl - prod/terragrunt.hcl
include {
  path = find_in_parent_folders("root")
}

locals {
  environment_name = "prod"
  alb_name = "prod-alb"
}
```
**Explanation:**

1.  **`terragrunt.hcl` (Root):**
    * Defines common inputs like region, VPC CIDR, subnet CIDRs, instance type, and count.  These apply to all environments.
    * Sets the Terraform module source.  I've used an example from the Terraform Registry; you might need to adjust this.  **Important:** Use a specific version.
    * Defines the input variables that will be passed to the Terraform module.
    * Uses `find_in_parent_folders()` to locate the root `terragrunt.hcl` file. This is crucial for inheritance.

2.  **`dev/terragrunt.hcl`:**
    * Sets the `environment_name` to "dev".
    * Sets the `alb_name` to "dev-alb".
    * Inherits the common configuration from the root `terragrunt.hcl` using the `include` block.
    * The `locals` block defines variables specific to the "dev" environment, overriding the empty `environment_name` and `alb_name` in the root.

3.  **`staging/terragrunt.hcl` and `prod/terragrunt.hcl`:**
    * Similar to `dev/terragrunt.hcl`, but set the `environment_name` and `alb_name` for "staging" and "prod" environments, respectively.

**Key Points:**

* **Modularization:** This structure promotes reusability and organization.  The root `terragrunt.hcl` holds the common configuration, while each environment's file provides specific values.
* **Inheritance:** Terragrunt's `include` block is essential for inheriting configurations.
* **Variables:** Variables are used to customize the deployment for each environment.
* **Terraform Module:** The `source` attribute specifies the Terraform module to use.  You'll need to choose a suitable module (from the Terraform Registry or a local/remote source) that creates the VPC, subnets, ALB, and EC2 instances.  The example I've provided is a general-purpose VPC module; you might need a more specialized one or create your own.
* **AMI ID:** **Critical:** The `ami_id` is an example.  You **must** replace it with a valid AMI ID for your desired operating system and region.  You can find AMI IDs in the AWS Management Console.
* **Region:** The `region` is set in the root `terragrunt.hcl`.  Change it to your desired AWS region.
* **ALB Security Groups:** The provided code does not explicitly create security groups for the ALB and EC2 instances.  You'll need to add security group rules in your Terraform module to allow traffic to the ALB (port 80 or 443) and from the ALB to the EC2 instances.
* **EC2 Security Groups:** Similarly, the EC2 instances need security group rules to allow inbound traffic from the ALB.
* **Terraform State:** Terragrunt will manage the Terraform state for each environment separately, ensuring isolation.
* **Load Balancer Type:** This configuration creates an Application Load Balancer.  If you need a different type (e.g., Network Load Balancer), you'll need to adjust the Terraform module and its variables.
* **Dependencies:** For a complete deployment, you might need to define dependencies between modules (e.g., the EC2 instances depend on the VPC and ALB).  Terragrunt's `dependencies` block can be used for this.

**To Use This Code:**

1.  **Set up Terragrunt:** Install Terragrunt on your system.
2.  **Create a Directory Structure:**
    ```
    my-vpc-app/
    ├── terragrunt.hcl
    ├── dev/
    │   └── terragrunt.hcl
    ├── staging/
    │   └── terragrunt.hcl
    └── prod/
        └── terragrunt.hcl
    ```
3.  **Place the Code:** Copy the code into the corresponding files.
4.  **Modify `terragrunt.hcl`:**
    * Change the `region` and `ami_id` in the root `terragrunt.hcl`.
    * **Crucially**, update the `source` attribute to point to a suitable Terraform module.
5.  **Run Terragrunt:** In each environment directory (dev, staging, prod), run `terragrunt apply`.  Terragrunt will automatically handle the `terraform init`, `terraform plan`, and `terraform apply` comman
