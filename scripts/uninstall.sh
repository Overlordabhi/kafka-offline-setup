#!/bin/bash
set -e

# ======================================
# COLORS
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
echo -e "${YELLOW}It will safely remove Java ONLY if installed by this installer.${NC}"
echo ""

read -p "Are you sure you want to continue? (yes/no): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
  echo -e "${BLUE}Uninstall cancelled.${NC}"
  exit 0
fi

echo ""

# ======================================
# 1. STOP KAFKA SERVICE
# ======================================
echo -e "${BLUE}[1/7] Stopping Kafka service${NC}"

if systemctl list-units --full -all | grep -q kafka.service; then
  systemctl stop kafka || true
  systemctl disable kafka || true
  echo -e "${GREEN}Kafka service stopped.${NC}"
else
  echo -e "${GREEN}Kafka service not found.${NC}"
fi

# ======================================
# 2. REMOVE SYSTEMD SERVICE FILE
# ======================================
echo -e "${BLUE}[2/7] Removing systemd service${NC}"

if [[ -f /etc/systemd/system/kafka.service ]]; then
  rm -f /etc/systemd/system/kafka.service
  systemctl daemon-reexec
  systemctl daemon-reload
  echo -e "${GREEN}systemd service removed.${NC}"
else
  echo -e "${GREEN}No systemd service file found.${NC}"
fi

# ======================================
# 3. REMOVE KAFKA DIRECTORY
# ======================================
echo -e "${BLUE}[3/7] Removing Kafka directory (/opt/kafka)${NC}"

if [[ -d /opt/kafka ]]; then
  rm -rf /opt/kafka
  echo -e "${GREEN}/opt/kafka removed.${NC}"
else
  echo -e "${GREEN}/opt/kafka not found.${NC}"
fi

# ======================================
# 4. REMOVE ENVIRONMENT VARIABLES
# ======================================
echo -e "${BLUE}[4/7] Removing Kafka environment variables${NC}"

if [[ -f /etc/profile.d/kafka.sh ]]; then
  rm -f /etc/profile.d/kafka.sh
  echo -e "${GREEN}/etc/profile.d/kafka.sh removed.${NC}"
else
  echo -e "${GREEN}Environment file not found.${NC}"
fi

# ======================================
# 5. REMOVE SYSTEM-WIDE JAVA SYMLINK (SAFE)
# ======================================
echo -e "${BLUE}[5/7] Checking system-wide java symlink${NC}"

if [[ -L /usr/bin/java ]]; then
  TARGET=$(readlink -f /usr/bin/java)
  if [[ "$TARGET" == /opt/java/*/bin/java ]]; then
    rm -f /usr/bin/java
    echo -e "${GREEN}/usr/bin/java symlink removed.${NC}"
  else
    echo -e "${YELLOW}/usr/bin/java points to system Java. Leaving untouched.${NC}"
  fi
else
  echo -e "${GREEN}No java symlink created by installer found.${NC}"
fi

# ======================================
# 6. REMOVE JAVA INSTALLED BY INSTALLER
# ======================================
echo -e "${BLUE}[6/7] Removing Java installed by installer${NC}"

if [[ -d /opt/java ]]; then
  rm -rf /opt/java
  echo -e "${GREEN}/opt/java removed.${NC}"
else
  echo -e "${GREEN}/opt/java not found.${NC}"
fi

# ======================================
# 7. CLEAN TEMP FILES
# ======================================
echo -e "${BLUE}[7/7] Cleaning temporary Kafka files${NC}"

rm -rf /tmp/kafka-* || true
echo -e "${GREEN}Temporary files cleaned.${NC}"

# ======================================
# DONE
# ======================================
echo ""
echo -e "${GREEN}====================================================${NC}"
echo -e "${GREEN}Kafka has been completely uninstalled.${NC}"
echo -e "${GREEN}System restored to safe state.${NC}"
echo -e "${GREEN}====================================================${NC}"
echo ""
