#!/usr/bin/env bash

# Generate a unique 4-character alphanumeric identifier
echo "Generating UUID"
UUID=$(head /dev/urandom | tr -dc a-z0-9 | head -c 4)

# Install necessary packages
echo "Installing Packages"
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
apt update -y && apt install -y boundary jq

# Get token for fetching metadata and retrieve local ipv4 and public ipv4 metadata
echo "Retrieving local and Public IP"
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
LOCAL_IPV4=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s "http://169.254.169.254/latest/meta-data/local-ipv4")
PUBLIC_IPV4=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s "http://169.254.169.254/latest/meta-data/public-ipv4")

echo "Creating Boundary Configuration Directory"
mkdir -p /etc/boundary.d

echo "Creating Boundary Configuration"
cat > /etc/boundary.d/boundary.hcl <<- EOF
disable_mlock = true

 listener "tcp" {
  purpose = "proxy"
  tls_disable = true
  address = "$${LOCAL_IPV4}:9202"
}

worker {
  name = "boundary-worker-$${UUID}"
  public_addr = "$${PUBLIC_IPV4}"

  controllers = [
   "${BOUNDARY_LB_DNS_NAME}"
  ]
}

kms "awskms" {
  purpose = "worker-auth"
  kms_key_id = "${KMS_WORKER_AUTH_KEY_ID}"
}
EOF


# Adding a system user and group
echo "Adding system and user group"
useradd --system --user-group boundary || true

# Changing ownership of directories and files
echo "Change ownership of Boundary Configuration directory and binary"
chown boundary:boundary -R /etc/boundary.d
chown boundary:boundary /usr/bin/boundary

# Reload systemd manager configuration
echo "Reloading service"
systemctl daemon-reload

# Enable and start the Boundary service
echo "Starting Boundary Service"
systemctl enable boundary
systemctl start boundary
