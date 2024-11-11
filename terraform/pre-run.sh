#!/bin/bash

export TF_LOG=DEBUG

ech " "
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

 
