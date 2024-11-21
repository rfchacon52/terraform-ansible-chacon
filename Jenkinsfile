pipeline {

agent any
    
    environment {
 VAULT_ADDR='http://127.0.0.1:8200'
 VAULT_NAMESPACE='admin'
 VAULT_TOKEN='hvs.CAESIBpdxHh6CQ_iZIzQrcfEmq3bbFMB0FmfprnzZ8dx237yGigKImh2cy51RXE5ZXN1WE1iV0Y1RWxwRENaOEh6TFAuSHlsNG0QlO4F'
 AWS_ACCESS_KEY_ID='AKIA3FLD3ICKGOBBOCYL'
 AWS_SECRET_ACCESS_KEY='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'
 TF_TOKEN_app_terraform_io='jv6AC5kovjoPzQ.atlasv1.6SFJPu8SMbXeqbt2VhKq4v2qffH9db7KGiEiSTud2bqKQG1UzvyQF1sd6UCy9rbY9gQ'
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
              #  source /var/local/env_settings
                cd terraform
                vault secrets enable -path=aws aws
               # hcp auth login 
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

