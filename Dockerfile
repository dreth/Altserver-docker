FROM debian:bookworm-slim

# Set the working directory
WORKDIR /altserver

# Install necessary system dependencies
RUN apt-get update && apt-get install -y \
    libavahi-compat-libdnssd-dev \
    libusb-1.0-0-dev \
    libclang-dev \
    libusbmuxd-dev \
    libimobiledevice-utils \
    ideviceinstaller \
    usbmuxd \
    avahi-daemon \
    avahi-utils \
    libnss-mdns \
    avahi-discover \
    curl \
    screen \
    dbus \
    jq \
    supervisor \
    xz-utils \
    && apt-get clean

# Copy the altserver directory to the container
COPY scripts /altserver/scripts
COPY bin /altserver/bin
COPY lib.tar.xz /altserver/lib.tar.xz

# Make the scripts executable
RUN chmod -R +x /altserver/scripts

# Create the logs directory
RUN mkdir -p /altserver/logs

# Copy the supervisord configuration file
COPY conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Set the anisette server environment variable
ENV ALTSERVER_ANISETTE_SERVER=http://127.0.0.1:6969

# Make the entrypoint script executable
RUN chmod +x /altserver/scripts/docker-entrypoint.sh

# Use supervisord as the entrypoint
ENTRYPOINT ["/altserver/scripts/docker-entrypoint.sh"]

# Run the supervisor in the foreground
CMD ["-n"]
