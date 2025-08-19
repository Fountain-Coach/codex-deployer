#!/usr/bin/env bash
set -e
base64 --decode --ignore-garbage sample.png.b64 > sample.png
base64 --decode --ignore-garbage sample.wav.b64 > sample.wav
# © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
