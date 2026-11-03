# Cómo integrar los cuatro roles en tu repo

1. Copia la carpeta `roles/` dentro de tu repo (se mezcla con tus roles existentes).

2. En `local.yml`, añade estas líneas dentro de `roles:` (después de `hardware` y antes de `gnome`):

```yaml
    - { role: google_chrome,  tags: [apps, google_chrome],  when: install_google_chrome | default(true) }
    - { role: vscode,         tags: [apps, vscode],         when: install_vscode | default(true) }
    - { role: claude_code,    tags: [apps, claude_code],    when: install_claude_code | default(true) }
    - { role: claude_desktop, tags: [apps, claude_desktop], when: install_claude_desktop | default(true) }
```

3. (Opcional) En `group_vars/all/main.yml`, para activar/desactivar o personalizar. Todos tienen valores por defecto en cada rol:

```yaml
install_google_chrome: true
install_vscode: true
install_claude_code: true
install_claude_desktop: true

chrome_set_default: true
chrome_policies:
  MetricsReportingEnabled: false
  DefaultBrowserSettingEnabled: false
chrome_force_extensions: []        # IDs de la Chrome Web Store

vscode_extensions: [redhat.ansible, redhat.vscode-yaml, ms-python.python, anthropic.claude-code]
vscode_settings:
  editor.fontSize: 14
  files.autoSave: afterDelay
  telemetry.telemetryLevel: "off"

claude_code_method: apt            # o: native
```

4. (Opcional) Para que Chrome y VS Code aparezcan en el dock de GNOME, en `gnome_settings`:

```yaml
  org/gnome/shell:
    favorite-apps: "['org.gnome.Nautilus.desktop', 'google-chrome.desktop', 'code.desktop', 'org.gnome.Terminal.desktop']"
```

5. Ejecuta por partes: `sync-config --tags google_chrome`, `--tags vscode`, `--tags claude_code`, `--tags claude_desktop`, o todas con `--tags apps`.

Los roles dependen de las variables `live_user`, `live_home`, `live_uid` y `live_gid`, que fija el rol `preflight` (siempre se ejecuta, tiene el tag `always`).
