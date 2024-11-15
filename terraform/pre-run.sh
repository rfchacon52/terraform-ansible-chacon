#!/bin/bash


export HCP_CLIENT_ID=p8eCxXiBVC41ZPxGd6WGtkjJ7bB1y6hw
export HCP_CLIENT_SECRET=5c3_AkyAFY57LM8jYMwP9dyp6DHQHk7GW3XmN0olokoNm-hVcuO_xbGNSR_aL5ky
export APP_NAME=WebApplication
#export TF_LOG=DEBUG


hcp profile set vault-secrets/app $APP_NAME
hcp auth login
#hcp vault-secrets secrets list --app=$APP_NAME 
echo " "

echo " "
 echo "Running terraform init"
 terraform init

 echo  "Running pre-run commands"

 echo "Running terraform validate"
 terraform validate
   if [ $? != 0 ] ; then
     echo "Failed terraform validate"
     exit 1
   fi 

 echo "Running terraform fmt -recursive"
 terraform fmt -recursive
   if [ $? != 0 ] ; then
     echo "Failed terraform fmt"
     exit 1
  else
     echo "terraform fmt ran ok"
   fi 

 
