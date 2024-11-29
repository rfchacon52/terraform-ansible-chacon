pipeline {

agent any

parameters {
  choice choices: ['Build_Deploy_EC2', 'Build_Deploy_K8', 'Destroy_EC2', 'Destroy_K8 '], description: '''Select [  Build_Deploy_EC2 to build EC2
               Build_Deploy_K8 to build EKS
               Destroy_EC2 to remove EC2
               Destroy_K8 to remove EKS ]''', name: 'CHOICE'
}
 
 
 environment {
  TF_VAR_access_key     = credentials('AWS_ACCESS_KEY_ID') 
  TF_VAR_secret_key     = credentials('AWS_SECRET_ACCESS_KEY')  
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
        stage('Terraform EC2  Init') {
           when {
             expression { params.CHOICE == "Build_Deploy_EC2" }  
           }
            steps {
               echo "params.CHOICE: ${params.CHOICE}"
                sh '''
                cd terraform
                echo "Running terraform init"
                terraform init -no-color
                echo "Running terraform fmt -recursive"
                terraform fmt -recursive
                echo "Running terraform validate"
                terraform validate -no-color
               sh '''
            }
        }

        stage('Terraform K8 Init') {
           when {
             expression { params.CHOICE == "Build_Deploy_K8" }  
           }
            steps {
                sh '''
                cd terraformk8
                echo "Running terraform init"
                terraform init -no-color
                echo "Running terraform fmt -recursive"
                terraform fmt -recursive
                echo "Running terraform validate"
                terraform validate -no-color
               sh '''
            }
        }

        stage('Terraform EC2 Plan & Apply') {
           when {
             expression { params.CHOICE == "Build_Deploy_EC2" }  
           }
            steps {
                sh '''
                echo "Executing terraform plan"                 
                cd terraform; terraform plan -out=tfplan -no-color
                sh '''
                sh '''
                echo "Executing terraform apply"                 
                cd terraform; terraform apply tfplan  -no-color
                sh '''
            }
        }

        stage('Terraform K8 Plan & Apply') {
           when {
             expression { params.CHOICE == "Build_Deploy_K8" }  
           }
            steps {
                sh '''
                echo "Executing terraform plan"                 
                cd terraformk8; terraform plan -out=tfplan -no-color
                sh '''
                sh '''
                echo "Executing terraform apply"                 
                cd terraformk8; terraform apply tfplan  -no-color
                sh '''
            }
        }

        stage('Terraform K8 Destroy') {
           when {
             expression { params.CHOICE == "Destroy_K8" }  
           }
            steps {
                sh  'cd terraformk8; terraform apply -destroy -auto-approve -no-color'
            }
        }

        stage('Terraform EC2 Destroy') {
           when {
             expression { params.CHOICE == "Destroy_EC2" }  
           }
            steps {
                sh  'cd terraform; terraform apply -destroy -auto-approve -no-color'
            }

        }

    }

}


