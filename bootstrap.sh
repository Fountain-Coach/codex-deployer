#!/bin/bash

set -e

echo "[BOOTSTRAP] Updating and installing system dependencies..."
apt update && apt install -y git python3 python3-pip swift curl unzip

echo "[BOOTSTRAP] Cloning codex-deployer repo into /srv/deploy..."
mkdir -p /srv && cd /srv
git clone https://github.com/fountain-coach/codex-deployer.git deploy || echo "Repo already exists"

echo "[BOOTSTRAP] Setting permissions..."
chmod +x /srv/deploy/commands/restart-services.sh
chmod +x /srv/deploy/commands/restart-target.sh

echo "[BOOTSTRAP] Copying systemd unit file..."
cp /srv/deploy/systemd/fountain-dispatcher.service /etc/systemd/system/
cp /srv/deploy/systemd/dispatcher.env /srv/deploy/dispatcher.env

echo "[BOOTSTRAP] Reminder: edit /srv/deploy/dispatcher.env with your secrets"

echo "[BOOTSTRAP] Enabling and starting dispatcher service..."
systemctl daemon-reexec
systemctl enable fountain-dispatcher
systemctl start fountain-dispatcher

echo "[BOOTSTRAP] Done. Codex deployment loop is now running."
