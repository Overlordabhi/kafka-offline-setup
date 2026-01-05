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
# SAFE EXTRACT FUNCTION
# ======================================
extract() {
  local file=$1
  local dest=$2

  [[ ! -f "$file" ]] && fail "File not found: $file"
  file "$file" | grep -q "gzip compressed" || fail "Invalid archive: $file"

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
# 1. INSTALL JAVA 17
# ======================================
echo -e "${BLUE}[1/8] Installing Java 17${NC}"

mkdir -p /opt/java
extract artifacts/OpenJDK17U-jdk_x64_linux_hotspot_17.0.10_7.tar.gz /opt/java

JDK_DIR=$(find /opt/java -maxdepth 1 -type d -name "jdk-17*" | head -n 1)
[[ -z "$JDK_DIR" ]] && fail "JDK directory not found"

export JAVA_HOME="$JDK_DIR"
export PATH="$JAVA_HOME/bin:$PATH"

"$JAVA_HOME/bin/java" -version || fail "Java verification failed"

echo -e "${GREEN}[OK] Java installed at $JAVA_HOME${NC}"

# ======================================
# 2. CREATE SYSTEM-WIDE JAVA SYMLINK
# ======================================
echo -e "${BLUE}[2/8] Registering system-wide java binary${NC}"

if [[ -L /usr/bin/java || -f /usr/bin/java ]]; then
  rm -f /usr/bin/java
fi

ln -s "$JAVA_HOME/bin/java" /usr/bin/java

which java >/dev/null || fail "java not found in PATH"
java -version || fail "Global java verification failed"

echo -e "${GREEN}[OK] java available at /usr/bin/java${NC}"

# ======================================
# 3. INSTALL KAFKA 4.0.0
# ======================================
echo -e "${BLUE}[3/8] Installing Kafka 4.0.0${NC}"

mkdir -p /opt/kafka
extract artifacts/kafka_2.13-4.0.0.tgz /opt

KAFKA_SRC=$(find /opt -maxdepth 1 -type d -name "kafka_*" | head -n 1)
[[ -z "$KAFKA_SRC" ]] && fail "Kafka directory not found"

mv "$KAFKA_SRC"/* /opt/kafka
rmdir "$KAFKA_SRC"

echo -e "${GREEN}[OK] Kafka installed at /opt/kafka${NC}"

# ======================================
# 4. DATA DIRECTORY
# ======================================
echo -e "${BLUE}[4/8] Creating Kafka data directory${NC}"
mkdir -p /opt/kafka/data
echo -e "${GREEN}[OK] Data directory ready${NC}"

# ======================================
# 5. APPLY CONFIGURATION
# ======================================
echo -e "${BLUE}[5/8] Applying Kafka configuration${NC}"
mkdir -p /opt/kafka/config/kraft
cp configs/server.properties /opt/kafka/config/kraft/server.properties
echo -e "${GREEN}[OK] Configuration applied${NC}"

# ======================================
# 6. SAVE ENVIRONMENT VARIABLES
# ======================================
echo -e "${BLUE}[6/8] Saving environment variables${NC}"

cat <<EOF >/etc/profile.d/kafka.sh
export JAVA_HOME=$JAVA_HOME
export KAFKA_HOME=/opt/kafka
export PATH=\$JAVA_HOME/bin:\$KAFKA_HOME/bin:\$PATH
EOF

chmod 644 /etc/profile.d/kafka.sh

# Load immediately for this script
source /etc/profile.d/kafka.sh

echo -e "${GREEN}[OK] Environment variables saved and loaded${NC}"

# ======================================
# 7. FORMAT KRAFT METADATA
# ======================================
echo -e "${BLUE}[7/8] Formatting KRaft metadata${NC}"

UUID=$(/opt/kafka/bin/kafka-storage.sh random-uuid)

 /opt/kafka/bin/kafka-storage.sh format \
   -t "$UUID" \
   -c /opt/kafka/config/kraft/server.properties

echo -e "${GREEN}[OK] KRaft metadata formatted${NC}"

# ======================================
# 8. SYSTEMD SERVICE
# ======================================
echo -e "${BLUE}[8/8] Setting up Kafka auto-start (systemd)${NC}"

cat <<EOF >/etc/systemd/system/kafka.service
[Unit]
Description=Apache Kafka 4.x (KRaft Mode)
After=network.target

[Service]
Type=simple
User=root
Group=root
Environment=JAVA_HOME=$JAVA_HOME
Environment=KAFKA_HOME=/opt/kafka
Environment=PATH=$JAVA_HOME/bin:/opt/kafka/bin:/usr/bin:/bin
ExecStart=/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/kraft/server.properties
ExecStop=/opt/kafka/bin/kafka-server-stop.sh
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reexec
systemctl daemon-reload
systemctl enable kafka
systemctl start kafka

echo -e "${GREEN}[OK] Kafka service enabled and started${NC}"

# ======================================
# DONE
# ======================================
echo -e "\n${GREEN}====================================================${NC}"
echo -e "${GREEN}Kafka 4.x Offline Installation Completed Successfully${NC}"
echo -e "${GREEN}====================================================${NC}"

echo -e "${YELLOW}Kafka Home : /opt/kafka${NC}"
echo -e "${YELLOW}Java Home  : $JAVA_HOME${NC}"
echo -e "${YELLOW}Data Dir   : /opt/kafka/data${NC}"
echo ""
echo -e "${BLUE}Kafka Status:${NC}"
systemctl status kafka --no-pager
echo ""
