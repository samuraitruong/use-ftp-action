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

# Configure lftp SSL settings to handle weak DH keys and SSL issues
export LFTP_SSL_ALLOW_UNKNOWN_CERTS=1
export LFTP_SSL_FORCE=no

# Create lftp configuration to handle SSL issues
cat > ~/.lftprc << EOF
set ssl:verify-certificate false
set ssl:check-hostname false
set ftp:ssl-allow no
set ftp:ssl-force no
set ftp:ssl-protect-data false
set ssl-allow false
EOF

# Sync or upload based on SYNC_MODE
if [ "$INPUT_SYNC_MODE" = "download" ]; then
    lftp -e "mirror --parallel=20 --overwrite --only-newer $INPUT_FTP_ROOT_FOLDER $INPUT_LOCAL_FOLDER;quit" -u "$INPUT_FTP_USER","$INPUT_FTP_PASSWORD" "$INPUT_FTP_HOST"
    # lftp -u "$INPUT_FTP_USER","$INPUT_FTP_PASSWORD" "$INPUT_FTP_HOST" -e "mirror --verbose --continue --reverse $INPUT_FTP_ROOT_FOLDER $INPUT_LOCAL_FOLDER; exit"
elif [ "$INPUT_SYNC_MODE" = "upload" ]; then
    lftp -u "$INPUT_FTP_USER","$INPUT_FTP_PASSWORD" "$INPUT_FTP_HOST" -e "mirror --verbose --continue $INPUT_LOCAL_FOLDER $INPUT_FTP_ROOT_FOLDER; exit"
else
    error_exit "Invalid SYNC_MODE: $INPUT_SYNC_MODE. Valid values are 'download' or 'upload'"
fi
