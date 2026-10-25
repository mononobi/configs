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
    echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    ln -fs /usr/share/zoneinfo/UTC /etc/localtime && \
    groupadd -f docker && usermod -aG docker ubuntu

# Add container stubs and wrappers (systemctl, apparmor_parser, udevadm)
RUN printf '#!/bin/sh\ncase "$*" in\n  *docker*)\n    if [ ! -S /var/run/docker.sock ]; then\n      if [ -x /usr/bin/dockerd ]; then\n        /usr/bin/dockerd >/var/log/dockerd.log 2>&1 &\n        for i in 1 2 3 4 5; do\n          [ -S /var/run/docker.sock ] && break\n          sleep 1\n        done\n        chmod 666 /var/run/docker.sock 2>/dev/null || true\n      elif [ -x /etc/init.d/docker ]; then\n        service docker start >/dev/null 2>&1 || true\n        chmod 666 /var/run/docker.sock 2>/dev/null || true\n      fi\n    fi\n    ;;\nesac\nexit 0\n' > /usr/local/bin/systemctl && \
    chmod +x /usr/local/bin/systemctl && \
    printf '#!/bin/sh\nexit 0\n' > /usr/local/bin/apparmor_parser && \
    chmod +x /usr/local/bin/apparmor_parser && \
    printf '#!/bin/sh\nif [ ! -S /run/udev/control ]; then\n    case "$1" in\n        control|trigger) exit 0 ;;\n    esac\nfi\nif [ -x /bin/udevadm ]; then\n    exec /bin/udevadm "$@"\nelif [ -x /usr/bin/udevadm ]; then\n    exec /usr/bin/udevadm "$@"\nfi\nexit 0\n' > /usr/local/bin/udevadm && \
    chmod +x /usr/local/bin/udevadm

# Add entrypoint script to initialize background daemons (e.g. dbus, docker)
RUN printf '#!/bin/sh\nif [ -f /etc/resolv.conf ] && mountpoint -q /etc/resolv.conf 2>/dev/null; then\n    sudo cp /etc/resolv.conf /tmp/resolv.conf.tmp && \\\n    sudo umount /etc/resolv.conf && \\\n    sudo cp /tmp/resolv.conf.tmp /etc/resolv.conf && \\\n    sudo chmod 644 /etc/resolv.conf && \\\n    sudo rm -f /tmp/resolv.conf.tmp || true\nfi\nif [ -x /etc/init.d/dbus ] && ! service dbus status >/dev/null 2>&1; then\n    sudo service dbus start >/dev/null 2>&1 || true\nfi\nif [ ! -S /var/run/docker.sock ]; then\n    if [ -x /usr/bin/dockerd ]; then\n        sudo /usr/bin/dockerd >/var/log/dockerd.log 2>&1 &\n        for i in 1 2 3 4 5; do\n            [ -S /var/run/docker.sock ] && break\n            sleep 1\n        done\n        sudo chmod 666 /var/run/docker.sock 2>/dev/null || true\n    elif [ -x /etc/init.d/docker ]; then\n        sudo service docker start >/dev/null 2>&1 || true\n        sudo chmod 666 /var/run/docker.sock >/dev/null 2>&1 || true\n    fi\nfi\nexec "$@"\n' > /usr/local/bin/docker-entrypoint.sh && \
    chmod +x /usr/local/bin/docker-entrypoint.sh

# Copy entire linux directory into /home/ubuntu/configs/linux with proper ownership
COPY --chown=ubuntu:ubuntu linux /home/ubuntu/configs/linux

# Set execution user and working directory to installer root
USER ubuntu
WORKDIR /home/ubuntu/configs/linux/install

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/bin/bash"]
