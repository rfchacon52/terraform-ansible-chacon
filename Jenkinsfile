pipeline {

agent any

parameters {
  choice choices: [ "Deploy_automode" , "Destroy_automode"], description: '''Select:  
               1. Deploy_automode
               2. Destroy_automode  ''', name: 'CHOICE'
}
 
 environment {
   AWS_DEFAULT_REGION    = 'us-east-1'
   THE_BUTLER_SAYS_SO  = credentials('aws-creds')
   
   MAVEN_HOME            = '/usr/share/maven' 
    // KUBE_CONFIG_PATH      = '~/.kube/config'
    //  JAVA_HOME             = '/usr/lib/jvm/jre-17-openjdk'
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

  stage('Deploy EKS Auto-mode') {
           when {
             expression { params.CHOICE == "Deploy_automode" }  
           }
            steps {
                sh '''
                cd realtime-project/terraform  
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

stage('Destroy EKS AUto-mode') {
           when {
             expression { params.CHOICE == "Destroy_automode" }  
           }
            steps {
                sh '''
                cd realtime-project/terraform
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
             expression { params.CHOICE == "Deploy_JMETER1" }
           }
            steps {
              script {
                withCredentials([string(credentialsId: 'dockerhub-credentials', variable: 'DOCKER_TOKEN')]) {
                sh '''
                cd jmeter
                echo "Creating swap 4gb swap file"
                ansible-playbook create-swap-file.yml 
                echo "$DOCKER_TOKEN" | docker login -u "rfchacon717" --password-stdin
                ansible-playbook deploy_podman_compose.yml 
                sh '''
               }
             }
            }
        }
}
}
