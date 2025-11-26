#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
    echo "Loading environment variables from .env file..."
    set -a  # automatically export all variables
    source .env
    set +a
    echo "Environment loaded successfully!"
    echo ""
else
    echo "Warning: .env file not found. Please create one or set environment variables manually."
    exit 1
fi

# Display current configuration
echo "=== Current FTP Configuration ==="
echo "FTP Host: ${INPUT_FTP_HOST}"
echo "FTP User: ${INPUT_FTP_USER}"
echo "FTP Password: [HIDDEN]"
echo "FTP Root Folder: ${INPUT_FTP_ROOT_FOLDER}"
echo "Local Folder: ${INPUT_LOCAL_FOLDER}"
echo "Sync Mode: ${INPUT_SYNC_MODE}"
echo ""

# Ask for confirmation before proceeding
read -p "Do you want to proceed with these settings? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 0
fi

# Create local folder if it doesn't exist
if [ ! -d "$INPUT_LOCAL_FOLDER" ]; then
    echo "Creating local folder: $INPUT_LOCAL_FOLDER"
    mkdir -p "$INPUT_LOCAL_FOLDER"
fi

# Run the sync script
echo ""
echo "=== Running FTP Sync ==="
echo "Starting sync operation..."
echo ""

./sync-ftp.sh