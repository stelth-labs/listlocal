FROM rockylinux:9.3
MAINTAINER "@StelthLabs"

## This Dockerfile represents a viable substitute for an equivalent "Vagrant Box" for use with Vagrant.
## A Vagrant "Box" would classically be a .box image file, which is a tarball of a VirtualBox VM image.
## Those are well-known to bloated and slow.
##
## In this case, we bend the rules a bit and use Docker with systemd to create a Vagrant Box-like image
## that can be used with Vagrant, but is much smaller and faster to download and use.
##
## It provides the same Developer Experience as working with a Vagrant Box, by providing the one thing that is
## fundamental for Vagrant --> ssh access a-la "vagrant ssh".

## Install the necessary packages and perform cleanup to make things work in a Docker container
RUN dnf -y update && \
    dnf -y install systemd dbus systemd-libs sudo openssh-server procps net-tools && \
    dnf clean all && \
    (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;

# Configure sshd to allow root login and password authentication for Vagrant
RUN sed -i 's/^\(UsePAM yes\)/# \1/' /etc/ssh/sshd_config; \
    ssh-keygen -q -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N '' && \
    ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' && \
    ssh-keygen -t dsa -f /etc/ssh/ssh_host_ed25519_key  -N ''; \
    sed -i 's/^#\(PermitRootLogin\) .*/\1 yes/' /etc/ssh/sshd_config; \
    sed -i 's/^UsePAM yes/UsePAM no/' /etc/ssh/sshd_config.d/50-redhat.conf; \
    rm -f /run/nologin; \
    dnf clean all;

# Setup the 'vagrant' user with sudo privileges
RUN useradd -m -G wheel -s /bin/bash vagrant && \
    echo 'vagrant:vagrant' | chpasswd && \
    echo 'vagrant ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/vagrant && \
    chmod 0440 /etc/sudoers.d/vagrant

# Establish generic ssh keys for vagrant
RUN mkdir -p /home/vagrant/.ssh; \
  chmod 700 /home/vagrant/.ssh
ADD https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub /home/vagrant/.ssh/authorized_keys
RUN chmod 600 /home/vagrant/.ssh/authorized_keys; \
  chown -R vagrant:vagrant /home/vagrant/.ssh

# Render a clever entrypoint script to handle the timezone and root password
RUN { \
    echo '#!/bin/bash -eu'; \
    echo 'ln -fs /usr/share/zoneinfo/${TIMEZONE} /etc/localtime'; \
    echo 'echo "root:${ROOT_PASSWORD}" | chpasswd'; \
    echo 'exec "$@"'; \
    } > /usr/local/bin/entry_point.sh; \
    chmod +x /usr/local/bin/entry_point.sh;

# Ensure sshd starts properly
RUN systemctl enable sshd.service

# Final touches
ENV TIMEZONE Asia/Yerevan
ENV ROOT_PASSWORD root

# Expose the ssh port
EXPOSE 22
ENTRYPOINT ["entry_point.sh"]

# Start systemd
CMD ["/usr/sbin/init"]


### GRAVEYARD
# CMD ["/usr/sbin/sshd", "-D", "-e"]
# VOLUME [ "/sys/fs/cgroup" ]
