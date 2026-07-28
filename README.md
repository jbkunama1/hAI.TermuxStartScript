# hAI.TermuxStartScript

![Bash](https://img.shields.io/badge/Bash-4EAA25?style=flat-square&logo=gnubash&logoColor=white)
![Termux](https://img.shields.io/badge/Termux-000000?style=flat-square&logo=android&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-blue?style=flat-square)
![Platform](https://img.shields.io/badge/Platform-Android-green?style=flat-square)
![dialog](https://img.shields.io/badge/TUI-dialog-blueviolet?style=flat-square)
![Cloudflare](https://img.shields.io/badge/Tunnel-Cloudflare-F38020?style=flat-square&logo=cloudflare&logoColor=white)

A configurable TUI (Terminal User Interface) start script for **Termux** that manages SSH, Cloudflare Tunnels, and security/OSINT tools — all from a single `dialog`-based menu.

## Features

- **Service Management**: Start, stop, restart SSH and Cloudflared via `termux-services` (`sv`)
- **Token Handling**: Paste Cloudflared tokens directly in the terminal (no `dialog` inputbox issues)
- **Status Overview**: Real-time status for SSH, Cloudflared, and token storage
- **Apps Menu**: Structured access to OSINT, Recon, and Pentest tools
- **Template-Ready**: Config block at the top — just edit paths and commands for your installation
- **Boot Support**: Works with `Termux:Boot` for auto-start on device boot

## Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/YOUR_USERNAME/hAI.TermuxStartScript.git
cd hAI.TermuxStartScript

# 2. Copy script to home
cp service.sh ~/service.sh
chmod +x ~/service.sh

# 3. Edit CONFIG section — adjust paths to your tools
nano ~/service.sh

# 4. Run
~/service.sh
```

## Configuration

Edit the **CONFIG** block at the top of `service.sh`:

```bash
# ==================== CONFIG ====================
TOKEN_FILE="$HOME/.config/my-services/cloudflared.token"

CMD_INFOOOZE="/data/data/com.termux/files/usr/bin/infoooze"
CMD_MRHOLMES="cd $HOME/Mr.Holmes && python3 MrHolmes.py"
CMD_RECONDOG="cd $HOME/ReconDog && python dog"
CMD_METASPLOIT="msfconsole"
CMD_DARKFLY="/data/data/com.termux/files/usr/bin/DarkFly"

SERVICE_SSHD="sshd"
SERVICE_CLOUDFLARED="cloudflared"
# ================ END CONFIG ====================
```

## Menu Structure

```
SSH + Cloudflared (Main Menu)
├── Status anzeigen
├── SSH starten / stoppen
├── Cloudflared starten / stoppen / restart
├── Cloudflared-Token eingeben / Status
├── Alles starten
├── Apps
│   ├── OSINT
│   │   ├── Infoooze  — OSINT für Domains, IPs, Usernames, DNS
│   │   ├── Mr.Holmes — OSINT für Domains, Usernames, Telefonnummern
│   │   └── ReconDog  — Recon für DNS, Ports, CMS, Subdomains
│   ├── Frameworks
│   │   └── Metasploit — modulares Pentest-Framework
│   ├── Tool-Sammlungen
│   │   └── DarkFly — Launcher/Installer für Security-Tools
│   └── Hinweise
│       ├── Zphisher (nur Info, nicht startbar)
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

## Tools Overview

| Tool | Category | Description |
|---|---|---|
| Infoooze | OSINT | Information gathering on domains, IPs, usernames, DNS, headers, EXIF |
| Mr.Holmes | OSINT | Recon on domains, usernames, phone numbers from public sources |
| ReconDog | Recon | All-in-one reconnaissance toolkit (DNS, ports, CMS, subdomains, Whois) |
| Metasploit | Framework | Modular penetration testing framework by Rapid7 |
| DarkFly | Tool-Sammlung | Installer/launcher for hundreds of security and utility tools |
| Zphisher | Hinweis | Phishing toolkit — info only, not startable |

## License

MIT
