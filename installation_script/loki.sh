#!/bin/bash
BLACK='\033[0;30m' RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[0;33m' BLUE='\033[0;34m' MAGENTA='\033[0;35m' CYAN='\033[0;36m' WHITE='\033[0;37m'
BOLD='\033[1m' UNDERLINE='\033[4m' BLINK='\033[5m' INVERT='\033[7m' 
RESET='\033[0m'  # Reset to default color

clear
echo "${CYAN}${BOLD}${BLINK}Loki (Log Management) Installation Script for Ubuntu...${RESET}"
sleep 5

# Create a user for Loki
echo "${YELLOW}Create a user for Loki...${RESET}"
sudo useradd --no-create-home --shell /bin/false loki

# Create necessary directories.
echo "${YELLOW}Create necessary directories...${RESET}"
sudo mkdir /etc/loki
sudo mkdir /var/lib/loki
sleep 2

# Download Loki and set permissions
echo "${YELLOW}Download Loki and set permissions...${RESET}"
LOKI_VERSION="2.9.4"  # Change this to the latest version
cd /tmp
wget https://github.com/grafana/loki/releases/download/v${LOKI_VERSION}/loki-linux-amd64.zip
unzip loki-linux-amd64.zip
chmod a+x "loki-linux-amd64"
sudo mv loki-linux-amd64 /usr/local/bin/loki
sudo chown loki:loki /usr/local/bin/loki 
rm -rf loki-linux-amd64.zip
sleep 2

# Create Loki configuration file
echo "${YELLOW}Create Loki configuration file...${RESET}"
sudo tee /etc/loki/local-config.yaml > /dev/null <<'EOF'
auth_enabled: false

server:
  http_listen_port: 3100
  grpc_listen_port: 9096

common:
  instance_addr: 127.0.0.1
  path_prefix: /tmp/loki
  storage:
    filesystem:
      chunks_directory: /tmp/loki/chunks
      rules_directory: /tmp/loki/rules
  replication_factor: 1
  ring:
    kvstore:
      store: inmemory

query_range:
  results_cache:
    cache:
      embedded_cache:
        enabled: true
        max_size_mb: 100

schema_config:
  configs:
    - from: 2020-10-24
      store: tsdb
      object_store: filesystem
      schema: v12
      index:
        prefix: index_
        period: 24h

ruler:
  alertmanager_url: http://localhost:9093

# By default, Loki will send anonymous, but uniquely-identifiable usage and configuration
# analytics to Grafana Labs. These statistics are sent to https://stats.grafana.org/
#
# Statistics help us better understand how Loki is used, and they show us performance
# levels for most users. This helps us prioritize features and documentation.
# For more information on what's sent, look at
# https://github.com/grafana/loki/blob/main/pkg/analytics/stats.go
# Refer to the buildReport method to see what goes into a report.
#
# If you would like to disable reporting, uncomment the following lines:
#analytics:
#  reporting_enabled: false

EOF
sleep 2

# Set permissions
echo "${YELLOW}Set permissions for Loki...${RESET}"
sudo chown loki:loki /etc/loki/local-config.yaml
sleep 2

# Create systemd service file for Loki
echo "${YELLOW}Create systemd service file for Loki...${RESET}"
sudo tee /etc/systemd/system/loki.service > /dev/null <<'EOF'
[Unit]
Description=Loki
Wants=network-online.target
After=network-online.target

[Service]
User=loki
Group=loki
Type=simple
ExecStart=/usr/local/bin/loki -config.file /etc/loki/local-config.yaml
#Restart=on-failure 
#RestartSec=20 
#StandardOutput=append:/var/log/monitoring/loki.log 
#StandardError=append:/var/log/monitoring/error_loki.log

[Install]
WantedBy=default.target
EOF
sleep 2

# Reload systemd and start Loki service
echo "${YELLOW}Reload systemd and start Loki service...${RESET}"
sudo systemctl daemon-reload
sudo systemctl start loki
sudo systemctl enable loki
sleep 2

# Display Loki service status
echo "${YELLOW}Display Loki service status...${RESET}"
sudo systemctl status loki | grep 'active (running)'
#journalctl -u loki.service --no-pager
sleep 3

# UFW allow for Loki
echo "${YELLOW}UFW 3100 allow for Loki...${RESET}"
sudo ufw allow '3100'
sudo ufw status | grep '3100'
sleep 2;
echo "${GREEN}${BOLD}UFW configuration completed successfully for Loki.${RESET}"

# Inform user about accessing Loki web interface
echo "${YELLOW}Inform user about accessing Loki web interface...${RESET}"
ip_address() {
    ip -4 addr show scope global | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n 1
}
echo "Loki is installed and running. Access the web interface at http://$(ip_address):3100"

# Test Loki installation
echo "${YELLOW}Testing Loki installation...${RESET}"
sudo apt-get install curl -y
curl http://$(ip_address):3100/ready | grep 'Ingester not ready: waiting for 15s after being ready'
sleep 5
echo "${CYAN}${BOLD}${BLINK}Loki (Log Management) configuration completed successfully.${RESET}"
