pipeline {

agent any
    
    environment {
        AWS_DEFAULT_REGION='us-west-1'
        APP_NAME='WebApplication'
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

        stage('Terraform Init') {
            steps {
                sh '''
                source /var/local/env_settings
                cd terraform
                hcp profile set vault-secrets/app WebApplication 
                hcp auth login 
                echo "Running terraform init"
                terraform init -no-color
                echo "Running terraform fmt -recursive"
                terraform fmt -recursive
                echo "Running terraform validate"
                terraform validate -no-color
                echo "Run terraform init again"
                terraform init -no-color
                sh '''
            }
        }
        stage('Terraform Plan') {

            steps {

                sh 'cd terraform; terraform plan -out=tfplan -no-color'

            }

        }

        stage('Terraform Apply') {

            steps {

                sh 'cd terraform; terraform apply tfplan -no-color'

            }

        }

    }

}

