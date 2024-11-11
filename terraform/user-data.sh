#!/bin/bash


aws ec2-instance-connect send-ssh-public-key \
    --region us-east-2 \
    --availability-zone us-east-2a \
    --instance-id i-04b5f873b6970ccb1 \
    --instance-os-user ec2-user \
    --ssh-public-key file://my_key.pub

aws ec2-instance-connect send-ssh-public-key \
    --region us-east-2 \
    --availability-zone us-east-2c \
    --instance-id i-0544a021c5d7d5640  \
    --instance-os-user ec2-user \
    --ssh-public-key file://my_key.pub

aws ec2-instance-connect send-ssh-public-key \
    --region us-east-2 \
    --availability-zone us-east-2b \
    --instance-id i-0ee8c90aabe3cabb8  \
    --instance-os-user ec2-user \
    --ssh-public-key file://my_key.pub

