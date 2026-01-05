
It explains  **what the setup does** ,  **how installation works on ANY Linux** , and  **how to move from GitHub → GitLab easily** , in  **simple language** .

---

```markdown
# Kafka 4.x Offline Installation – Production Ready (GitHub → GitLab)

This repository provides a **fully offline, production-safe installation of Apache Kafka 4.x** using **KRaft mode** (ZooKeeper removed).

The same repository can be:
- Used on **GitHub now**
- Moved to **GitLab later**
- Installed on **any Linux server without internet**

No rebuilding. No downloads during install.

---

## 1️⃣ What This Setup Does (Simple Explanation)

When you run the install script, it will:

1. Install **Java 17** locally from a bundled file  
2. Install **Kafka 4.x** locally from a bundled binary  
3. Configure Kafka in **KRaft mode**  
4. Create a **permanent data directory**  
5. Format Kafka metadata (required for KRaft)  

After installation:
- Kafka runs fully offline
- Data is stored safely (not in `/tmp`)
- The system is ready for production use

---

## 2️⃣ Why This Setup Is Production Safe

### ❌ What is NOT used
- `git clone apache/kafka`
- `apt install kafka`
- Gradle build
- ZooKeeper
- Internet access during install

### ✅ What IS used
- Kafka official binary (`.tgz`)
- Java binary (`.tar.gz`)
- Local files only
- Permanent data storage

This matches how Kafka is deployed in real enterprise environments.

---

## 3️⃣ Repository Structure (DO NOT CHANGE)

```

kafka-offline-setup/
├── artifacts/
│ ├── kafka_2.13-4.0.0.tgz
│ └── jdk-17_linux-x64_bin.tar.gz
├── configs/
│ └── server.properties
├── env/
│ └── kafka.env
├── scripts/
│ └── install.sh
└── README.md

```

Everything Kafka needs is already inside this repository.

---

## 4️⃣ Kafka Data Safety (IMPORTANT)

Kafka **does NOT** store data in `/tmp`.

Instead, this setup forces Kafka to store all data in:

```

/opt/kafka/data

```

This directory contains:
- Topics
- Partitions
- Offsets
- Index files
- Log segments

This prevents **data loss on reboot**.

---

## 5️⃣ Supported Linux Distributions

This setup works on:

- Ubuntu 20.04 / 22.04 / 24.04
- Debian 11+
- RHEL / Rocky / Alma Linux 8+
- Any system with:
  - Bash
  - tar
  - sudo

No package manager dependency.

---

## 6️⃣ How to Install on Any Linux Machine (Offline)

### Step 1: Clone the repository

From GitHub (now):

```bash
git clone https://github.com/YOUR-ORG/kafka-offline-setup.git
cd kafka-offline-setup
```

From GitLab (later):

```bash
git clone http://gitlab.local/infra/kafka-offline-setup.git
cd kafka-offline-setup
```

---

### Step 2: Make install script executable

```bash
chmod +x scripts/install.sh
```

---

### Step 3: Run installation

```bash
sudo bash scripts/install.sh
```

What this does internally:

* Extracts Java to `/opt/java`
* Extracts Kafka to `/opt/kafka`
* Creates `/opt/kafka/data`
* Copies Kafka configuration
* Formats KRaft metadata

No internet is required.

---

## 7️⃣ Start Kafka

After installation:

```bash
/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/kraft/server.properties
```

Kafka ports:

* Broker: `9092` (applications connect here)
* Controller: `9093` (Kafka internal use only)

---

## 8️⃣ Verify Kafka Is Working

Create a test topic:

```bash
/opt/kafka/bin/kafka-topics.sh \
  --create \
  --topic test-topic \
  --bootstrap-server localhost:9092 \
  --partitions 3 \
  --replication-factor 1
```

List topics:

```bash
/opt/kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:9092
```

Check data storage:

```bash
ls /opt/kafka/data
```

You should see topic and partition folders.

---

## 9️⃣ How to Push This Repo to GitHub (NOW)

From your local machine:

```bash
git init
git add .
git commit -m "Kafka 4.x offline production setup"
git branch -M main
git remote add origin https://github.com/YOUR-ORG/kafka-offline-setup.git
git push -u origin main
```

---

## 🔁 10️⃣ How to Move This Repo from GitHub to GitLab (LATER)

When your GitLab server is ready:

```bash
git clone --mirror https://github.com/YOUR-ORG/kafka-offline-setup.git
cd kafka-offline-setup.git
git push --mirror http://gitlab.local/infra/kafka-offline-setup.git
```

✅ All commits preserved
✅ No file changes needed
✅ Installation steps remain the same

---

## 11️⃣ Common Mistakes to Avoid

❌ Building Kafka from source
❌ Using `/tmp/kafka-logs`
❌ Using ZooKeeper
❌ Downloading files during install
❌ Hardcoding GitHub URLs in scripts

---

## 12️⃣ Final Summary

* Kafka 4.x installed using official binaries
* Fully offline installation
* Permanent data storage
* GitHub now, GitLab later
* Same repo works everywhere
* Production safe

---

## ✅ Status Checklist

* [X] Kafka 4.x binary
* [X] Java 17 binary
* [X] KRaft mode
* [X] Permanent data directory
* [X] Offline installation
* [X] GitHub compatible
* [X] GitLab compatible

```

---

### ✅ What you should do now
1. Save this as **`README.md`**
2. Commit and push to GitHub
3. Use the same file later on Linux or GitLab

If you want next, I can:
- Add **systemd auto-start**
- Add **start/stop/status scripts**
- Explain **cluster mode**
- Explain **backup & recovery**

Just tell me 👍
```
