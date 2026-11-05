# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Qué es

Configuración Ansible que deja un Debian 13 Live (GNOME) siempre igual. No hay hosts remotos (`inventory.ini` solo define `localhost` con conexión local): se aplica sobre la propia máquina con `ansible-pull` (conexión local, `become: true`). La documentación y los nombres de tareas están en español; mantén ese idioma.

Flujo real de uso:

1. `bootstrap.sh` (vía `curl … | sudo bash`) instala `ansible` y `git` y lanza `ansible-pull` contra este repo (variables de entorno `REPO_URL`, `BRANCH`, `PLAYBOOK`; los argumentos extra pasan a `ansible-pull`).
2. `ansible-pull` clona en `/var/lib/ansible-pull` y ejecuta el playbook, por defecto `local-emv.yml`.
3. El rol `user_env` instala el script `sync-config` (plantilla `roles/user_env/templates/sync-config.j2`) para reaplicar después, usando `repo_url`/`repo_branch`/`repo_playbook` de `group_vars/all/main.yml`.

Como `ansible-pull` descarga de GitHub, **los cambios locales no se aplican con `sync-config` hasta hacer push**. Para probar en local usa `ansible-playbook` directamente.

## Comandos

```bash
# Comprobar sintaxis (no hay tests ni linter configurados)
ansible-playbook --syntax-check local-emv.yml

# Simulación sobre la máquina local con el repo local (sin pasar por GitHub)
sudo ansible-playbook local-emv.yml --check --diff

# Aplicar solo un rol / grupo de roles mediante tags
sudo ansible-playbook local-emv.yml --tags gnome
sudo ansible-playbook local-emv.yml --tags apps   # google_chrome, vscode, claude_code, claude_desktop

# Con secretos del vault
sudo ansible-playbook local-emv.yml --ask-vault-pass

# En el live, reaplicando desde GitHub
sync-config --tags gnome
sync-config --check --diff
```

Probar siempre primero en una VM Debian 13 + GNOME; revisar eliminaciones con `sudo apt -s remove <paquete>`.

## Arquitectura

- **Playbooks**: `local-emv.yml` es el que se ejecuta (lo fijan `bootstrap.sh` y `repo_playbook`). Es el único playbook de roles; `network` y `hardware` están comentados en él. `VerySimplePlaybook.yml` es un ejemplo mínimo.
- **`preflight` siempre corre** (tag `always`): verifica Debian, hace `apt update` y fija los facts `live_uid`, `live_gid`, `live_home` (vía `getent` sobre `live_user`) e `is_live` (existe `/run/live/medium`). Los demás roles dependen de esos facts; cualquier rol que toque el home del usuario debe usarlos para owner/group y para `become_user`.
- **Configuración central**: `group_vars/all/main.yml` controla casi todo (paquetes, localización, ajustes de GNOME, flags `install_*`). Los secretos (`wifi_networks`, `ssh_private_key`) van en `group_vars/all/vault.yml` cifrado con `ansible-vault` (plantilla en `vault.yml.example`; nunca subir `vault.yml` sin cifrar). Los valores por defecto de cada rol están en `roles/<rol>/defaults/main.yml`, que `group_vars` sobrescribe.
- **Roles de apps** (`google_chrome`, `vscode`, `claude_code`, `claude_desktop`): se activan con `install_<app>` (condición `when` en el playbook) y comparten el tag `apps`. `claude_code` admite `claude_code_method: apt` (repo apt firmado, verifica la huella de la clave antes de añadirlo) o `native` (instalador oficial como el usuario).
- **`gnome`**: escribe `gnome_settings` (formato GVariant, igual que `dconf dump`) en la base de sistema `/etc/dconf/db/local.d/00-live-defaults` y ejecuta `dconf update`; no necesita sesión gráfica. Son valores por defecto: lo que el usuario cambie a mano en GNOME manda, salvo en las claves de `gnome_reset_user_keys`, donde el rol borra el valor del usuario (solo con sesión abierta, vía su bus de D-Bus). El live fija sus propias fuentes de entrada en la base del usuario, por eso el teclado está ahí. Las extensiones (Dash to Dock, AppIndicator) se instalan desde `packages_install_optional` y se activan con `enabled-extensions` en `gnome_settings`.
- **`user_env`**: instala `/usr/local/bin/sync-config`, añade un bloque marcado a `~/.bashrc` y copia `.vimrc`/`.tmux.conf`. Si `git_user_name` no está vacío, fija `user.name`/`user.email`/`init.defaultBranch`/`pull.rebase` clave a clave con `community.general.git_config`, sin tocar el resto de `~/.gitconfig` (p. ej. el credential helper de `gh auth setup-git`).
- **`packages`**: aborta si `packages_remove` intersecta `packages_protected` (defaults del rol) y, además, simula la eliminación con `apt-get -s remove` (con los mismos `--purge`/`--autoremove`) y aborta si lo que se eliminaría de verdad, comodines y dependencias incluidos, contiene algún paquete protegido o si apt no puede simularla (p. ej. un nombre mal escrito). Ojo: `evolution*` incluye `evolution-data-server`, del que dependen `gnome-shell` y `gdm3`; `packages_install_optional` se instala uno a uno con `ignore_errors` y solo avisa; limpia la caché de apt al final (en un live ocupa RAM).
- **`live_ram`**: libera memoria en el live: enmascara unidades systemd (solo las que existen), oculta autostarts y enmascara unidades `--user` creando enlaces a `/dev/null` en el home, y si se arrancó con `toram` (`/run/live/medium` en tmpfs) borra contenido innecesario de la copia de la ISO, remontando rw y volviendo a ro en `always`.

## Convenciones

- Módulos con FQCN (`ansible.builtin.*`, `community.general.*`); nombres de tareas en español.
- Variables con prefijo del rol (`live_ram_*`, `packages_*`, `claude_code_*`).
- Tareas `command` de solo lectura llevan `changed_when: false` y, si deben correr en `--check`, `check_mode: false`.
- Al añadir un rol: crearlo en `roles/`, añadirlo a `local-emv.yml` con su tag (y `when: install_x | default(true)` si es opcional) y documentarlo en la tabla de `README.md`.
