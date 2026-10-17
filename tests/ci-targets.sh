#!/usr/bin/env bash
# Used by the autograder (and by "make test"): start two fresh containers and
# write a CI inventory pointing at them. It lives in inventory/ so that your
# group_vars/ and host_vars/ apply to it exactly as they apply to hosts.ini.
# The GitHub runner cannot reach your Azure VMs, so it never uses hosts.ini.
set -euo pipefail
cd "$(dirname "$0")/.."

export KEY="$PWD/.ci_key"
rm -f "$KEY" "$KEY.pub"
ssh-keygen -q -t ed25519 -N "" -f "$KEY"
./targets/local-up.sh >/dev/null

cat > inventory/ci.ini <<INI
[web]
web1 ansible_host=127.0.0.1 ansible_port=2221 ansible_ssh_private_key_file=$KEY
web2 ansible_host=127.0.0.1 ansible_port=2222 ansible_ssh_private_key_file=$KEY
INI

# The lab vault password (see the handout, Part E). Lab only: in real life a
# vault password comes from a secret store, never from a script in Git.
printf '%s\n' "sesame-cao-lab2" > .ci_vault_pass
chmod 600 .ci_vault_pass

for p in 2221 2222; do
  for _ in $(seq 1 30); do
    ssh -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
        -i "$KEY" -p "$p" azureuser@127.0.0.1 true && break
    sleep 1
  done
done
echo "CI targets ready."
