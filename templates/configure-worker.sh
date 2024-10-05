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

if [ "${LOGGING_ENABLED}" = "true"]; then
events {
  audit_enabled = true
  observation_enabled = true
  sysevents_enabled = true
  telemetry_enabled = true

  sink "stderr" {
    name = "all-events"
    description = "Sink for all events to stderr"
    event_types = ["*"]
    format = "cloudevents-json"
  }

  sink {
    name = "worker-event-sink"
    description = "Sink for worker logs to file"
    event_types = ["*"]
    format = "cloudevents-json"

    file {
      path = "/logs"
      file_name = "worker-logs.log"
    }
  }
}
fi

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

# Check if the service started successfully
if systemctl is-active --quiet boundary; then
    echo "Boundary service started successfully (status code: 0)"
else
    status_code=$?
    echo "Failed to start Boundary service (status code: $status_code)"
    exit $status_code
fi

if [ "${LOGGING_ENABLED}" = "true" ]; then
  # Configure CloudWatch Logs
  echo "Configuring CloudWatch Logs"
  mkdir -p /etc/awslogs
  cat > /etc/awslogs/awslogs.conf <<- EOF
[general]
state_file = /var/lib/awslogs/agent-state

[/var/log/syslog]
file = /var/log/syslog
log_group_name = ${CLOUDWATCH_LOG_GROUP}
log_stream_name = {instance_id}/syslog
datetime_format = %b %d %H:%M:%S

[/var/log/boundary/boundary.log]
file = /var/log/boundary/boundary.log
log_group_name = ${CLOUDWATCH_LOG_GROUP}
log_stream_name = {instance_id}/boundary
datetime_format = %Y-%m-%d %H:%M:%S
EOF

  # Start CloudWatch Logs agent
  echo "Starting CloudWatch Logs agent"
  /usr/bin/aws configure set region $(curl -s http://169.254.169.254/latest/meta-data/placement/region)
  /usr/bin/aws logs push --config-file /etc/awslogs/awslogs.conf
fi
