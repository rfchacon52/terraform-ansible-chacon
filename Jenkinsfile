pipeline {

    agent any
    
    environment {
        AWS_ACCESS_KEY_ID='AKIA3FLD3ICKGOBBOCYL' 
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS-KEY') 
        TF_TOKEN_app_terraform_io = credentials('TF_TOKEN')
        AWS_DEFAULT_REGION='us-west-1'
        HCP_CLIENT_ID='p8eCxXiBVC41ZPxGd6WGtkjJ7bB1y6hw'
        HCP_CLIENT_SECRET = credentials('HCP_CLIENT_SECRET')
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
                cd terraform
                hcp profile set vault-secrets/app WebApplication 
                hcp auth login 
                echo "Running terraform init"
                terraform init -input=false -no-color
                echo "Running terraform fmt -recursive"
                terraform fmt -recursive
                echo "Running terraform validate"
                terraform validate -no-color
                echo "Run terraform init again"
                terraform init -input=false -no-color
                sh '''
            }
        }
        stage('Terraform Plan') {

            steps {

                sh 'cd terraform; terraform plan -out=tfplan -input=false -no-color'

            }

        }

        stage('Terraform Apply') {

            steps {

                sh 'cd terraform; terraform apply -input=false tfplan  -no-color'

            }

        }

    }

}

