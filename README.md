# live-config

Configuración Ansible para dejar un Debian 13 Live (GNOME) siempre igual. Se aplica con `ansible-pull`.

## Uso en un live recién arrancado (con red)

    curl -fsSL https://raw.githubusercontent.com/eduardomv72/DebLiveConf/main/bootstrap.sh | sudo bash

Con secretos cifrados (wifi, clave SSH):

    curl -fsSL https://raw.githubusercontent.com/eduardomv72/DebLiveConf/main/bootstrap.sh | sudo bash -s -- --ask-vault-pass

Después, para reaplicar o probar partes:

    sync-config --tags gnome
    sync-config --check --diff

## Qué toca cada rol

| Rol | Hace |
|---|---|
| preflight | Comprueba Debian, detecta usuario y live, actualiza apt |
| packages | Elimina e instala paquetes (con lista de protegidos) |
| localization | Zona horaria, locales, teclado, hostname |
| network | NetworkManager, región wifi, redes wifi del vault |
| hardware | Ajustes según hardware/VM detectado |
| gnome | Ajustes de GNOME vía dconf (valores por defecto del sistema) |
| user_env | .bashrc, vim, tmux, git, clave SSH, script sync-config |

## Personalizar

Todo se controla desde `group_vars/all/main.yml`. Los secretos van en `group_vars/all/vault.yml`
(cifrado con `ansible-vault`, ver `vault.yml.example`). Nunca subas secretos sin cifrar.

## Antes de usarlo

1. Revisa `packages_remove` con `sudo apt -s remove <paquete>`.
2. El playbook que se ejecuta es `local-emv.yml` (variable `repo_playbook` en
   `group_vars/all/main.yml`; en `bootstrap.sh`, variable de entorno `PLAYBOOK`).
3. Prueba primero en una VM con Debian 13 + GNOME.
