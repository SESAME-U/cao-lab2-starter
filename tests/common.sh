# Shared settings for the Lab 2 checks. Sourced, not run.
cd "$(dirname "${BASH_SOURCE[0]}")/.."
if [[ -f inventory/ci.ini ]]; then INV="inventory/ci.ini"; else INV="inventory/hosts.ini"; fi
# The CI vault password file wins over the one in ansible.cfg (the runner
# has no ~/.cao_vault_pass). Locally, ansible.cfg is used as is.
if [[ -f .ci_vault_pass ]]; then export ANSIBLE_VAULT_PASSWORD_FILE="$PWD/.ci_vault_pass"; fi
VAULT_OPT=()
play() { ansible-playbook -i "$INV" playbooks/site.yml "$@"; }
