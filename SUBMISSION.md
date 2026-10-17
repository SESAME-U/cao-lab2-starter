# Lab 2 submission

Fill in every line marked `ANSWER:` (one to three sentences each). Write the answer on the same line, right after `ANSWER:`; for pasted output, add a short summary there and paste the output below. Push before the start of the week 4 session.

## Part A - targets

- Path used (azure or local): ANSWER:

## Part B - variables

1. `site_color` is set in `group_vars/web/vars.yml` and in `host_vars/web1.yml`. Which value does web1 get, and why? Then run `ansible web1 -m ansible.builtin.debug -a "var=site_color" -e site_color=red`: what does it print, and what does that tell you about `-e`?
   ANSWER:

## Part C - templates and handlers

2. Which facts does your `index.html.j2` use, and what values do they have on your servers?
   ANSWER:

3. In your first run, `RUNNING HANDLER [Reload nginx]` appears after the last task, not right after the template task. Why? And why does it not appear in the second run?
   ANSWER:

## Part D - loops and conditions

4. Remove `| bool` from your maintenance condition, run `make run ARGS="-e maintenance_mode=false"`, then put `| bool` back. What happened, and why?
   ANSWER:

## Part E - Vault

5. Paste the first line of `inventory/group_vars/web/vault.yml`. Why is it safe to commit this file, and which file must never be committed?
   ANSWER:

6. Why do we use two variables, `db_password` in `vars.yml` and `vault_db_password` in `vault.yml`, instead of one?
   ANSWER:

## Cleanup

- Azure resource group deleted, or local containers removed (yes/no): ANSWER:
