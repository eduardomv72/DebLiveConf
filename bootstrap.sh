#!/usr/bin/env bash
# Uso en un live recién arrancado (con red):
#   curl -fsSL https://raw.githubusercontent.com/eduardomv72/DebLiveConf/main/bootstrap.sh | sudo bash
# Con secretos cifrados (vault):
#   curl -fsSL .../bootstrap.sh | sudo bash -s -- --ask-vault-pass
# Cualquier argumento extra se pasa a ansible-pull (p. ej. --tags gnome).
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

export REPO_URL="${REPO_URL:-https://github.com/eduardomv72/DebLiveConf.git}"
export BRANCH="${BRANCH:-main}"
export PLAYBOOK="${PLAYBOOK:-main.yml}"
export REPO_DEST="/home/user/DebLiveConf"

#if [[ $EUID -ne 0 ]]; then
#  echo "Ejecuta este script como root (sudo bash)." >&2
#  exit 1
#fi


#apt-get update
#apt-get install -y --no-install-recommends ansible git

ansible-pull -U "$REPO_URL" -C "$BRANCH" -d "$REPO_DEST" "$@" "$PLAYBOOK"

git config --global user.email "eduardomv72@gmail.com"
