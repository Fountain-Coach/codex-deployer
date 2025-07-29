#!/bin/bash
# DEPRECATED: This script bootstraps the legacy Python dispatcher environment.
# TODO: replace with setup steps for the Swift orchestrator loop.

set -e

echo "[BOOTSTRAP] Updating and installing system dependencies..."
apt update && apt install -y git python3 python3-pip curl unzip
# Install Swift using swiftly to ensure a modern toolchain
curl -L https://github.com/swift-server/swiftly/releases/download/1.0.1/swiftly-linux-amd64.tar.gz | tar -xz -C /usr/local/bin
/usr/local/bin/swiftly install 6.1.2

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

# © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.


