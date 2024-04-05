FROM alpine:latest

# Install lftp
RUN apk --no-cache add lftp

# Copy sync script
COPY sync-ftp.sh /usr/local/bin/sync-ftp.sh

# Make script executable
RUN chmod +x /usr/local/bin/sync-ftp.sh

ENTRYPOINT ["/usr/local/bin/sync-ftp.sh"]