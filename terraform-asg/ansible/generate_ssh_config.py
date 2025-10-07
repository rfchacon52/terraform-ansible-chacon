#!/usr/bin/env python3


import boto3
import os
from botocore.exceptions import ClientError

# --- Configuration ---
# Target Tag for filtering EC2 instances
TARGET_TAG_KEY = 'ec2_type'
TARGET_TAG_VALUE = 'nginx'

# Bastion Host configuration for ProxyJump
BASTION_HOST = 'bastion1'

# Local path for the SSH configuration file
SSH_CONFIG_PATH = os.path.expanduser('/tmp/config_tmp')
IDENTITY_FILE_PATH = '~/.ssh/id_rsa' # Your private key file

def get_private_nginx_instances():
    """
    Finds all running EC2 instances with the specific tag and extracts their private IP.
    """
    region_to_query = 'us-east-1'
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
    
    config_entries = [
        # Start with a warning that the file is dynamically generated
        "# --- START DYNAMIC NGINX CONFIG ---",
        "# Created by AWS Python script. Do not edit manually.",
        f"# Bastion Host for ProxyJump: {BASTION_HOST}\n"
    ]
    
    # Check if there are existing contents to preserve
    # This block attempts to keep any custom config that isn't the dynamic block
    
    if os.path.exists(SSH_CONFIG_PATH):
        with open(SSH_CONFIG_PATH, 'r') as f:
            existing_content = f.read()
            
        # Find the start/end markers to avoid duplicating or mixing up content
        start_marker = existing_content.find("# --- START DYNAMIC NGINX CONFIG ---")
        
        # If the dynamic block already exists, use content BEFORE the start marker
        if start_marker != -1:
             config_entries.insert(0, existing_content[:start_marker])
        # Otherwise, keep the entire original file content
        else:
             config_entries.insert(0, existing_content)


    for index, ip in enumerate(ip_list):
        host_alias = f"nginx-private-{index + 1}"
        
        entry = [
            f"Host {host_alias}",
            f"  Hostname {ip}",
            "  User ec2-user",
            f"  IdentityFile {IDENTITY_FILE_PATH}",
            f"  ProxyJump {BASTION_HOST}\n"
        ]
        config_entries.extend(entry)

    config_entries.append("# --- END DYNAMIC NGINX CONFIG ---\n")

    # Write the new configuration
    with open(SSH_CONFIG_PATH, 'w') as f:
        # Filter out any blank lines that might result from concatenation
        f.write('\n'.join(line for line in config_entries if line.strip()))
        
    print(f"\n✅ Successfully updated SSH config: {SSH_CONFIG_PATH}")
    print(f"   Added {len(ip_list)} instance entries.")


     

if __name__ == "__main__":
    ip_addresses = get_private_nginx_instances()
    
    if ip_addresses:
        generate_ssh_config(ip_addresses)
    else:
        print("\n⚠️ No running EC2 instances found with the specified tags.")
