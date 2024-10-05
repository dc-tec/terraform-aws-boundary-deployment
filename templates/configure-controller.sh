#!/usr/bin/env bash

# Generate a unique 4-character alphanumeric identifier
echo "Generating UUID"
UUID=$(head /dev/urandom | tr -dc a-z0-9 | head -c 4)

# Install necessary packages
echo "Installing Packages"
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
apt update -y && apt install -y boundary jq awscli

# Get token for fetching metadata and local ipv4
echo "Retrieving local IP"
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
LOCAL_IPV4=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s "http://169.254.169.254/latest/meta-data/local-ipv4")

# URL-encode the password
echo "Encoding DB Password"
ENCODED_DB_PASSWORD=$(echo -n "${DB_PASSWORD}" | jq -sRr @uri)

# Create the Boundary configuration directory and TLS subdirectory
echo "Creating TLS directory"
mkdir -p /etc/boundary.d/tls

# Write the server key and certificate to the appropriate files
echo "Writing Certificate data"
cat > /etc/boundary.d/tls/key.pem <<- EOF
${SERVER_KEY}
EOF

cat > /etc/boundary.d/tls/cert.pem <<- EOF
${SERVER_CERT}
EOF

echo "Creating Boundary Environment File"
cat > /etc/boundary.d/boundary.env <<- EOF
BOUNDARY_DB_CONNECTION=postgresql://${DB_USERNAME}:$${ENCODED_DB_PASSWORD}@${DB_ENDPOINT}/${DB_NAME}
EOF

echo "Creating Boundary Configuration"
cat > /etc/boundary.d/boundary.hcl <<- EOF
# Disable memory lock: https://www.man7.org/linux/man-pages/man2/mlock.2.html
disable_mlock = true

# Controller configuration block
controller {
  # This name attr must be unique across all controller instances if running in HA mode
  name = "boundary-controller-$${UUID}"
  description = "Boundary Controller $${UUID}"

  database {
    url = "env://BOUNDARY_DB_CONNECTION"
    max_open_connections = 20
  }
}

# API listener configuration block
listener "tcp" {
  # Should be the address of the NIC that the controller server will be reached on
  address = "$${LOCAL_IPV4}:9200"
  # The purpose of this listener block
  purpose = "api"

  tls_disable = false
  tls_cert_file = "/etc/boundary.d/tls/cert.pem"
  tls_key_file = "/etc/boundary.d/tls/key.pem"
}

# Data-plane listener configuration block (used for worker coordination)
listener "tcp" {
  # Should be the IP of the NIC that the worker will connect on
  address = "$${LOCAL_IPV4}:9201"
  # The purpose of this listener
  purpose = "cluster"
}

# For health checks for load balancer
listener "tcp" {
  # Should be the IP of the NIC that the worker will connect on
  address = "$${LOCAL_IPV4}:9203"
  # The purpose of this listener
  purpose = "ops"

  tls_disable = false
  tls_cert_file = "/etc/boundary.d/tls/cert.pem"
  tls_key_file = "/etc/boundary.d/tls/key.pem"
}

# Event sinks configuration
if [ "${LOGGING_ENABLED}" = "true" ]; then
events {
  audit_enabled = true
  observation_enabled = true
  sysevents_enabled = true
  telemetry_enabled = true

  sink "stderr" {
    name = "all-events"
    description = "All events will be logged to stderr sink"
    event_types = ["*"]
    format = "cloudevents-json"
  }

  sink {
    name = "controller-audit-sink"
    description = "Send Controller Audit Logs to File"
    event_types = ["audit"]
    format = "cloudevents-json"

    file {
      path = "/logs"
      file_name = "controller-audit.log"
    }

    audit_config {
      audit_filter_overrides = {
        secret = "encrypt"
        sensitive = "hmac-sha256"
      }
    }
  }

  sink {
    name = "controller-auth-sink"
    description = "Send Controller Auth Logs to File"
    event_types = ["observeration"]
    format = "cloudevents-json"

    allow_filter = [
      "\"/data/request_info/path\" contains \":authenticate\""
    ]

    file {
      path = "/logs"
      file_name = "controller-auth.log"
    }
  }

  sink {
    name = "controller-session-sink"
    description = "Send Controller Session Logs to File"
    event_types = ["audit"]
    format = "cloudevents-json"

    allow_filter = [
      "\"/data/request_info/path\" contains \":authorize-session\"",
      "\"/data/request_info/method\" contains \"SessionService\""
    ]

    file {
      path = "/logs"
      file_name = "controller-session.log"
    }
  }
}
fi

# Root KMS configuration block: this is the root key for Boundary
# Use a production KMS such as AWS KMS in production installs
kms "awskms" {
  purpose = "root"
  kms_key_id = "${KMS_ROOT_KEY_ID}"
}

# Worker authorization KMS
# Use a production KMS such as AWS KMS for production installs
# This key is the same key used in the worker configuration
kms "awskms" {
  purpose = "worker-auth"
  kms_key_id = "${KMS_WORKER_AUTH_KEY_ID}"
}

# Recovery KMS block: configures the recovery key for Boundary
# Use a production KMS such as AWS KMS for production installs
kms "awskms" {
  purpose = "recovery"
  kms_key_id = "${KMS_RECOVERY_KEY_ID}"
}
EOF

# Adding a system user and group
echo "Adding system and user group"
useradd --system --user-group boundary || true

# Changing ownership of directories and files
echo "Change ownership of Boundary Configuration directory and binary"
chown boundary:boundary -R /etc/boundary.d
chown boundary:boundary /usr/bin/boundary

echo "Exporting DB Connection URI"
export BOUNDARY_DB_CONNECTION="postgresql://${DB_USERNAME}:$${ENCODED_DB_PASSWORD}@${DB_ENDPOINT}/${DB_NAME}"

# Run the command and capture the exit code
echo "Initializing database"
boundary database init -config /etc/boundary.d/boundary.hcl
boundary_db_init=$?

# Check if the exit code is 0 or 2
if [ $boundary_db_init -eq 0 ] || [ $boundary_db_init -eq 2 ]; then
  echo "Command succeeded with exit code $boundary_db_init"
else
  echo "Command failed with exit code $boundary_db_init"
  exit $boundary_db_init
fi

# Reload systemd manager configuration
echo "Reloading service"
systemctl daemon-reload

# Enable and start the Boundary service
echo "Starting Boundary Service"
systemctl enable boundary
systemctl start boundary

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
datetime_format = '%d %b %Y %H:%M:%S'

[/logs/controller-audit.log]
file = /logs/controller-audit.log
log_group_name = ${CLOUDWATCH_LOG_GROUP}
log_stream_name = {instance_id}/controller-audit
datetime_format = '%d %b %Y %H:%M:%S'

[/logs/controller-auth.log]
file = /logs/controller-auth.log
log_group_name = ${CLOUDWATCH_LOG_GROUP}
log_stream_name = {instance_id}/controller-auth
datetime_format = '%d %b %Y %H:%M:%S'

[/logs/controller-session.log]
file = /logs/controller-session.log
log_group_name = ${CLOUDWATCH_LOG_GROUP}
log_stream_name = {instance_id}/controller-session
datetime_format = '%d %b %Y %H:%M:%S'
EOF

  # Start CloudWatch Logs agent
  echo "Starting CloudWatch Logs agent"
  /usr/bin/aws configure set region $(curl -s http://169.254.169.254/latest/meta-data/placement/region)
  /usr/bin/aws logs push --config-file /etc/awslogs/awslogs.conf
fi
