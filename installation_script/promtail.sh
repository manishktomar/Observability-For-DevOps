#!/bin/bash
BLACK='\033[0;30m' RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[0;33m' BLUE='\033[0;34m' MAGENTA='\033[0;35m' CYAN='\033[0;36m' WHITE='\033[0;37m'
BOLD='\033[1m' UNDERLINE='\033[4m' BLINK='\033[5m' INVERT='\033[7m' 
RESET='\033[0m'  # Reset to default color

clear
echo "${CYAN}${BOLD}${BLINK}Promtail (Log Agent for Loki) Installation Script for Ubuntu...${RESET}"
sleep 5

# Create a user for Promtail
echo "${YELLOW}Create a user for Promtail...${RESET}"
sudo useradd --no-create-home --shell /bin/false promtail
sudo mkdir /etc/promtail

# Download Promtail and set permissions
echo "${YELLOW}Download Promtail and set permissions...${RESET}"
PROMTAIL_VERSION="2.9.4"  # Change this to the latest version
cd /tmp
wget https://github.com/grafana/loki/releases/download/v${PROMTAIL_VERSION}/promtail-linux-amd64.zip
unzip promtail-linux-amd64.zip
sudo mv promtail-linux-amd64 /usr/local/bin/promtail
sudo chown promtail:promtail /usr/local/bin/promtail
#rm -rf promtail-linux-amd64.zip
sleep 2

# Create Promtail configuration file
echo "${YELLOW}Create Promtail configuration file...${RESET}"
sudo tee /etc/promtail/config.yaml > /dev/null <<'EOF'
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://localhost:3100/loki/api/v1/push

scrape_configs:
- job_name: system
  static_configs:
  - targets:
      - localhost
    labels:
      job: varlogs
      __path__: /var/log/*log

EOF
sleep 2

# Set permissions
echo "${YELLOW}Set permissions...${RESET}"
sudo chown promtail:promtail /etc/promtail/config.yaml

# Create systemd service file for Promtail
echo "${YELLOW}Create systemd service file for Promtail...${RESET}"
sudo tee /etc/systemd/system/promtail.service > /dev/null <<'EOF'
[Unit]
Description=Promtail
Wants=network-online.target
After=network-online.target

[Service]
User=promtail
Group=promtail
Type=simple
ExecStart=/usr/local/bin/promtail -config.file /etc/promtail/config.yaml

[Install]
WantedBy=default.target
EOF
sleep 2

# UFW allow for Promtail
echo "${YELLOW}UFW 9080 allow for Loki...${RESET}"
sudo ufw allow '9080'
sudo ufw status | grep '9080'
sleep 2;
echo "${GREEN}${BOLD}UFW configuration completed successfully for Promtail.${RESET}"

# Reload systemd and start Promtail service
echo "${YELLOW}Reload systemd and start Promtail service...${RESET}"
sudo systemctl daemon-reload
sudo systemctl start promtail
sudo systemctl enable promtail
sleep 2

# Display Promtail service status
echo "${YELLOW}Display Promtail service status...${RESET}"
sudo systemctl status promtail | grep 'active (running)'
sleep 3

# Inform user about successful installation
ip_address() {
    ip -4 addr show scope global | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n 1
}
echo "Promtail is installed and running. It is now scraping logs and forwarding them to Loki."
echo "Loki is installed and running. Access the web interface at http://$(ip_address):9080"
sleep 2

# Test Loki installation
echo "${YELLOW}Testing Loki installation...${RESET}"
sudo apt-get install curl -y
curl http://$(ip_address):9080/targets  | grep 'Targets'
sleep 5
echo "${CYAN}${BOLD}${BLINK}Promtail (Log Agent for Loki) configuration completed successfully.${RESET}"
