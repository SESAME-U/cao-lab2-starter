.PHONY: help check azure-up azure-down local-up local-down ping vault-pass test-vars run test clean

# Your vault password file (Part E), referenced in ansible.cfg.
VAULT_PASS_FILE ?= $(HOME)/.cao_vault_pass

help:
	@echo "make check        verify the toolbox"
	@echo "make azure-up     Part A, Azure path: create web1 and web2 VMs"
	@echo "make local-up     Part A, no-Azure path: start web1 and web2 containers"
	@echo "make ping         ansible web -m ping"
	@echo "make test-vars    Part B: check group_vars and host_vars"
	@echo "make vault-pass   Part E: write the lab vault password to ~/.cao_vault_pass"
	@echo "make run          run playbooks/site.yml (extra options: ARGS=\"-e x=y\")"
	@echo "make test         run the autograder checks against fresh local containers"
	@echo "make azure-down   delete the Azure VMs (do this before you leave)"
	@echo "make local-down   remove the local containers"

check:
	@bash scripts/check.sh

azure-up:
	@bash targets/azure-up.sh

azure-down:
	@bash targets/azure-down.sh

local-up:
	@bash targets/local-up.sh

local-down:
	@bash targets/local-down.sh

ping:
	ansible web -m ping

vault-pass:
	@umask 077; printf '%s\n' "sesame-cao-lab2" > $(VAULT_PASS_FILE)
	@echo "Wrote $(VAULT_PASS_FILE) (mode 600). Lab password only: never do this with a real one."

test-vars:
	@python3 tests/check_vars.py

run:
	ansible-playbook playbooks/site.yml $(ARGS)

# Same checks as the autograder, on fresh local containers (needs Docker).
# Note: this replaces the web1/web2 containers of the local path.
test:
	@bash tests/ci-targets.sh
	@python3 tests/check_vars.py
	@bash tests/check_playbook.sh converge
	@bash tests/check_playbook.sh idempotent
	@bash tests/check_playbook.sh handlers
	@bash tests/check_playbook.sh vault
	@$(MAKE) --no-print-directory clean

clean:
	rm -f inventory/ci.ini .ci_key .ci_key.pub .ci_vault_pass
