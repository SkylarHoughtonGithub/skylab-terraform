#!/bin/bash
# user_data.sh

# Update system
yum update -y

# Install ECS agent
echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config
echo ECS_ENABLE_TASK_IAM_ROLE=true >> /etc/ecs/ecs.config
echo ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true >> /etc/ecs/ecs.config

# Install Docker (should be pre-installed on ECS-optimized AMI)
systemctl enable docker
systemctl start docker

# Install Tailscale
curl -fsSL https://tailscale.com/install.sh | sh
echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.conf
echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.conf
sysctl -p /etc/sysctl.conf

# Connect to Tailscale
tailscale up --authkey=${tailscale_api_token} --accept-routes

# Create directory for QDevice data
mkdir -p /opt/qdevice-data
chown 1000:1000 /opt/qdevice-data

# Start ECS agent
systemctl enable ecs
systemctl start ecs