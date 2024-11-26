pipeline {

agent any

    parameters {
        choice(
            name: 'CHOICE',
            choices: ['Build_Deploy', 'Destroy', 'Build_Docker'],
            description: 'Select [ Build_Deploy  or Destroy or Build_Docker ]'
        )
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

        stage('Build Docker') {
           when {
             expression { params.CHOICE == "Build_Docker" }  
           }
            steps {
                sh '''
                cd docker
                docker build . -t voting-app 
                sh '''
            }
        stage('Terraform Init') {
           when {
             expression { params.CHOICE == "Build_Deploy" }  
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
            }
        }
        stage('Terraform Plan & Apply') {
           when {
             expression { params.CHOICE == "Build_Deploy" }  
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
        stage('Terraform Destroy') {
           when {
             expression { params.CHOICE == "Destroy" }  
           }
            steps {
                sh  'cd terraform; terraform apply -destroy -auto-approve -no-color'
            }

        }

    }

}


