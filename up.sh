#!/usr/bin/env bash
# Rebuild the full environment: infrastructure (Terraform) + configuration (Ansible)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
TF="terraform -chdir=$ROOT/terraform"

echo "==> Checking AWS credentials (profile mern-tf)"
aws sts get-caller-identity --profile mern-tf --query Arn --output text

echo "==> Refreshing admin IP for SSH allow-list"
MYIP=$(curl -s https://checkip.amazonaws.com)
echo "my_ip = \"${MYIP}/32\"" > "$ROOT/terraform/terraform.tfvars"
echo "    admin IP: ${MYIP}"

echo "==> Terraform apply"
$TF init -input=false >/dev/null
$TF apply -auto-approve

WEB_IP=$($TF output -raw web_public_ip)
DB_IP=$($TF output -raw db_private_ip)

echo "==> Clearing stale SSH host keys (IPs can be reused)"
ssh-keygen -R "$WEB_IP" >/dev/null 2>&1 || true
ssh-keygen -R "$DB_IP"  >/dev/null 2>&1 || true

cd "$ROOT/ansible"
./gen_inventory.sh

echo "==> Waiting for both servers to accept SSH"
ansible all -m ansible.builtin.wait_for_connection -a "timeout=300"

echo "==> Configuring servers (site.yml)"
ansible-playbook site.yml

echo
echo "Environment is UP:  http://${WEB_IP}"
echo "Remember: run ./down.sh when finished - the NAT Gateway bills hourly."
