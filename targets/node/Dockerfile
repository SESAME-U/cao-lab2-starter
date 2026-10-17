# A minimal "server" for Ansible to manage: Ubuntu 24.04 with SSH and Python.
# Used by targets/local-up.sh (the no-Azure path) and by the autograder.
FROM ubuntu:24.04

# nginx is pre-installed (but not started) only in this container image:
# Ubuntu's default site also listens on IPv6 ([::]:80), which fails in
# containers without IPv6. We keep the IPv4 listener only. On a real VM
# (the Azure path) your playbook installs nginx itself.
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      openssh-server python3 sudo ca-certificates nginx \
 && sed -i '/listen \[::\]/d' /etc/nginx/sites-available/default \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /run/sshd \
 && useradd --create-home --shell /bin/bash azureuser \
 && echo "azureuser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/azureuser \
 && chmod 0440 /etc/sudoers.d/azureuser \
 && mkdir -p /home/azureuser/.ssh \
 && chmod 700 /home/azureuser/.ssh

# The public key is passed at build time so each student uses their own key.
ARG PUBKEY
RUN echo "$PUBKEY" > /home/azureuser/.ssh/authorized_keys \
 && chmod 600 /home/azureuser/.ssh/authorized_keys \
 && chown -R azureuser:azureuser /home/azureuser/.ssh

EXPOSE 22 80
CMD ["/usr/sbin/sshd", "-D", "-e"]
