pipeline {

agent any

parameters {
  choice choices: ['Build_Deploy_ASG', 'Build_Deploy_K8', 'Destroy_ASG', 'Destroy_K8', 'Fix_state'], description: '''Select [  Build_Deploy_EC2 to build EC2
               
               1. Build_Deploy_ASG
               2. Build_Deploy_K8 to build full EKS 
               3. Destroy_ASG to destroy ASG 
               4. Destroy_K8 to destroy EKS
               Fix_state to run state commands  ]''', name: 'CHOICE'
}
 
 
 environment {
  TF_VAR_access_key     = credentials('AWS_ACCESS_KEY_ID') 
  TF_VAR_secret_key     = credentials('AWS_SECRET_ACCESS_KEY')  
  KUBE_CONFIG_PATH      = '~/.kube/config'
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
        
        stage('Terraform ASG Init & Plan & Apply') {
           when {
             expression { params.CHOICE == "Build_Deploy_ASG" }  
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
                echo "Executing terraform plan"                 
                terraform plan -out=tfplan -no-color
                echo "Executing terraform apply"                 
                terraform apply tfplan -no-color
                sh '''
            }
        }

        stage('TerraForm build/deploy K8 Infra') {
           when {
             expression { params.CHOICE == "Build_Deploy_K8" }  
           }
             steps {
                sh '''
                export KUBE_CONFIG_PATH=~/.kube/config
                cd terraform
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
             expression { params.CHOICE == "Build_Deploy_K8" }  
           }
            steps {
                sh '''
                cd terraform
                export KUBE_CONFIG_PATH=~/.kube/config
                echo "Executing update-kubeconfig on cluster EKS-blueprints  region us-east-1"
                aws eks update-kubeconfig --region us-east-1 --name EKS-blueprints 
                echo "Executing Get all pods"
                kubectl get pods -A -o wide
                cd apps_deploy
                echo "Deploying EKS Apps"           
                kubectl apply -f hello-kubernetes.yaml
                kubectl apply -f service-loadbalancer.yaml 
                echo "Deploying prometheus-community chart"
                kubectl create namespace prometheus
                helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
                helm upgrade -i prometheus prometheus-community/prometheus \
                --namespace prometheus \
                --set alertmanager.persistence.storageClass="gp2" \
                --set server.persistentVolume.storageClass="gp2"
                sh '''
            }
        }

        stage('Terraform K8 Destroy') {
           when {
             expression { params.CHOICE == "Destroy_K8" }  
           }
            steps {
                sh '''
                cd terraform
                echo "Running terraform init"
                terraform init -no-color
                echo "Running terraform validate"
                terraform  validate -no-color
                echo "Executing Terraform K8 Destroy"
                terraform apply -destroy -auto-approve -no-color
                sh '''
            }
        }

        stage('Terraform Fix State file') {
           when {
             expression { params.CHOICE == "Fix_state" }  
           }
            steps {
                sh '''
                export KUBE_CONFIG_PATH=~/.kube/config
                cd terraformk8
                echo "Running terraform init"
                terraform init -no-color
                echo "Running terraform fmt -recursive"
                terraform fmt -recursive
                echo "Running terraform validate"
                terraform validate -no-color
                terraform refresh -no-color
                terraform apply -auto-approve -no-color
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

    }

}


