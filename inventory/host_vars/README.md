# host_vars

Lab 2, Part B: create one file per host, named after the host's inventory name:

- `web1.yml`
- `web2.yml`

Each file sets `site_color` to a colour of your choice, different for each host
(for example `"#1E8F8A"` for web1 and `"#B5462A"` for web2).

A value in `host_vars/web1.yml` wins over the same variable in `group_vars/web/`.
