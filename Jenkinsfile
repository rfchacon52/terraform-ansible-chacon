pipeline {

agent any

parameters {
  choice choices: [ 'Deploy_K8', 'Destroy_K8' 'Deploy_Docker'], description: '''Select:  
               1. Deploy_K8  
               2. Destroy_K8 
               3. Deploy_Docker
              ''', name: 'CHOICE'
}
 
 
 environment {
  THE_BUTLER_SAYS_SO  = credentials('aws-creds')
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

        stage('Deploy Docker App') {
           when {
             expression { params.CHOICE == "Deploy_Docker" }
           }
            steps {
                sh '''
                cd auto-mode 

                aws ecr get-login-password --region us-east-1 | \
                podman login --username AWS --password-stdin 767397937300.dkr.ecr.us-east-1.amazonaws.com
                echo "Run podman build" 
                podman build -t rails-app .
                podman tag rails-app:latest 767397937300.dkr.ecr.us-east-1.amazonaws.com/rails-app:latest
                podman push 767397937300.dkr.ecr.us-east-1.amazonaws.com/rails-app:latest
                
                sh '''
               }
             }


    }
}
