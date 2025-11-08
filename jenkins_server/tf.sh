#!/bin/bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

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

