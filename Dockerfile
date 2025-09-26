FROM alpine:latest

# Install lftp
RUN apk --no-cache add lftp

# Configure OpenSSL to allow legacy connections and weaker DH keys
RUN echo "openssl_conf = default_conf" >> /etc/ssl/openssl.cnf && \
    echo "[default_conf]" >> /etc/ssl/openssl.cnf && \
    echo "ssl_conf = ssl_sect" >> /etc/ssl/openssl.cnf && \
    echo "[ssl_sect]" >> /etc/ssl/openssl.cnf && \
    echo "system_default = ssl_default_sect" >> /etc/ssl/openssl.cnf && \
    echo "[ssl_default_sect]" >> /etc/ssl/openssl.cnf && \
    echo "CipherString = DEFAULT:@SECLEVEL=1" >> /etc/ssl/openssl.cnf

# Copy sync script
COPY sync-ftp.sh /usr/local/bin/sync-ftp.sh

# Make script executable
RUN chmod +x /usr/local/bin/sync-ftp.sh

ENTRYPOINT ["/usr/local/bin/sync-ftp.sh"]