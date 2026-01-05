#!/bin/bash
set -e

# ======================================
# COLORS (professional, no icons)
# ======================================
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# ======================================
# SIMPLE SPINNER
# ======================================
spinner() {
  local pid=$!
  local spin='-\|/'
  local i=0
  while kill -0 $pid 2>/dev/null; do
    i=$(( (i+1) %4 ))
    printf "\r${YELLOW}[%c] Processing...${NC}" "${spin:$i:1}"
    sleep 0.1
  done
  printf "\r${GREEN}[OK] Completed            ${NC}\n"
}

# ======================================
# ERROR HANDLER
# ======================================
fail() {
  echo -e "\n${RED}ERROR: $1${NC}"
  exit 1
}

# ======================================
# SAFE EXTRACT FUNCTION
# ======================================
extract() {
  local file=$1
  local dest=$2

  if [[ ! -f "$file" ]]; then
    fail "File not found: $file"
  fi

  if file "$file" | grep -q "gzip compressed"; then
    tar -xzf "$file" -C "$dest"
  else
    fail "Invalid or corrupted archive: $file"
  fi
}

# ======================================
# CLEAR SCREEN + TITLE
# ======================================
clear
echo -e "${BLUE}"
echo "===================================================="
echo "        SWAAMLAB X HSL"
echo "        Offline Kafka 4.x Installer"
echo "===================================================="
echo -e "${NC}"

sleep 1

# ======================================
# 1. INSTALL JAVA
# ======================================
echo -e "${BLUE}[1/6] Installing Java 17${NC}"
(
  mkdir -p /opt/java
  extract artifacts/OpenJDK17U-jdk_x64_linux_hotspot_17.0.10_7.tar.gz /opt
  mv /opt/jdk-17* /opt/java
) & spinner

# ======================================
# 2. INSTALL KAFKA
# ======================================
echo -e "${BLUE}[2/6] Installing Kafka 4.0.0${NC}"
(
  mkdir -p /opt/kafka
  extract artifacts/kafka_2.13-4.0.0.tgz /opt
  mv /opt/kafka_*/* /opt/kafka
) & spinner

# ======================================
# 3. CREATE DATA DIRECTORY
# ======================================
echo -e "${BLUE}[3/6] Creating Kafka data directory${NC}"
(
  mkdir -p /opt/kafka/data
) & spinner

# ======================================
# 4. APPLY CONFIGURATION
# ======================================
echo -e "${BLUE}[4/6] Applying Kafka configuration${NC}"
(
  mkdir -p /opt/kafka/config/kraft
  cp configs/server.properties /opt/kafka/config/kraft/server.properties
) & spinner

# ======================================
# 5. SET ENVIRONMENT VARIABLES
# ======================================
echo -e "${BLUE}[5/6] Setting environment variables${NC}"
(
  cp env/kafka.env /etc/profile.d/kafka.sh
  source /etc/profile.d/kafka.sh
) & spinner

# ======================================
# 6. FORMAT KRAFT METADATA
# ======================================
echo -e "${BLUE}[6/6] Formatting KRaft metadata${NC}"
(
  /opt/kafka/bin/kafka-storage.sh format \
    -t $(/opt/kafka/bin/kafka-storage.sh random-uuid) \
    -c /opt/kafka/config/kraft/server.properties
) & spinner

# ======================================
# FINAL MESSAGE
# ======================================
echo -e "\n${GREEN}====================================================${NC}"
echo -e "${GREEN}Kafka 4.x Offline Installation Completed Successfully${NC}"
echo -e "${GREEN}====================================================${NC}"

echo -e "${YELLOW}Kafka Location : /opt/kafka${NC}"
echo -e "${YELLOW}Java Location  : /opt/java${NC}"
echo -e "${YELLOW}Data Directory : /opt/kafka/data${NC}"

echo ""
echo -e "${BLUE}Start Kafka using:${NC}"
echo "/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/kraft/server.properties"
echo ""
