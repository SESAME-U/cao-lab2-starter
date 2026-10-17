#!/usr/bin/env bash
# Autograded checks for Lab 2, run against the two CI containers.
#   converge   the playbook runs; pages, nginx config, users and the
#              maintenance page are as expected
#   idempotent a second run reports changed=0
#   handlers   a drifted nginx config is fixed and triggers the handler;
#              maintenance_mode=true shows the maintenance page
#   vault      the secret is encrypted in Git and lands on the hosts, mode 0600
set -uo pipefail
source "$(dirname "$0")/common.sh"
mode="${1:-converge}"

page() { curl -fsS "http://127.0.0.1:808$1/$2"; }
code() { curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:808$1/$2"; }
# hv HOST VAR: print a host variable, one line per list item (maps as JSON).
hv() { ansible-inventory -i "$INV" "${VAULT_OPT[@]}" --host "$1" | python3 -c '
import json, sys
v = json.load(sys.stdin).get(sys.argv[1])
for x in (v if isinstance(v, list) else [v]):
    print(json.dumps(x) if isinstance(x, dict) else x)' "$2"; }

# check_state: the hosts are in the state the lab asks for.
check_state() {
    grep -Eq '\{\{ *http_port *\}\}' playbooks/templates/nginx-site.conf.j2 \
      || { echo "nginx-site.conf.j2 must use the variable http_port"; return 1; }
    for i in 1 2; do
      p=$(page $i "") || { echo "web$i: no page on port 808$i"; return 1; }
      grep -q "Hello from web$i" <<<"$p" || { echo "web$i: page does not say 'Hello from web$i'"; return 1; }
      color=$(hv web$i site_color)
      grep -qF "$color" <<<"$p" || { echo "web$i: page does not use its site_color ($color)"; return 1; }
      grep -q "Running Ubuntu" <<<"$p" || { echo "web$i: page does not show 'Running Ubuntu ...' from the facts"; return 1; }
      while read -r f; do
        grep -Eq "<li>[[:space:]]*$f[[:space:]]*</li>" <<<"$p" || { echo "web$i: no <li> for feature '$f'"; return 1; }
      done < <(hv web$i shop_features)
      while read -r u; do
        docker exec "web$i" id "$u" >/dev/null 2>&1 || { echo "web$i: user '$u' does not exist"; return 1; }
      done < <(hv web$i app_users | python3 -c "import sys,json; [print(json.loads(l)['name']) for l in sys.stdin if l.strip()]")
      [[ $(code $i maintenance.html) == 404 ]] || { echo "web$i: maintenance.html must not exist when maintenance_mode is false"; return 1; }
    done
}

case "$mode" in
  converge)
    play --syntax-check >/dev/null || exit 1
    play || exit 1
    check_state || exit 1
    echo "OK: both servers converge"
    ;;
  idempotent)
    out=$(play) || { echo "$out"; exit 1; }
    echo "$out" | sed -n '/PLAY RECAP/,$p'
    if echo "$out" | sed -n '/PLAY RECAP/,$p' | grep -Eq 'changed=[1-9]'; then
      echo "Second run changed something: the playbook is not idempotent."
      exit 1
    fi
    check_state >/dev/null || { echo "The hosts are not in the expected state yet (see the converge check)."; exit 1; }
    echo "OK: second run changed nothing"
    ;;
  handlers)
    docker exec web1 sh -c 'echo "# manual edit" >> /etc/nginx/sites-available/default'
    out=$(play) || { echo "$out"; exit 1; }
    grep -q "RUNNING HANDLER" <<<"$out" || { echo "A changed nginx config must notify a handler."; exit 1; }
    docker exec web1 grep -q "manual edit" /etc/nginx/sites-available/default \
      && { echo "The manual edit is still in the nginx config."; exit 1; }
    out=$(play -e maintenance_mode=true) || { echo "$out"; exit 1; }
    for i in 1 2; do
      [[ $(code $i maintenance.html) == 200 ]] || { echo "web$i: maintenance_mode=true must publish maintenance.html"; exit 1; }
    done
    out=$(play -e maintenance_mode=false) || { echo "$out"; exit 1; }
    [[ $(code 1 maintenance.html) == 404 ]] || { echo "maintenance_mode=false must remove maintenance.html again"; exit 1; }
    echo "OK: handler and conditions work"
    ;;
  vault)
    vf=inventory/group_vars/web/vault.yml
    [[ -f $vf ]] || { echo "$vf is missing"; exit 1; }
    head -1 "$vf" | grep -q '^\$ANSIBLE_VAULT;' || { echo "$vf is not encrypted"; exit 1; }
    secret=$(ansible-vault view "${VAULT_OPT[@]}" "$vf" \
      | python3 -c "import yaml,sys; print((yaml.safe_load(sys.stdin) or {}).get('vault_db_password',''))") \
      || { echo "cannot decrypt $vf with the lab vault password"; exit 1; }
    [[ -n $secret ]] || { echo "$vf must define vault_db_password"; exit 1; }
    grep -Eq '^db_password: *"\{\{ *vault_db_password *\}\}"' inventory/group_vars/web/vars.yml \
      || { echo 'vars.yml must contain: db_password: "{{ vault_db_password }}"'; exit 1; }
    if grep -rqF --exclude=vault.yml -- "$secret" inventory playbooks; then
      echo "The secret appears in clear text in a file under inventory/ or playbooks/."; exit 1
    fi
    grep -q 'no_log: true' playbooks/site.yml || { echo "The task that writes the secret needs no_log: true"; exit 1; }
    for i in 1 2; do
      m=$(docker exec "web$i" stat -c %a /etc/shop/app.env 2>/dev/null) || { echo "web$i: /etc/shop/app.env missing"; exit 1; }
      [[ $m == 600 ]] || { echo "web$i: app.env mode is $m, expected 600"; exit 1; }
      docker exec "web$i" grep -qxF "DB_PASSWORD=$secret" /etc/shop/app.env || { echo "web$i: app.env does not contain DB_PASSWORD=<your secret>"; exit 1; }
    done
    echo "OK: the secret is encrypted in Git and delivered safely"
    ;;
  *) echo "usage: $0 converge|idempotent|handlers|vault"; exit 2 ;;
esac
