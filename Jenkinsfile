pipeline {

agent any

parameters {
  choice choices: ['Deploy_ASG', 'Deploy_K8', 'Destroy_ASG', 'Destroy_K8', 'Destroy_SFTP', 'Deploy_SFTP', 'Deploy_ALB', 'Destroy_ALB'], description: '''Select:  
               1. Deploy_ASG
               2. Destroy_ASG  
               3. Deploy_K8  
               4. Destroy_K8 
               5. Deploy_ALB
               6. Destroy_ALB 
               7. Destroy_SFTP 
               8. Deploy_SFTP  ''', name: 'CHOICE'
}
 
 
 environment {
  TF_VAR_access_key     = credentials('AWS_ACCESS_KEY_ID') 
  TF_VAR_secret_key     = credentials('AWS_SECRET_ACCESS_KEY')  
  KUBE_CONFIG_PATH      = '~/.kube/config'
  JAVA_HOME             = '/usr/lib/jvm/java-17-openjdk-17.0.14.0.7-2.el9.x86_64/'
  MAVEN_HOME            = '/usr/share/maven' 
  ANSIBLE_INVENTORY     = '/etc/ansible/inventory'
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
             expression { params.CHOICE == "Deploy_ASG" }  
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

        stage('Run Maven build') {
           when {
             expression { params.CHOICE == "Deploy_no" }  
           }
             steps {
                sh '''
                echo "Running Maven build step"
                 cd project
                mvn clean package
                sh '''
                  }
             }



        stage('Build and Push Docker image') {
           when {
             expression { params.CHOICE == "Deploy_no" }  
           }
             steps {
                script {
                    withCredentials([string(credentialsId: 'dockerhub-credentials', variable: 'DOCKER_TOKEN')]) {
                        sh '''
                            cd project
                            echo "$DOCKER_TOKEN" | docker login -u "rfchacon717" --password-stdin
                            docker build -t rfchacon717/chacon-image:latest .
                            docker push rfchacon717/chacon-image:latest
                         echo "Build part"
                        '''
                      }
                    } 
               
                  }
             }

       stage('Deploy nginx using ansible') {
               when {
                  expression { params.CHOICE == "Deploy_ASG" }
                 }
            steps {
                sh '''
                cd terraform-asg/ansible
                 sleep 5
                ./rebuild_ssh_config
                ansible-playbook deploy_nginx.yml  
                sh '''
            }
        }

        stage('TerraForm build/deploy K8 Infra') {
           when {
             expression { params.CHOICE == "Deploy_K8" }  
           }
             steps {
                sh '''
                cd terraform
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
             expression { params.CHOICE == "Deploy_K8" }  
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
                cd terraform
               ./cleanup-cluster.sh  
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
