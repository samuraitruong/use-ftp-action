#!/bin/sh -l

# Function to display error message and exit
error_exit() {
    echo "$1" 1>&2
    exit 1
}

# Check if required parameters are provided
[ -z "$INPUT_FTP_USER" ] && error_exit "FTP_USER is not provided"
[ -z "$INPUT_FTP_PASSWORD" ] && error_exit "FTP_PASSWORD is not provided"
[ -z "$INPUT_FTP_HOST" ] && error_exit "FTP_HOST is not provided"

# Set default values for optional parameters
INPUT_FTP_ROOT_FOLDER="${INPUT_FTP_ROOT_FOLDER:-.}"
INPUT_LOCAL_FOLDER="${INPUT_LOCAL_FOLDER:-.}"
INPUT_SYNC_MODE="${INPUT_SYNC_MODE:-download}"

# Performance and connection settings (optimized for slow/limited FTP servers)
INPUT_PARALLEL_CONNECTIONS="${INPUT_PARALLEL_CONNECTIONS:-1}"  # Default to 1 for slow servers
INPUT_CONNECTION_TIMEOUT="${INPUT_CONNECTION_TIMEOUT:-30}"      # Connection timeout in seconds
INPUT_RETRY_COUNT="${INPUT_RETRY_COUNT:-3}"                    # Number of retries
INPUT_TRANSFER_RATE_LIMIT="${INPUT_TRANSFER_RATE_LIMIT:-0}"     # KB/s limit (0 = unlimited)
INPUT_DEBUG_MODE="${INPUT_DEBUG_MODE:-false}"                  # Enable verbose logging

# Configure lftp SSL settings to handle weak DH keys and SSL issues
export LFTP_SSL_ALLOW_UNKNOWN_CERTS=1
export LFTP_SSL_FORCE=no

# Create lftp configuration optimized for slow/unreliable FTP servers
cat > ~/.lftprc << EOF
# SSL/Security settings
set ssl:verify-certificate false
set ssl:check-hostname false
set ftp:ssl-allow no
set ftp:ssl-force no
set ftp:ssl-protect-data false
set ssl-allow false

# Connection and performance settings
set net:connection-limit $INPUT_PARALLEL_CONNECTIONS
set net:connection-take-over yes
set net:timeout $INPUT_CONNECTION_TIMEOUT
set net:max-retries $INPUT_RETRY_COUNT
set net:reconnect-interval-base 5
set net:reconnect-interval-multiplier 1.5
set net:reconnect-interval-max 30

# Transfer settings
set ftp:passive-mode true
set ftp:use-feat false
set ftp:use-mdtm false
set ftp:use-size false
set ftp:rest-list true
$([ "$INPUT_TRANSFER_RATE_LIMIT" -gt 0 ] && echo "set net:limit-rate ${INPUT_TRANSFER_RATE_LIMIT}k")

# Debugging (if enabled)
$([ "$INPUT_DEBUG_MODE" = "true" ] && echo "set debug 3" || echo "set debug 0")
EOF

# Display configuration for debugging
echo "FTP Sync Configuration:"
echo "  Host: $INPUT_FTP_HOST"
echo "  User: $INPUT_FTP_USER"
echo "  Mode: $INPUT_SYNC_MODE"
echo "  Parallel connections: $INPUT_PARALLEL_CONNECTIONS"
echo "  Connection timeout: ${INPUT_CONNECTION_TIMEOUT}s"
echo "  Retry count: $INPUT_RETRY_COUNT"
echo "  Rate limit: ${INPUT_TRANSFER_RATE_LIMIT}KB/s (0=unlimited)"
echo "  Debug mode: $INPUT_DEBUG_MODE"
echo ""

# Build mirror command with optimized options for slow servers
MIRROR_OPTIONS="--verbose --continue"

# Add parallel connections (but respect the limit)
if [ "$INPUT_PARALLEL_CONNECTIONS" -gt 1 ]; then
    MIRROR_OPTIONS="$MIRROR_OPTIONS --parallel=$INPUT_PARALLEL_CONNECTIONS"
else
    echo "Using single connection mode for maximum compatibility with slow servers"
fi

# Sync or upload based on SYNC_MODE
if [ "$INPUT_SYNC_MODE" = "download" ]; then
    echo "Starting download from $INPUT_FTP_ROOT_FOLDER to $INPUT_LOCAL_FOLDER..."
    lftp -u "$INPUT_FTP_USER","$INPUT_FTP_PASSWORD" "$INPUT_FTP_HOST" -e "mirror $MIRROR_OPTIONS --only-newer $INPUT_FTP_ROOT_FOLDER $INPUT_LOCAL_FOLDER; exit"
elif [ "$INPUT_SYNC_MODE" = "upload" ]; then
    echo "Starting upload from $INPUT_LOCAL_FOLDER to $INPUT_FTP_ROOT_FOLDER..."
    lftp -u "$INPUT_FTP_USER","$INPUT_FTP_PASSWORD" "$INPUT_FTP_HOST" -e "mirror $MIRROR_OPTIONS --reverse $INPUT_LOCAL_FOLDER $INPUT_FTP_ROOT_FOLDER; exit"
else
    error_exit "Invalid SYNC_MODE: $INPUT_SYNC_MODE. Valid values are 'download' or 'upload'"
fi

echo "FTP sync operation completed."
