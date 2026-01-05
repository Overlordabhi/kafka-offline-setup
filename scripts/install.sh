#!/bin/bash
set -e

# ======================================
# COLORS
# ======================================
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# ======================================
# ERROR HANDLER
# ======================================
fail() {
  echo -e "\n${RED}ERROR: $1${NC}"
  exit 1
}

# ======================================
# SAFE EXTRACT
# ======================================
extract() {
  local file=$1
  local dest=$2

  if [[ ! -f "$file" ]]; then
    fail "File not found: $file"
  fi

  if ! file "$file" | grep -q "gzip compressed"; then
    fail "Invalid archive: $file"
  fi

  tar -xzf "$file" -C "$dest"
}

# ======================================
# TITLE
# ======================================
clear
echo -e "${BLUE}"
echo "===================================================="
echo "        SWAAMLAB X HSL"
echo "        Offline Kafka 4.x Installer"
echo "===================================================="
echo -e "${NC}"

# ======================================
# 1. INSTALL JAVA
# ======================================
echo -e "${BLUE}[1/6] Installing Java 17${NC}"
mkdir -p /opt/java
extract artifacts/OpenJDK17U-jdk_x64_linux_hotspot_17.0.10_7.tar.gz /opt
mv /opt/jdk-17* /opt/java

# 👉 IMPORTANT: export Java NOW
export JAVA_HOME=/opt/java
export PATH=$JAVA_HOME/bin:$PATH

# Verify Java immediately
java -version || fail "Java not working after installation"

echo -e "${GREEN}[OK] Java installed and verified${NC}"

# ======================================
# 2. INSTALL KAFKA
# ======================================
echo -e "${BLUE}[2/6] Installing Kafka 4.0.0${NC}"
mkdir -p /opt/kafka
extract artifacts/kafka_2.13-4.0.0.tgz /opt
mv /opt/kafka_*/* /opt/kafka
echo -e "${GREEN}[OK] Kafka extracted${NC}"

# ======================================
# 3. DATA DIRECTORY
# ======================================
echo -e "${BLUE}[3/6] Creating Kafka data directory${NC}"
mkdir -p /opt/kafka/data
echo -e "${GREEN}[OK] Data directory ready${NC}"

# ======================================
# 4. CONFIG
# ======================================
echo -e "${BLUE}[4/6] Applying Kafka configuration${NC}"
mkdir -p /opt/kafka/config/kraft
cp configs/server.properties /opt/kafka/config/kraft/server.properties
echo -e "${GREEN}[OK] Configuration applied${NC}"

# ======================================
# 5. ENV FOR FUTURE SESSIONS
# ======================================
echo -e "${BLUE}[5/6] Setting environment variables${NC}"
cat <<EOF >/etc/profile.d/kafka.sh
export JAVA_HOME=/opt/java
export KAFKA_HOME=/opt/kafka
export PATH=\$JAVA_HOME/bin:\$KAFKA_HOME/bin:\$PATH
EOF
chmod 644 /etc/profile.d/kafka.sh
echo -e "${GREEN}[OK] Environment variables saved${NC}"

# ======================================
# 6. FORMAT KRAFT (USES JAVA)
# ======================================
echo -e "${BLUE}[6/6] Formatting KRaft metadata${NC}"
/opt/kafka/bin/kafka-storage.sh format \
  -t $(/opt/kafka/bin/kafka-storage.sh random-uuid) \
  -c /opt/kafka/config/kraft/server.properties

echo -e "${GREEN}[OK] KRaft metadata formatted${NC}"

# ======================================
# DONE
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
