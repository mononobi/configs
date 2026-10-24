FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive

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

# Grant passwordless sudo to default 'ubuntu' user (UID 1000)
RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu && \
    chmod 0440 /etc/sudoers.d/ubuntu

# Add systemctl stub to prevent service daemon failures in container environments
RUN printf '#!/bin/sh\nexit 0\n' > /usr/local/bin/systemctl && \
    chmod +x /usr/local/bin/systemctl

# Copy entire linux directory into /home/ubuntu/configs/linux with proper ownership
COPY --chown=ubuntu:ubuntu linux /home/ubuntu/configs/linux

# Set execution user and working directory to installer root
USER ubuntu
WORKDIR /home/ubuntu/configs/linux/install

CMD ["/bin/bash"]
