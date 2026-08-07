# hAI.TermuxStartScript

<a href="https://www.buymeacoffee.com/highfish">
<img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="41" width="174">
</a>

![Bash](https://img.shields.io/badge/Bash-4EAA25?style=flat-square&logo=gnubash&logoColor=white)
![Termux](https://img.shields.io/badge/Termux-000000?style=flat-square&logo=android&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-blue?style=flat-square)
![Platform](https://img.shields.io/badge/Platform-Android-green?style=flat-square)
![dialog](https://img.shields.io/badge/TUI-dialog-blueviolet?style=flat-square)
![Cloudflare](https://img.shields.io/badge/Tunnel-Cloudflare-F38020?style=flat-square&logo=cloudflare&logoColor=white)

A configurable TUI (Terminal User Interface) start script for **Termux** that manages SSH, Cloudflare Tunnels, and custom apps — all from a single `dialog`-based menu.

## Features

- **Service Management**: Start, stop, restart SSH and Cloudflared via `termux-services` (`sv`)
- **Token Handling**: Paste Cloudflared tokens directly in the terminal (no `dialog` inputbox issues)
- **Status Overview**: Real-time status for SSH, Cloudflared, and token storage
- **Apps Menu**: Structured, categorised access to your own apps — fully placeholder-based
- **Template-Ready**: Config block at the top — just edit paths and commands for your installation
- **Config Wizard**: Interactive web-based assistant to configure and download your script
- **Boot Support**: Works with `Termux:Boot` for auto-start on device boot

## Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/YOUR_USERNAME/hAI.TermuxStartScript.git
cd hAI.TermuxStartScript

# 2. Copy script to home
cp service.sh ~/service.sh
chmod +x ~/service.sh

# 3. Edit CONFIG section — adjust paths to your apps
nano ~/service.sh

# 4. Run
~/service.sh
```

## Configuration

Edit the **CONFIG** block at the top of `service.sh`:

```bash
# ==================== CONFIG ====================
TOKEN_FILE="$HOME/.config/my-services/cloudflared.token"

# Apps — replace with your own commands
CMD_APP_1="your-command-here"
CMD_APP_2="your-command-here"
CMD_APP_3="your-command-here"
CMD_APP_4="your-command-here"
CMD_APP_5="your-command-here"

SERVICE_SSHD="sshd"
SERVICE_CLOUDFLARED="cloudflared"
# ================ END CONFIG ====================
```

Also adjust the menu labels and descriptions in the category functions (e.g. `category_1_menu`, `category_2_menu`) to match your apps.

## Config Wizard

Visit the [GitHub Pages site](https://YOUR_USERNAME.github.io/hAI.TermuxStartScript/) to use the interactive configuration assistant:

1. Enter your general settings (token file path, service names)
2. Toggle apps on/off and enter their launch commands
3. Add short descriptions for each app
4. Generate and download a ready-to-use `service.sh`

The wizard runs entirely in your browser — no data is sent anywhere.

## Menu Structure

```
SSH + Cloudflared (Main Menu)
├── Status anzeigen
├── SSH starten / stoppen
├── Cloudflared starten / stoppen / restart
├── Cloudflared-Token eingeben / Status
├── Alles starten
├── Apps
│   ├── Kategorie 1
│   │   ├── App 1 — kurze Beschreibung
│   │   └── App 2 — kurze Beschreibung
│   ├── Kategorie 2
│   │   └── App 3 — kurze Beschreibung
│   ├── Kategorie 3
│   │   ├── App 4 — kurze Beschreibung
│   │   └── App 5 — kurze Beschreibung
│   └── Hinweise
│       ├── App 6 (nur Info)
│       └── Lokales Script starten (Platzhalter)
└── Beenden
```

## Prerequisites

```bash
pkg install dialog termux-services openssh cloudflared
sv-enable sshd
sv-enable cloudflared
```

## Boot Auto-Start (optional)

Create `~/.termux/boot/start-services`:

```bash
#!/data/data/com.termux/files/usr/bin/sh
termux-wake-lock
. "$PREFIX/etc/profile"
exec runsvdir -P "$PREFIX/var/service"
```

Make sure to:
- Install and open **Termux:Boot** once
- Disable battery optimization for Termux and Termux:Boot

## License

MIT

