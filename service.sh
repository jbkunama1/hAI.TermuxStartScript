#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
# hAI.TermuxStartScript — Termux Service Manager TUI
# Template Version — adapt CONFIG section to your needs
# ============================================================

# ==================== CONFIG ====================
# Cloudflared
TOKEN_FILE="$HOME/.config/my-services/cloudflared.token"

# Apps — replace with your own commands
# Format: CMD_APP_XX="your command here"
CMD_APP_1="echo 'Platzhalter App 1 — hier eigenen Befehl eintragen'"
CMD_APP_2="echo 'Platzhalter App 2 — hier eigenen Befehl eintragen'"
CMD_APP_3="echo 'Platzhalter App 3 — hier eigenen Befehl eintragen'"
CMD_APP_4="echo 'Platzhalter App 4 — hier eigenen Befehl eintragen'"
CMD_APP_5="echo 'Platzhalter App 5 — hier eigenen Befehl eintragen'"

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
    app1)
      dialog --msgbox "App 1:\nPlatzhalter — hier eigene Beschreibung eintragen." 8 68
      ;;
    app2)
      dialog --msgbox "App 2:\nPlatzhalter — hier eigene Beschreibung eintragen." 8 68
      ;;
    app3)
      dialog --msgbox "App 3:\nPlatzhalter — hier eigene Beschreibung eintragen." 8 68
      ;;
    app4)
      dialog --msgbox "App 4:\nPlatzhalter — hier eigene Beschreibung eintragen." 8 68
      ;;
    app5)
      dialog --msgbox "App 5:\nPlatzhalter — hier eigene Beschreibung eintragen." 8 68
      ;;
    app6)
      dialog --msgbox "App 6 (nur Info):\nPlatzhalter — hier eigene Beschreibung eintragen." 8 68
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

category_1_menu() {
  while true; do
    CHOICE=$(dialog --clear \
      --backtitle "Termux Services" \
      --title "Kategorie 1" \
      --menu "Apps auswählen:" 20 90 10 \
      1 "App 1 - kurze Beschreibung" \
      2 "App 2 - kurze Beschreibung" \
      3 "Zurück" \
      2>&1 >/dev/tty)

    clear

    case "$CHOICE" in
      1)
        app_menu "app1" "App 1" "$CMD_APP_1"
        ;;
      2)
        app_menu "app2" "App 2" "$CMD_APP_2"
        ;;
      3|*)
        break
        ;;
    esac
  done
}

category_2_menu() {
  while true; do
    CHOICE=$(dialog --clear \
      --backtitle "Termux Services" \
      --title "Kategorie 2" \
      --menu "Apps auswählen:" 16 90 8 \
      1 "App 3 - kurze Beschreibung" \
      2 "Zurück" \
      2>&1 >/dev/tty)

    clear

    case "$CHOICE" in
      1)
        app_menu "app3" "App 3" "$CMD_APP_3"
        ;;
      2|*)
        break
        ;;
    esac
  done
}

category_3_menu() {
  while true; do
    CHOICE=$(dialog --clear \
      --backtitle "Termux Services" \
      --title "Kategorie 3" \
      --menu "Apps auswählen:" 16 90 8 \
      1 "App 4 - kurze Beschreibung" \
      2 "App 5 - kurze Beschreibung" \
      3 "Zurück" \
      2>&1 >/dev/tty)

    clear

    case "$CHOICE" in
      1)
        app_menu "app4" "App 4" "$CMD_APP_4"
        ;;
      2)
        app_menu "app5" "App 5" "$CMD_APP_5"
        ;;
      3|*)
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
      1 "App 6 (nur Info) - kurze Beschreibung" \
      2 "Lokales Script starten - Platzhalter für eigenes Script" \
      3 "Zurück" \
      2>&1 >/dev/tty)

    clear

    case "$CHOICE" in
      1)
        show_app_info "app6"
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
      1 "Kategorie 1 - kurze Beschreibung" \
      2 "Kategorie 2 - kurze Beschreibung" \
      3 "Kategorie 3 - kurze Beschreibung" \
      4 "Hinweise        - Infotexte und Platzhalter" \
      5 "Zurück" \
      2>&1 >/dev/tty)

    clear

    case "$APP_CHOICE" in
      1)
        category_1_menu
        ;;
      2)
        category_2_menu
        ;;
      3)
        category_3_menu
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
