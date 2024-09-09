# Observability-For-DevOps

This repository provides a comprehensive observability stack tailored for DevOps engineers. It integrates key tools like Prometheus, Promtail, Loki, Grafana, cAdvisor, and Node Exporter to monitor, visualize, and manage your infrastructure and applications. Additionally, it includes a custom Notes App to demonstrate the observability stack in action..

## Overview
In modern DevOps, observability is key to ensuring the health and performance of your applications and infrastructure. This repository sets up an observability stack that includes metrics collection, container monitoring, and real-time visualization.

![image](https://github.com/user-attachments/assets/36ed40f2-3322-456a-9f91-ffcc13fc3c9b)

## Features
- Real-time monitoring of container metrics with Prometheus.
- Visualize metrics using Grafana dashboards.
- Monitor hardware, OS metrics, and custom application performance.
- Easily extendable for additional services and metrics.
- Persistent data storage for Prometheus and Grafana.

## Tech Services
- **Docker & Docker Compose**: Containerization and orchestration.
- **Prometheus**: Metrics collection and monitoring.
- **Loki**: Lightweight log management.
- **Promtail**: Promtail (Log Agent for Loki)
- **Grafana**: Data visualization and dashboard creation.
- **cAdvisor**: Container resource monitoring.
- **Node Exporter**: Hardware and OS metrics exporter.

## Installation on Ubuntu

1. **Clone the repository**:
    ```bash
    git clone https://github.com/manishktomar/Observability-For-DevOps.git
    cd Observability-For-DevOps
    ```

2. **Docker and Docker Compose Installation**:
    ```bash
    cd installation_script
    chmod +x docker.sh
    sh docker.sh
    ```
    ```bash
    apt  install docker-compose
    docker-compose --version
    ```

3. **Loki and Promtail Installation on Ubuntu Server**:
We also can use Docker Image for Installation of Loki and Promtail 

    ```bash
    cd installation_script
    chmod +x loki.sh
    sh loki.sh
    ```

    ```bash
    cd installation_script
    chmod +x promtail.sh
    sh promtail.sh
    ```

    Once Installation done copy configure file and restart the services.
    ```bash
    cp loki-config.yaml /etc/loki/local-config.yaml
    cp promtail-config.yaml  /etc/loki/config.yaml

    systemctl restart loki.service
    systemctl restart promtail.service
    ```

4. **Prometheus + Grafana + cAdvisor + Node Exporter Installation with Docker**:
    ```bash
    cd Observability-For-DevOps
    docker compose up -d
    ```

5. **Login Grafana and add Data Sources**:
   ![image](https://github.com/user-attachments/assets/a93caf59-a806-4968-b188-d591e6f70e9d)

  - Access **Grafana** at `http://localhost:3000`
    - Default credentials: `admin` / `admin` (you'll be prompted to change this)

## Usage
- Access **Loki** at `http://localhost:3100/metrics`
- Access **Promtail** at `http://localhost:9080/targets`
- Access **Grafana** at `http://localhost:3000`
  - Default credentials: `admin` / `admin` (you'll be prompted to change this)
- Access **Prometheus** at `http://localhost:9090`
- Access **cAdvisor** at `http://localhost:8080`
- Access **Node Exporter** metrics will be available at `http://localhost:9100/metrics`
