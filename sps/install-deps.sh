#!/usr/bin/env bash
set -e

if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! command -v brew >/dev/null 2>&1; then
        echo "Homebrew is required. Install from https://brew.sh" >&2
        exit 1
    fi
    brew update
    brew install pdfium tesseract
else
    if command -v apt-get >/dev/null 2>&1; then
        apt-get update
        if apt-get install -y libpdfium-dev tesseract-ocr; then
            true
        else
            echo "libpdfium-dev unavailable; using poppler-utils as fallback" >&2
            apt-get install -y poppler-utils tesseract-ocr
        fi
    else
        echo "Unsupported platform. Install PDFium and Tesseract manually." >&2
        exit 1
    fi
fi

# © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
