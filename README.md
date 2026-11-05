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

Solo en `local.yml`: `network` (NetworkManager, región wifi, redes del vault) y
`hardware` (ajustes según hardware/VM). Sin usar: `timesync` y `keyboard`
(los cubre `localization`; ver sus variables al final).

## Personalizar

Todo se controla desde `group_vars/all/main.yml`. Los secretos van en `group_vars/all/vault.yml`
(cifrado con `ansible-vault`, ver `vault.yml.example`). Nunca subas secretos sin cifrar.

## Antes de usarlo

1. Revisa `packages_remove` con `sudo apt -s remove <paquete>`.
2. El playbook que se ejecuta es `local-emv.yml` (variable `repo_playbook` en
   `group_vars/all/main.yml`; en `bootstrap.sh`, variable de entorno `PLAYBOOK`).
3. Prueba primero en una VM con Debian 13 + GNOME.
4. Para probar cambios sin subirlos: `sudo ansible-playbook local-emv.yml --check --diff`
   (`sync-config` descarga de GitHub, así que solo ve lo que está subido).

## Roles sin usar: `timesync` y `keyboard`

Se pueden añadir a un playbook si se prefieren a `localization`.

- `timesync`: zona horaria y sincronización automática de la hora con systemd-timesyncd.
- `keyboard`: teclado en la consola y en el escritorio GNOME.

Requieren la colección `community.general` (incluida con el paquete `ansible`).

### Variables de `timesync` (roles/timesync/defaults/main.yml)

| Variable | Por defecto | Descripción |
|---|---|---|
| `timesync_timezone` | `Europe/Madrid` | Zona horaria |
| `timesync_ntp_servers` | `*.es.pool.ntp.org` | Servidores NTP |
| `timesync_fallback_servers` | `*.debian.pool.ntp.org` | Servidores de respaldo |
| `timesync_rtc_local` | `false` | `true` = reloj del hardware en hora local (evita el desfase con Windows) |

### Variables de `keyboard` (roles/keyboard/defaults/main.yml)

| Variable | Por defecto | Descripción |
|---|---|---|
| `keyboard_layout` | `es` | Distribución del teclado |
| `keyboard_variant` | `""` | Variante (p. ej. `cat` para catalán) |
| `keyboard_model` | `pc105` | Modelo de teclado |
| `keyboard_options` | `""` | Opciones XKB (p. ej. `caps:escape`) |
| `keyboard_desktop_user` | usuario actual | Usuario GNOME a configurar |
| `keyboard_extra_layouts` | `[us]` | Distribuciones adicionales, disponibles pero no activas |
| `keyboard_gnome_sources` | `[('xkb', 'es'), ('xkb', 'us')]` | Fuentes de entrada de GNOME, en orden (la primera es la activa) |
