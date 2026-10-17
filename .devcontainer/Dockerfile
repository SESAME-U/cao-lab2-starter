FROM mcr.microsoft.com/devcontainers/python:1-3.12-bookworm

RUN for source in /etc/apt/sources.list.d/*; do \
      if grep -q "dl.yarnpkg.com" "$source" 2>/dev/null; then rm -f "$source"; fi; \
    done