#!/usr/bin/env bash
# Generates Ansible inventory from Terraform outputs
set -euo pipefail
cd "$(dirname "$0")"

WEB_IP=$(terraform -chdir=../terraform output -raw web_public_ip)
DB_IP=$(terraform -chdir=../terraform output -raw db_private_ip)
KEY=~/.ssh/mern-tf

cat > inventory.ini <<EOF
[webservers]
web ansible_host=${WEB_IP}

[dbservers]
db ansible_host=${DB_IP} ansible_ssh_common_args='-o ProxyCommand="ssh -i ${KEY} -o StrictHostKeyChecking=accept-new -W %h:%p -q ubuntu@${WEB_IP}"'

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=${KEY}
db_private_ip=${DB_IP}
EOF

echo "inventory.ini generated: web=${WEB_IP} db=${DB_IP}"
