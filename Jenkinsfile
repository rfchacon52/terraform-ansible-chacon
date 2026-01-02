pipeline {

agent any

parameters {
  choice choices: [ 'Deploy_K8', 'Destroy_K8'], description: '''Select:  
               1. Deploy_K8  
               2. Destroy_K8 
              ''', name: 'CHOICE'
}
 
 
 environment {
  THE_BUTLER_SAYS_SO  = credentials('aws-creds')
  KUBE_CONFIG_PATH      = '~/.kube/config'
  MAVEN_HOME            = '/usr/share/maven' 
  ANSIBLE_INVENTORY     = '/etc/ansible/inventory.ini'
    }    
    options {
        // This is required if you want to clean before build
        skipDefaultCheckout(true)
    }
        
    stages {

        stage('Checkout') {

            steps {
                // Clean before build
                cleanWs()
                // Clone the repo
                git branch: 'main', url: 'https://github.com/rfchacon52/terraform-ansible-chacon.git' 

            }

        }


        stage('TerraForm build/deploy K8 Infra') {
           when {
             expression { params.CHOICE == "Deploy_K8" }  
           }
             steps {
                sh '''
                cd auto-mode 
                export KUBE_CONFIG_PATH=~/.kube/config
                echo "Running terraform init"
                terraform init -no-color
                echo "Running terraform fmt -recursive"
                terraform fmt -recursive
                echo "Running terraform validate"
                terraform  validate -no-color
                echo "Executing terraform plan"                 
                terraform plan -out=tfplan -no-color
                echo "Executing terraform apply"                 
                terraform apply tfplan -no-color
                sh '''
            }
        }

        stage('Configure Kubectl, Deploy EKS apps') {
           when {
             expression { params.CHOICE == "Deploy_K8_no" }  
           }
            steps {
                sh '''
                cd terraform
                export KUBE_CONFIG_PATH=~/.kube/config
                aws eks update-kubeconfig --region us-east-1 --name eksblue 
                echo "Executing Get all pods"
                kubectl get all -A -o wide
                kubectl apply -f apps_deploy/hello-kubernetes.yaml
                kubectl apply -f apps_deploy/service-loadbalancer.yaml
                kubectl apply -f apps_deploy/ingress.yaml
                sh '''
            }
        }

        stage('Terraform K8 Destroy') {
           when {
             expression { params.CHOICE == "Destroy_K8" }  
           }
            steps {
                sh '''
                cd auto-mode 
                echo "Running terraform init"
                terraform init -no-color
                echo "Running terraform validate"
                terraform  validate -no-color
                echo "Executing Terraform K8 Destroy"
                terraform apply -destroy -auto-approve -no-color
                sh '''
            }
        }

        stage('Terraform Deploy SFTP') {
           when {
             expression { params.CHOICE == "Deploy_SFTP" }  
           }
            steps {
                sh '''
                cd sftp 
                echo "Running terraform init"
                terraform init -no-color
                echo "Running terraform fmt -recursive"
                terraform fmt -recursive
                echo "Running terraform validate"
                terraform validate -no-color
                echo "Executing terraform plan"                 
                terraform plan -out=tfplan -no-color
                echo "Executing terraform apply"                 
                terraform apply tfplan -no-color
                sh '''
            }
        }


        stage('Terraform Destroy SFTP') {
           when {
             expression { params.CHOICE == "Destroy_SFTP" }  
           }
            steps {
                sh '''
                cd sftp 
                echo "Running terraform init"
                terraform init -no-color
                echo "Running terraform fmt -recursive"
                terraform fmt -recursive
                echo "Running terraform validate"
                terraform validate -no-color
                echo "Executing Terraform Destroy"
                terraform apply -destroy -auto-approve -no-color
                sh '''
            }
        }


        stage('Terraform ASG Destroy') {
           when {
             expression { params.CHOICE == "Destroy_ASG" }  
           }
            steps {
                sh '''
                cd terraform-asg
                echo "Running terraform init"
                terraform init -no-color
                echo "Running terraform fmt -recursive"
                terraform fmt -recursive
                echo "Running terraform validate"
                terraform validate -no-color
                echo "Executing Terraform EC2 Destroy"
                terraform apply -destroy -auto-approve -no-color
                sh '''
            }

}


  stage('Terraform ALB Deploy') {
           when {
             expression { params.CHOICE == "Deploy_ALB" }  
           }
            steps {
                sh '''
                cd terraform_ALB
                echo "Running terraform init"
                terraform init -no-color
                echo "Running terraform fmt -recursive"
                terraform fmt -recursive
                echo "Running terraform validate"
                terraform validate -no-color
                echo "Executing terraform plan"                 
                terraform plan -out=tfplan -no-color
                echo "Executing terraform apply"                 
                terraform apply tfplan -no-color 
                sh '''
            }

}

  stage('Terraform ALB Destroy') {
           when {
             expression { params.CHOICE == "Destroy_ALB" }  
           }
            steps {
                sh '''
                cd terraform_ALB
                echo "Running terraform init"
                terraform init -no-color
                echo "Running terraform fmt -recursive"
                terraform fmt -recursive
                echo "Running terraform validate"
                terraform validate -no-color
                echo "Executing Terraform EC2 Destroy"
                terraform apply -destroy -auto-approve -no-color
                sh '''
            }
  }

    }
}
