# Configuración Ansible: hora y teclado

Dos roles para Debian:

- `timesync`: zona horaria (Europe/Madrid) y sincronización automática de la
  hora con systemd-timesyncd.
- `keyboard`: teclado en español en la consola y en el escritorio GNOME.

## Uso

    cd ansible-sistema
    ansible-playbook -i inventory.ini site.yml

Si sudo pide contraseña, añade `-K`.

Requiere la colección `community.general` (incluida con el paquete `ansible`).

## Variables de `timesync` (roles/timesync/defaults/main.yml)

| Variable | Por defecto | Descripción |
|---|---|---|
| `timesync_timezone` | `Europe/Madrid` | Zona horaria |
| `timesync_ntp_servers` | `*.es.pool.ntp.org` | Servidores NTP |
| `timesync_fallback_servers` | `*.debian.pool.ntp.org` | Servidores de respaldo |
| `timesync_rtc_local` | `false` | `true` = reloj del hardware en hora local (evita el desfase con Windows) |

## Variables de `keyboard` (roles/keyboard/defaults/main.yml)

| Variable | Por defecto | Descripción |
|---|---|---|
| `keyboard_layout` | `es` | Distribución del teclado |
| `keyboard_variant` | `""` | Variante (p. ej. `cat` para catalán) |
| `keyboard_model` | `pc105` | Modelo de teclado |
| `keyboard_options` | `""` | Opciones XKB (p. ej. `caps:escape`) |
| `keyboard_desktop_user` | usuario actual | Usuario GNOME a configurar |
| `keyboard_extra_layouts` | `[us]` | Distribuciones adicionales, disponibles pero no activas |
| `keyboard_gnome_sources` | `[('xkb', 'es'), ('xkb', 'us')]` | Fuentes de entrada de GNOME, en orden (la primera es la activa) |
