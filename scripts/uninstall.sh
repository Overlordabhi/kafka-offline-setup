#!/bin/bash
set -e

# ======================================
# COLORS (clean, professional)
# ======================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "===================================================="
echo "        SWAAMLAB X HSL"
echo "        Kafka Offline Uninstaller"
echo "===================================================="
echo -e "${NC}"

echo -e "${YELLOW}This will REMOVE Kafka installed by this project.${NC}"
echo -e "${YELLOW}It will NOT remove system-wide Java or other apps.${NC}"
echo ""

read -p "Are you sure you want to continue? (yes/no): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
  echo -e "${BLUE}Uninstall cancelled.${NC}"
  exit 0
fi

echo ""

# ======================================
# 1. Stop Kafka if running
# ======================================
echo -e "${BLUE}[1/6] Stopping Kafka if running${NC}"
if pgrep -f kafka.Kafka >/dev/null 2>&1; then
  /opt/kafka/bin/kafka-server-stop.sh || true
  sleep 2
  echo -e "${GREEN}Kafka stopped.${NC}"
else
  echo -e "${GREEN}Kafka not running.${NC}"
fi

# ======================================
# 2. Remove Kafka directory
# ======================================
echo -e "${BLUE}[2/6] Removing Kafka directory (/opt/kafka)${NC}"
if [[ -d /opt/kafka ]]; then
  rm -rf /opt/kafka
  echo -e "${GREEN}/opt/kafka removed.${NC}"
else
  echo -e "${GREEN}/opt/kafka not found.${NC}"
fi

# ======================================
# 3. Remove Java installed by installer
# ======================================
echo -e "${BLUE}[3/6] Removing Java installed by installer (/opt/java)${NC}"
if [[ -d /opt/java ]]; then
  rm -rf /opt/java
  echo -e "${GREEN}/opt/java removed.${NC}"
else
  echo -e "${GREEN}/opt/java not found.${NC}"
fi

# ======================================
# 4. Remove environment variables
# ======================================
echo -e "${BLUE}[4/6] Removing Kafka environment variables${NC}"
if [[ -f /etc/profile.d/kafka.sh ]]; then
  rm -f /etc/profile.d/kafka.sh
  echo -e "${GREEN}Environment file removed.${NC}"
else
  echo -e "${GREEN}Environment file not found.${NC}"
fi

# ======================================
# 5. Remove systemd service (if exists)
# ======================================
echo -e "${BLUE}[5/6] Removing systemd service (if exists)${NC}"
if [[ -f /etc/systemd/system/kafka.service ]]; then
  systemctl stop kafka || true
  systemctl disable kafka || true
  rm -f /etc/systemd/system/kafka.service
  systemctl daemon-reload
  echo -e "${GREEN}systemd service removed.${NC}"
else
  echo -e "${GREEN}No systemd service found.${NC}"
fi

# ======================================
# 6. Cleanup temporary Kafka files
# ======================================
echo -e "${BLUE}[6/6] Cleaning temporary Kafka files${NC}"
rm -rf /tmp/kafka-* || true
echo -e "${GREEN}Temporary files cleaned.${NC}"

# ======================================
# DONE
# ======================================
echo ""
echo -e "${GREEN}====================================================${NC}"
echo -e "${GREEN}Kafka has been completely uninstalled.${NC}"
echo -e "${GREEN}System is back to normal state.${NC}"
echo -e "${GREEN}====================================================${NC}"
echo ""
