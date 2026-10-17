# Cloud Automation and Orchestration - Lab 2

SESAME University, Computer Engineering, ING5. Week 3: variables, templates, loops, conditions, handlers and Ansible Vault.

You start from the Lab 1 playbook and make it configurable: variables in `group_vars` and `host_vars`, a Jinja2 template for the page and for the nginx configuration, a handler that reloads nginx only when its configuration changes, users created in a loop, a maintenance page behind a condition, and a database password kept encrypted with Ansible Vault.

## Start

1. Open this repository in a Codespace (**Code > Codespaces > Create codespace on main**).
2. Wait for `Toolbox ready`, then run `make check`.
3. Follow the Lab 2 handout shared in class.

## Two ways to get servers

| Path | Command | Servers | When |
| --- | --- | --- | --- |
| Azure (default) | `make azure-up` | 2 Ubuntu VMs, `Standard_B1s` | Your Azure for Students subscription works |
| Local (fallback) | `make local-up` | 2 Ubuntu containers in your Codespace | No Azure yet, or Azure is blocked |

**Before you leave:** `make azure-down` (or `make local-down`), then stop your Codespace.

## What you edit

| File | Part |
| --- | --- |
| `inventory/hosts.ini` | A: your two servers |
| `inventory/group_vars/web/vars.yml`, `inventory/host_vars/web1.yml`, `web2.yml` | B: variables |
| `playbooks/templates/index.html.j2`, `playbooks/templates/nginx-site.conf.j2` | C: templates |
| `playbooks/site.yml` | C, D, E: tasks and the handler |
| `inventory/group_vars/web/vault.yml` (you create it) | E: the encrypted secret |
| `SUBMISSION.md` | answers |

## Grading (10 points, autograded on every push)

| Check | Points |
| --- | --- |
| Part B: variables in `group_vars` and `host_vars`, with the right types | 1 |
| Parts C and D: playbook runs; pages, nginx config, users and maintenance page are right | 3 |
| Second run reports `changed=0` (and the hosts are still right) | 2 |
| Handler fixes a changed nginx config; `maintenance_mode` works both ways | 1 |
| Part E: secret encrypted in Git, delivered to the hosts with mode 0600 | 1 |
| `SUBMISSION.md` complete | 2 |

The autograder runs your playbook against two fresh containers on GitHub, not against your Azure VMs. Run the same checks yourself with `make test`.
