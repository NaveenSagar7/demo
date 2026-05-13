#!/bin/bash

sudo apt update -y
sudo apt install -y unzip wget > /dev/null 2>&1

wget https://releases.hashicorp.com/vault/1.15.5/vault_1.15.5_linux_amd64.zip > /dev/null 2>&1

unzip -o vault_1.15.5_linux_amd64.zip > /dev/null 2>&1

sudo mv vault /usr/local/bin/

vault version

nohup vault server \
-dev \
-dev-root-token-id="root" \
-dev-listen-address="0.0.0.0:8200" \
> /dev/null 2>&1 &

sleep 5

export VAULT_ADDR='http://127.0.0.1:8200'

vault login root

# Enable AWS secrets engine
vault secrets enable aws

# Configure AWS root credentials
vault write aws/config/root \
    access_key="****" \
    secret_key="****" \
    region="us-east-1"

# Create AWS role
vault write aws/roles/terraform-role \
    credential_type=iam_user \
    policy_document=-<<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
    }
  ]
}
EOF

# Enable JWT auth
vault auth enable jwt

# Configure GitHub OIDC
vault write auth/jwt/config \
    oidc_discovery_url="https://token.actions.githubusercontent.com" \
    bound_issuer="https://token.actions.githubusercontent.com"

# Vault policy
vault policy write terraform-policy - <<EOF
path "aws/creds/terraform-role" {
  capabilities = ["read"]
}
EOF

# GitHub Actions role
vault write auth/jwt/role/gh-actions-role - <<EOF
{
  "role_type": "jwt",
  "bound_audiences": ["sts.amazonaws.com"],
  "user_claim": "sub",
  "bound_claims_type": "glob",
  "bound_claims": {
    "sub": "repo:NaveenSagar7/terraform-with-vault:*"
  },
  "token_policies": ["terraform-policy"],
  "token_ttl": "1h"
}
EOF