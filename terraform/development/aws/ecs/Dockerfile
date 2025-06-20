# Dockerfile
FROM debian:bullseye-slim

# Install corosync-qnetd
RUN apt-get update && \
    apt-get install -y \
    corosync-qnetd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create qnetd user
RUN useradd -r -s /bin/false -d /var/lib/corosync qnetd

# Create necessary directories
RUN mkdir -p /etc/corosync/qnetd \
    && chown -R qnetd:qnetd /etc/corosync/qnetd

# Expose QDevice port
EXPOSE 5403

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD netstat -ln | grep :5403 || exit 1

# Start qnetd
CMD ["corosync-qnetd", "-f"]