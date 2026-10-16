#!/usr/bin/env bash
# Destroy the full environment and verify nothing billable is left behind
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
R=ap-southeast-2
P=mern-tf

terraform -chdir="$ROOT/terraform" destroy

echo "==> Checking for billable leftovers in $R"
NAT=$(aws ec2 describe-nat-gateways --profile $P --region $R \
  --filter Name=tag:Project,Values=mern-tf Name=state,Values=pending,available \
  --query 'NatGateways[].NatGatewayId' --output text)
EIP=$(aws ec2 describe-addresses --profile $P --region $R \
  --filters Name=tag:Project,Values=mern-tf \
  --query 'Addresses[].PublicIp' --output text)
EC2=$(aws ec2 describe-instances --profile $P --region $R \
  --filters Name=tag:Project,Values=mern-tf Name=instance-state-name,Values=pending,running,stopping,stopped \
  --query 'Reservations[].Instances[].InstanceId' --output text)

if [ -z "$NAT$EIP$EC2" ]; then
  echo "    Clean: no NAT Gateways, Elastic IPs or instances left."
else
  echo "    WARNING - still present:"
  [ -n "$NAT" ] && echo "    NAT Gateway(s): $NAT"
  [ -n "$EIP" ] && echo "    Elastic IP(s):  $EIP"
  [ -n "$EC2" ] && echo "    Instance(s):    $EC2"
  exit 1
fi
