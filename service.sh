#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
# hAI.TermuxStartScript — Termux Service Manager TUI
# Template Version — adapt CONFIG section to your needs
# ============================================================

# ==================== CONFIG ====================
# Cloudflared
TOKEN_FILE="$HOME/.config/my-services/cloudflared.token"

# OSINT Tools — adjust paths/commands to your installation
CMD_INFOOOZE="/data/data/com.termux/files/usr/bin/infoooze"
CMD_MRHOLMES="cd $HOME/Mr.Holmes && python3 MrHolmes.py"
CMD_RECONDOG="cd $HOME/ReconDog && python dog"

# Frameworks
CMD_METASPLOIT="msfconsole"

# Tool-Sammlungen
CMD_DARKFLY="/data/data/com.termux/files/usr/bin/DarkFly"

# Services (termux-services)
SERVICE_SSHD="sshd"
SERVICE_CLOUDFLARED="cloudflared"
# ================ END CONFIG ====================

export SVDIR="$PREFIX/var/service"
mkdir -p "$HOME/.config/my-services"

# ==================== FUNCTIONS ====================
ssh_running_any() {
  pgrep -x sshd >/dev/null 2>&1
}

port_8022_in_use() {
  pgrep -x sshd >/dev/null 2>&1
}

cloudflared_token_set() {
  [ -f "$TOKEN_FILE" ] && [ -s "$TOKEN_FILE" ]
}

show_status() {
  local ssh_status cf_status token_status port_status

  if ssh_running_any; then
    ssh_status="läuft"
    port_status="ja"
  else
    ssh_status="gestoppt"
    port_status="nein/unbekannt"
  fi

  cf_status="$(sv status "$SERVICE_CLOUDFLARED" 2>&1)"

  if cloudflared_token_set; then
    token_status="gespeichert"
  else
    token_status="nicht gesetzt"
  fi

  cat <<STATUS
SSH: $ssh_status
Port 8022 belegt/vermutet: $port_status

Cloudflared: $cf_status
Cloudflared-Token: $token_status
STATUS
}

set_token_terminal() {
  clear
  echo "Cloudflared-Token eingeben"
  echo "----------------------------------------"
  echo "Hier kannst du normal im Terminal einfügen."
  echo ""
  printf "Token: "
  IFS= read -r token

  if [ -n "$token" ]; then
    printf "%s" "$token" > "$TOKEN_FILE"
    chmod 600 "$TOKEN_FILE"
    dialog --msgbox "Token gespeichert." 6 30
  else
    dialog --msgbox "Leerer Token wurde nicht gespeichert." 6 45
  fi
}

show_token_info() {
  if cloudflared_token_set; then
    dialog --msgbox "Cloudflared-Token ist gespeichert." 6 40
  else
    dialog --msgbox "Cloudflared-Token ist nicht gesetzt." 6 40
  fi
}

start_ssh_safe() {
  if ssh_running_any || port_8022_in_use; then
    dialog --msgbox "SSH läuft bereits oder Port 8022 ist belegt.\nEs wird nichts geändert." 8 55
    return
  fi

  sv up "$SERVICE_SSHD"
  sleep 1
  dialog --msgbox "$(sv status "$SERVICE_SSHD" 2>&1)" 8 60
}

start_cloudflared() {
  if ! cloudflared_token_set; then
    dialog --msgbox "Kein Cloudflared-Token gesetzt." 6 40
    return
  fi

  sv up "$SERVICE_CLOUDFLARED"
  sleep 1
  dialog --msgbox "$(sv status "$SERVICE_CLOUDFLARED" 2>&1)" 8 60
}

stop_cloudflared() {
  sv down "$SERVICE_CLOUDFLARED"
  sleep 1
  dialog --msgbox "$(sv status "$SERVICE_CLOUDFLARED" 2>&1)" 8 60
}

restart_cloudflared() {
  if ! cloudflared_token_set; then
    dialog --msgbox "Kein Cloudflared-Token gesetzt." 6 40
    return
  fi

  sv restart "$SERVICE_CLOUDFLARED"
  sleep 1
  dialog --msgbox "$(sv status "$SERVICE_CLOUDFLARED" 2>&1)" 8 60
}

start_all_safe() {
  if ! ssh_running_any && ! port_8022_in_use; then
    sv up "$SERVICE_SSHD"
  fi

  if cloudflared_token_set; then
    sv up "$SERVICE_CLOUDFLARED"
  fi

  sleep 1
  dialog --msgbox "$(show_status)" 14 65
}

run_in_terminal() {
  local title="$1"
  local cmd="$2"
  clear
  echo "$title"
  echo "----------------------------------------"
  echo "Befehl: $cmd"
  echo ""
  eval "$cmd"
  echo ""
  read -p "Enter drücken für Rückkehr ins Menü..."
}

show_app_info() {
  case "$1" in
    darkfly)
      dialog --msgbox "DarkFly:\nTool-Sammlung bzw. Installer, der viele Security- und Utility-Tools über ein zentrales Menü zugänglich macht." 8 70
      ;;
    infoooze)
      dialog --msgbox "Infoooze:\nBenutzerfreundliches OSINT-Tool für Informationen zu Websites, IP-Adressen, Usernames, DNS, Headern, EXIF und weiteren offenen Quellen." 9 72
      ;;
    mrholmes)
      dialog --msgbox "Mr.Holmes:\nOSINT-/Information-Gathering-Tool für Domains, Usernames und Telefonnummern aus öffentlichen Quellen." 8 70
      ;;
    metasploit)
      dialog --msgbox "Metasploit:\nModulares Penetration-Testing-Framework von Rapid7 für autorisierte Sicherheitsanalysen, Assessments und Modultests." 8 72
      ;;
    recondog)
      dialog --msgbox "ReconDog:\nRecon-/Information-Gathering-Tool ('Reconnaissance Swiss Army Knife') für verschiedene Abfragen und Analysen." 8 72
      ;;
    zphisher)
      dialog --msgbox "Zphisher:\nPhishing-Toolkit. Es wird hier nur als Hinweis geführt und nicht startbar eingebunden." 8 68
      ;;
    localscript)
      dialog --msgbox "Lokales Script starten:\nPlatzhalter für ein eigenes, harmloses lokales Skript oder Utility." 8 68
      ;;
  esac
}

run_local_script() {
  clear
  echo "Lokales Script starten"
  echo "----------------------------------------"
  echo "Bitte trage hier später ein eigenes harmloses Script ein."
  echo ""
  read -p "Enter drücken für Rückkehr ins Menü..."
}

app_menu() {
  local app="$1"
  local title="$2"
  local cmd="$3"

  while true; do
    APP_ACTION=$(dialog --clear \
      --backtitle "Termux Services" \
      --title "$title" \
      --menu "Bitte wählen:" 16 68 8 \
      1 "Info anzeigen" \
      2 "Starten" \
      3 "Neustarten" \
      4 "Zurück" \
      2>&1 >/dev/tty)

    clear

    case "$APP_ACTION" in
      1)
        show_app_info "$app"
        ;;
      2)
        run_in_terminal "$title starten" "$cmd"
        ;;
      3)
        run_in_terminal "$title neu starten" "$cmd"
        ;;
      4|*)
        break
        ;;
    esac
  done
}

osint_menu() {
  while true; do
    CHOICE=$(dialog --clear \
      --backtitle "Termux Services" \
      --title "OSINT" \
      --menu "OSINT-Tools auswählen:" 20 90 10 \
      1 "Infoooze  - OSINT für Domains, IPs, Usernames, DNS und Webinfos" \
      2 "Mr.Holmes - OSINT für Domains, Usernames und Telefonnummern" \
      3 "ReconDog  - Recon für DNS, Ports, CMS, Subdomains und Whois" \
      4 "Zurück" \
      2>&1 >/dev/tty)

    clear

    case "$CHOICE" in
      1)
        app_menu "infoooze" "Infoooze" "$CMD_INFOOOZE"
        ;;
      2)
        app_menu "mrholmes" "Mr.Holmes" "$CMD_MRHOLMES"
        ;;
      3)
        app_menu "recondog" "ReconDog" "$CMD_RECONDOG"
        ;;
      4|*)
        break
        ;;
    esac
  done
}

frameworks_menu() {
  while true; do
    CHOICE=$(dialog --clear \
      --backtitle "Termux Services" \
      --title "Frameworks" \
      --menu "Framework auswählen:" 16 90 8 \
      1 "Metasploit - modulares Pentest-Framework für Assessments und Tests" \
      2 "Zurück" \
      2>&1 >/dev/tty)

    clear

    case "$CHOICE" in
      1)
        app_menu "metasploit" "Metasploit" "$CMD_METASPLOIT"
        ;;
      2|*)
        break
        ;;
    esac
  done
}

toolsets_menu() {
  while true; do
    CHOICE=$(dialog --clear \
      --backtitle "Termux Services" \
      --title "Tool-Sammlungen" \
      --menu "Sammlung auswählen:" 16 90 8 \
      1 "DarkFly - Launcher/Installer für viele Security- und Utility-Tools" \
      2 "Zurück" \
      2>&1 >/dev/tty)

    clear

    case "$CHOICE" in
      1)
        app_menu "darkfly" "DarkFly" "$CMD_DARKFLY"
        ;;
      2|*)
        break
        ;;
    esac
  done
}

notes_menu() {
  while true; do
    CHOICE=$(dialog --clear \
      --backtitle "Termux Services" \
      --title "Hinweise" \
      --menu "Hinweis auswählen:" 16 90 8 \
      1 "Zphisher - nur Hinweistext, nicht startbar eingebunden" \
      2 "Lokales Script starten - Platzhalter für eigenes harmloses Script" \
      3 "Zurück" \
      2>&1 >/dev/tty)

    clear

    case "$CHOICE" in
      1)
        show_app_info "zphisher"
        ;;
      2)
        show_app_info "localscript"
        run_local_script
        ;;
      3|*)
        break
        ;;
    esac
  done
}

apps_menu() {
  while true; do
    APP_CHOICE=$(dialog --clear \
      --backtitle "Termux Services" \
      --title "Apps" \
      --menu "Bereich auswählen:" 18 90 10 \
      1 "OSINT           - Informationssammlung und Recon" \
      2 "Frameworks      - Sicherheits-Frameworks" \
      3 "Tool-Sammlungen - Launcher und Installer" \
      4 "Hinweise        - Infotexte und Platzhalter" \
      5 "Zurück" \
      2>&1 >/dev/tty)

    clear

    case "$APP_CHOICE" in
      1)
        osint_menu
        ;;
      2)
        frameworks_menu
        ;;
      3)
        toolsets_menu
        ;;
      4)
        notes_menu
        ;;
      5|*)
        break
        ;;
    esac
  done
}

# ==================== MAIN MENU ====================
while true; do
  CHOICE=$(dialog --clear \
    --backtitle "Termux Services" \
    --title "SSH + Cloudflared" \
    --menu "Bitte wählen:" 20 75 12 \
    1 "Status anzeigen" \
    2 "SSH starten (nur wenn Port frei)" \
    3 "SSH stoppen (gesperrt)" \
    4 "Cloudflared starten" \
    5 "Cloudflared stoppen" \
    6 "Cloudflared neu starten" \
    7 "Cloudflared-Token eingeben (Terminal-Paste)" \
    8 "Cloudflared-Token Status" \
    9 "Alles starten" \
    10 "Apps" \
    11 "Beenden" \
    2>&1 >/dev/tty)

  clear

  case "$CHOICE" in
    1)
      dialog --msgbox "$(show_status)" 14 65
      ;;
    2)
      start_ssh_safe
      ;;
    3)
      dialog --msgbox "SSH-Stopp ist aktuell gesperrt,\ndamit du deine aktive SSH-Verbindung nicht verlierst." 8 55
      ;;
    4)
      start_cloudflared
      ;;
    5)
      stop_cloudflared
      ;;
    6)
      restart_cloudflared
      ;;
    7)
      set_token_terminal
      ;;
    8)
      show_token_info
      ;;
    9)
      start_all_safe
      ;;
    10)
      apps_menu
      ;;
    11|*)
      clear
      exit 0
      ;;
  esac
done
