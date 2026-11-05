#!/usr/bin/env bash
# Uso en un live recién arrancado (con red):
#   curl -fsSL https://raw.githubusercontent.com/eduardomv72/DebLiveConf/main/bootstrap.sh | sudo bash
# Con secretos cifrados (vault):
#   curl -fsSL .../bootstrap.sh | sudo bash -s -- --ask-vault-pass
# Cualquier argumento extra se pasa a ansible-pull (p. ej. --tags gnome).
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/eduardomv72/DebLiveConf.git}"
BRANCH="${BRANCH:-main}"
PLAYBOOK="${PLAYBOOK:-local-emv.yml}"

if [[ $EUID -ne 0 ]]; then
  echo "Ejecuta este script como root (sudo bash)." >&2
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive
REPO_URL="${REPO_URL:-https://github.com/eduardomv72/DebLiveConf.git}"
BRANCH="${BRANCH:-main}"
PLAYBOOK="${PLAYBOOK:-local-emv.yml}"


apt-get update
apt-get install -y --no-install-recommends ansible git

exec ansible-pull -U "$REPO_URL" -C "$BRANCH" -d /var/lib/ansible-pull "$@" "$PLAYBOOK"
