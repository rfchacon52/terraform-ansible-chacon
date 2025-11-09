pipeline {

agent any

parameters {
  choice choices: [ "Deploy_automode" , "Destroy_automode"], description: '''Select:  
               1. Deploy_automode
               2. Destroy_automode  ''', name: 'CHOICE'
}
 
 environment {
   ANSIBLE_PRIVATE_KEY   = credentials('Jenkins-pem')
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
               withAWS(credentials: 'aws_creds', region: 'us-east-1') {
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


  stage('Destroy Jmeter') {
           when {
             expression { params.CHOICE == "Destroy_JMETER1" }  
           }
            steps {
                sh '''
                cd jmeter 
                echo "Running terraform init"
                terraform init -no-color
                echo "Running terraform validate"
                terraform  validate -no-color
                echo "Executing Terraform Destroy"
                terraform apply -destroy -auto-approve -no-color
                sh '''
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

        stage('Run Maven Clean, Verify and Sonar Checks') {
           when {
             expression { params.CHOICE == "Deploy_K8" }  
           }
             steps {
                sh '''
                cd realtime-project
                export JAVA_HOME="/usr/lib/jvm/jre-17-openjdk"
                export PATH="$JAVA_HOME/bin:$PATH"
                echo "Run Maven Clean, Verify and Sonar Check"
                mvn clean verify sonar:sonar \
                -Dsonar.host.url=http://18.119.144.3:9000 \
                -Dsonar.token=squ_f46748d5844bd4bd337c33225b99cf703179ce66
                sh '''
                  }
             }


        stage('Run Maven Deploy to Nexus ') {
           when {
             expression { params.CHOICE == "Deploy_K8" }  
           }
             steps {
                sh '''
                cd realtime-project
                export JAVA_HOME="/usr/lib/jvm/jre-17-openjdk"
                export PATH="$JAVA_HOME/bin:$PATH"
                echo "Run Maven Deploy"
                mvn deploy 
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

       stage('Ansible deploy nginx') {
               when {
                  expression { params.CHOICE == "Deploy_ASG" }
                 }
            steps {
                sh '''
                cd terraform-asg/ansible
                sleep 5
                ansible-playbook deploy_nginx.yml  
                sh '''
            }
        }

        stage('TerraForm build/deploy K8 Infra') {
           when {
             expression { params.CHOICE == "Deploy_K8_no" }  
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
