pipeline {

agent any

parameters {
  choice choices: ['Build_Deploy_EC2', 'Build_Deploy_K8', 'Destroy_EC2', 'Destroy_K8', 'Fix_state'], description: '''Select [  Build_Deploy_EC2 to build EC2
               Build_Deploy_K8 to build EKS
               Destroy_EC2 to remove EC2
               Destroy_K8 to remove EKS
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
        
        stage('Terraform EC2 Init & Plan & Apply') {
           when {
             expression { params.CHOICE == "Build_Deploy_EC2" }  
           }
            steps {
                
                sh '''
                cd terraform
                echo "Running terraform init"
                terraform init -no-color
                echo "Running terraform fmt -recursive"
                terraform fmt -recursive
                echo "Running terraform validate"
                terraform validate -no-color
                sh '''

                sh '''
                echo "Executing terraform plan"                 
                cd terraform; terraform plan -out=tfplan -no-color
                sh '''
                sh '''
                echo "Executing terraform apply"                 
                cd terraform; terraform apply tfplan -no-color
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
                cd 112/terraform 
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

        stage('Configure Kubectl, Create Storage-Class') {
           when {
             expression { params.CHOICE == "Build_Deploy_K8" }  
           }
            steps {
                sh '''
                cd 112/terraform 
                export KUBE_CONFIG_PATH=~/.kube/config
                echo "Executing update-kubeconfig on cluster dev-demo region us-west-1"
                aws eks update-kubeconfig --region us-east-1 --name demo 
                echo "Executing Get all pods"
                kubectl get pods -A -o wide
                sh '''
            }
        }

        stage('Terraform K8 Destroy') {
           when {
             expression { params.CHOICE == "Destroy_K8" }  
           }
            steps {
                sh '''
                cd 112/terraform 
                echo "Running terraform init"
                terraform init -no-color
                echo "Running terraform fmt -recursive"
                terraform fmt -recursive
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

        stage('Terraform EC2 Destroy') {
           when {
             expression { params.CHOICE == "Destroy_EC2" }  
           }
            steps {
                sh '''
                cd terraform
                echo "Running terraform init"
                terraform init -no-color
                echo "Running terraform fmt -recursive"
                terraform fmt -recursive
                echo "Running terraform validate"
                terraform validate -no-color
                sh '''
                sh '''
                echo "Executing Terraform EC2 Destroy"
                cd terraform; terraform apply -destroy -auto-approve -no-color
                sh '''
            }

        }

    }

}


