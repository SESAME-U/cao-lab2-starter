"""Lab 2, Part B: variables live in group_vars and host_vars, with the right types."""
import json
import os
import subprocess
import sys

import yaml

os.chdir(os.path.join(os.path.dirname(__file__), ".."))
inv = "inventory/ci.ini" if os.path.exists("inventory/ci.ini") else "inventory/hosts.ini"
if os.path.exists(".ci_vault_pass"):
    os.environ["ANSIBLE_VAULT_PASSWORD_FILE"] = os.path.abspath(".ci_vault_pass")

errors = []


def fail(msg):
    errors.append(msg)


def host_vars(host):
    cmd = ["ansible-inventory", "-i", inv, "--host", host]
    out = subprocess.run(cmd, capture_output=True, text=True)
    if out.returncode != 0:
        print(out.stderr)
        sys.exit(f"ansible-inventory failed for {host}")
    return json.loads(out.stdout)


group_file = "inventory/group_vars/web/vars.yml"
try:
    with open(group_file) as f:
        group = yaml.safe_load(f) or {}
except FileNotFoundError:
    sys.exit(f"{group_file} is missing")

for h in ("web1", "web2"):
    if not os.path.exists(f"inventory/host_vars/{h}.yml"):
        fail(f"inventory/host_vars/{h}.yml is missing")

v1, v2 = host_vars("web1"), host_vars("web2")

if type(v1.get("http_port")) is not int or v1.get("http_port") != 80:
    fail(f"http_port must be the number 80, got {v1.get('http_port')!r}")
if not isinstance(v1.get("site_title"), str) or not v1.get("site_title"):
    fail("site_title must be a non-empty string")
feats = v1.get("shop_features")
if not isinstance(feats, list) or len(feats) < 3 or not all(isinstance(x, str) for x in feats):
    fail("shop_features must be a list of at least three strings")
users = v1.get("app_users")
if not isinstance(users, list) or len(users) < 2 or not all(
        isinstance(u, dict) and u.get("name") and u.get("shell") for u in users):
    fail("app_users must be a list of at least two maps, each with name and shell")
if v1.get("maintenance_mode") is not False:
    fail(f"maintenance_mode must be the boolean false, got {v1.get('maintenance_mode')!r}")

c0, c1, c2 = group.get("site_color"), v1.get("site_color"), v2.get("site_color")
if not c0:
    fail("site_color needs a default value in group_vars/web/vars.yml")
if not c1 or not c2 or c1 == c2:
    fail("web1 and web2 must each have their own site_color in host_vars")
elif c0 in (c1, c2):
    fail("each host's site_color must differ from the group default")

if errors:
    print("\n".join("FAIL: " + e for e in errors))
    sys.exit(1)
print("OK: variables are in the right place, with the right types")
