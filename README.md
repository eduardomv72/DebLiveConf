# DebLiveConf

Configuración Ansible para dejar un Debian 13 Live (GNOME) siempre igual. Se aplica con `ansible-pull`.

## Uso en un live recién arrancado (con red)

    curl -fsSL https://raw.githubusercontent.com/eduardomv72/DebLiveConf/main/bootstrap.sh | sudo bash

Con secretos cifrados (wifi, clave SSH):

    curl -fsSL https://raw.githubusercontent.com/eduardomv72/DebLiveConf/main/bootstrap.sh | sudo bash -s -- --ask-vault-pass

Después, para reaplicar o probar partes:

    sync-config --tags gnome
    sync-config --check --diff

## Qué toca cada rol

`local-emv.yml` (el playbook que se ejecuta):

| Rol | Hace |
|---|---|
| preflight | Comprueba Debian, detecta usuario y live, actualiza apt (siempre se ejecuta) |
| packages | Elimina e instala paquetes (con lista de protegidos) |
| live_ram | Libera RAM: para servicios, oculta autoarranques, vacía la copia de la ISO si se arrancó con `toram` |
| localization | Zona horaria, locales, teclado, hostname |
| gnome | Ajustes de GNOME vía dconf (`gnome_settings`, valores por defecto del sistema) |
| google_chrome, vscode, claude_code, claude_desktop | Apps (tag `apps`; se desactivan con `install_<app>: false`) |
| user_env | .bashrc, vim, tmux, git, clave SSH, script sync-config |

Comentados en `local-emv.yml` (se activan quitando el `#`): `network` (NetworkManager,
región wifi, redes wifi del vault) y `hardware` (herramientas de invitado si es una VM).

## Personalizar

Todo se controla desde `group_vars/all/main.yml`. Los secretos van en `group_vars/all/vault.yml`
(cifrado con `ansible-vault`, ver `vault.yml.example`). Nunca subas secretos sin cifrar.

## Antes de usarlo

1. Revisa `packages_remove` con `apt-get -s remove <paquete>` (el playbook también lo simula
   y se detiene si la eliminación arrastra algún paquete de `packages_protected`).
2. El playbook que se ejecuta es `local-emv.yml` (variable `repo_playbook` en
   `group_vars/all/main.yml`; en `bootstrap.sh`, variable de entorno `PLAYBOOK`).
3. Prueba primero en una VM con Debian 13 + GNOME.
4. Para probar cambios sin subirlos: `sudo ansible-playbook local-emv.yml --check --diff`
   (`sync-config` descarga de GitHub, así que solo ve lo que está subido).
