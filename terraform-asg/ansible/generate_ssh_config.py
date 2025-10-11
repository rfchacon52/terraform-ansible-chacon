#!/usr/bin/env python3


import boto3
import os
from botocore.exceptions import ClientError

# More configs
bastion1='3.89.4.207'
ansible_user='ec2-user'
ansible_ssh_common_args='-o ProxyJump=ec2-user@bastion1'
ansible_ssh_private_key_file='~/.ssh/my-private-key.pem' 


# --- Configuration ---
# Target Tag for filtering EC2 instances
TARGET_TAG_KEY = 'ec2_type'
TARGET_TAG_VALUE = 'nginx'

# Bastion Host configuration for ProxyJump
BASTION_HOST = 'bastion1'

# Local path for the SSH configuration file
IDENTITY_FILE_PATH = '~/.ssh/id_rsa' # Your private key file
INVENTORY = '/tmp/inventory'

def get_private_nginx_instances(region_to_query):
    """
    Finds all running EC2 instances with the specific tag and extracts their private IP.
    """
    ec2 = boto3.client('ec2', region_name=region_to_query)
    
    try:
        response = ec2.describe_instances(
            Filters=[
                {
                    'Name': 'instance-state-name',
                    'Values': ['running']
                },
                {
                    'Name': f'tag:{TARGET_TAG_KEY}',
                    'Values': [TARGET_TAG_VALUE]
                }
            ]
        )
    except ClientError as e:
        print(f"Error accessing AWS EC2: {e}")
        return []

    instance_ips = []
    
    # Iterate through reservations and instances
    for reservation in response.get('Reservations', []):
        for instance in reservation.get('Instances', []):
            private_ip = instance.get('PrivateIpAddress')
            
            # The list should only include IPs that actually exist
            if private_ip:
                instance_ips.append(private_ip)

    return instance_ips

def generate_ssh_config(ip_list):
    """
    Generates the SSH config file content based on the list of IPs.
    """
       
    try:
        with open(INVENTORY, 'w') as f:
            f.write(f"[nginxservers] \n") 

            for index, ip in enumerate(ip_list):
                host_alias = f"nginxprivate{index + 1}"
                # Write the item and append a newline character
                f.write(f"{host_alias} ansible_host={ip} \n")


    except IOError as e:
        print(f"An error occurred: {e}")

    f.write(f"[bastions] \n")
    f.write(f"bastion1 ansible_host={beation1} \n")
    f.write(f"[nginxservers:vars] \n")    
    f.write(f"ansible_ssh_common_args={ansible_ssh_common_args} \n")    
    f.write(f"ansible_user={ansible_user} \n")    
    f.write(f"ansible_ssh_private_key_file={ansible_ssh_private_key_file} \n")    
    print(f"\n✅ Successfully updated SSH config: {SSH_CONFIG_PATH}")
    print(f"   Added {len(ip_list)} instance entries.")


     

if __name__ == "__main__":


    region_to_query = 'us-east-1'
    ip_addresses = get_private_nginx_instances(region_to_query)
    
    if ip_addresses:
        generate_ssh_config(ip_addresses)
    else:
        print("\n⚠️ No running EC2 instances found with the specified tags.")
