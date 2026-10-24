FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=ubuntu

# Install only minimal container infrastructure packages
RUN apt-get update -qq && \
    apt-get install -y -qq --no-install-recommends \
        sudo \
        iptables \
        dbus && \
    rm -rf /var/lib/apt/lists/*

# Set default passwords ('ubuntu' for ubuntu, 'root' for root)
RUN echo "ubuntu:ubuntu" | chpasswd && \
    echo "root:root" | chpasswd

# Grant passwordless sudo to default 'ubuntu' user (UID 1000) and preserve noninteractive frontend
RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu && \
    echo 'Defaults env_keep += "DEBIAN_FRONTEND"' >> /etc/sudoers.d/ubuntu && \
    chmod 0440 /etc/sudoers.d/ubuntu && \
    echo "DEBIAN_FRONTEND=noninteractive" >> /etc/environment && \
    ln -fs /usr/share/zoneinfo/UTC /etc/localtime

# Add systemctl stub to prevent service daemon failures in container environments
RUN printf '#!/bin/sh\nexit 0\n' > /usr/local/bin/systemctl && \
    chmod +x /usr/local/bin/systemctl

# Add entrypoint script to initialize background daemons (e.g. dbus)
RUN printf '#!/bin/sh\nif [ -x /etc/init.d/dbus ] && ! service dbus status >/dev/null 2>&1; then\n    sudo service dbus start >/dev/null 2>&1 || true\nfi\nexec "$@"\n' > /usr/local/bin/docker-entrypoint.sh && \
    chmod +x /usr/local/bin/docker-entrypoint.sh

# Copy entire linux directory into /home/ubuntu/configs/linux with proper ownership
COPY --chown=ubuntu:ubuntu linux /home/ubuntu/configs/linux

# Set execution user and working directory to installer root
USER ubuntu
WORKDIR /home/ubuntu/configs/linux/install

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/bin/bash"]
