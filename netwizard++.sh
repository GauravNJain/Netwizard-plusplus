#!/usr/bin/env bash

# ===============================
#  NetWizard++ Pentest Toolkit
# ===============================

# -------- Colors --------
RED="\e[31m"; GREEN="\e[32m"; YELLOW="\e[33m"
BLUE="\e[34m"; MAGENTA="\e[35m"; CYAN="\e[36m"
BOLD="\e[1m"; RESET="\e[0m"

read -p "Enter the location you want to use as the 'Loot Directory' (this is where your network analysis information will be stored): " LOOT_DIR
#LOOT_DIR="./netwizard_loot"
mkdir -p "$LOOT_DIR"

# -------- Banner --------
banner() {
clear
echo -e "${CYAN}${BOLD}"
cat << "EOF"
 _   _      _   __        _                  _     ++
| \ | | ___| |_/ /_ _ __| |_ ___  _ __ ___  | |
|  \| |/ _ \ __| | '__| | __/ _ \| '__/ _ \ | |
| |\  |  __/ |_| | |  | | || (_) | | |  __/ |_|
|_| \_|\___|\__| |_|  |_|\__\___/|_|  \___| (_)

     NetWizard++  |  Pentest Networking Toolkit
EOF
echo -e "${RESET}"
}

pause() { read -rp "Press Enter to continue..."; }

# -------- IP Helpers --------
ip2dec(){ IFS=. read -r a b c d <<< "$1"; echo "$((a<<24|b<<16|c<<8|d))"; }
dec2ip(){ echo "$(( $1>>24&255 )).$(( $1>>16&255 )).$(( $1>>8&255 )).$(( $1&255 ))"; }

# -------- Network Calculator --------
calculate_network() {
  read -rp "IP Address: " IP
  read -rp "CIDR (e.g. 24): " CIDR

  IPD=$(ip2dec "$IP")
  MASK=$((0xffffffff << (32-CIDR) & 0xffffffff))
  NET=$((IPD & MASK))
  BCAST=$((NET | ~MASK & 0xffffffff))

  echo -e "\n${GREEN}${BOLD}Subnet Info${RESET}"
  echo -e "${BLUE}-----------------------------${RESET}"
  printf "%-18s : %s\n" "Network ID" "$(dec2ip $NET)"
  printf "%-18s : %s\n" "Broadcast ID" "$(dec2ip $BCAST)"
  printf "%-18s : %s\n" "Subnet Mask" "$(dec2ip $MASK)"
  printf "%-18s : %s - %s\n" "Usable Range" \
    "$(dec2ip $((NET+1)))" "$(dec2ip $((BCAST-1)))"
  printf "%-18s : %s\n" "Usable Hosts" "$((2**(32-CIDR)-2))"
}

# -------- Pentest Host Discovery --------
discover_hosts() {
  read -rp "Target network (e.g. 192.168.1.0/24): " NET
  OUT="$LOOT_DIR/hosts_$(date +%F_%H%M).txt"

  echo -e "\n${YELLOW}[*] Scanning hosts...${RESET}"

  nmap -sn "$NET" -oG - | awk '/Up$/{print $2}' > "$OUT"

  echo -e "\n${CYAN}${BOLD}Live Hosts${RESET}"
  echo -e "${BLUE}------------------------${RESET}"
  column "$OUT"
}

# -------- Pretty Host Table --------
pretty_scan() {
  read -rp "Target network: " NET

  echo -e "\n${YELLOW}[*] Performing readable scan...${RESET}\n"

  echo -e "${CYAN}${BOLD}IP Address        Hostname              MAC Address         Vendor${RESET}"
  echo -e "${BLUE}-----------------------------------------------------------------------------${RESET}"

  nmap -sn "$NET" | awk '
  /^Nmap scan report for/ {
      ip=$NF; host="N/A"
      if ($5 != "for") host=$5
      print ip "|" host "|N/A|N/A"
  }
  /MAC Address:/ {
      mac=$3
      vendor=$4
      for (i=5;i<=NF;i++) vendor=vendor" "$i
      gsub(/[()]/,"",vendor)
      printf "%s|%s|%s|%s\n", ip, host, mac, vendor
  }' | column -t -s "|"
}

# -------- Network Map (ASCII + Graphviz) --------
network_map() {
  read -rp "Target network: " NET
  MAP="$LOOT_DIR/map_$(date +%F_%H%M)"

  echo -e "\n${YELLOW}[*] Building network map...${RESET}"

  nmap -sn "$NET" -oG - | awk '/Up$/{print $2}' > "$MAP.nodes"

  echo -e "\n${CYAN}${BOLD}ASCII MAP${RESET}"
  echo -e "${BLUE}----------------${RESET}"
  for h in $(cat "$MAP.nodes"); do
    echo -e "${GREEN}[+]${RESET} $h"
  done

  if command -v dot &>/dev/null; then
    {
      echo "graph network {"
      echo "  node [shape=box, style=filled, color=lightblue];"
      for h in $(cat "$MAP.nodes"); do
        echo "  \"$NET\" -- \"$h\";"
      done
      echo "}"
    } > "$MAP.dot"

    dot -Tpng "$MAP.dot" -o "$MAP.png"
    echo -e "\n${MAGENTA}[+] Graphviz map saved:${RESET} $MAP.png"
  else
    echo -e "${YELLOW}[!] graphviz not installed (ASCII only)${RESET}"
  fi
}

# -------- Pentest Enumeration --------
pentest_enum() {
  read -rp "Target IP: " TARGET
  OUT="$LOOT_DIR/pentest_$TARGET"

  echo -e "\n${RED}${BOLD}[!] Pentest Scan Started${RESET}"

  nmap -sS -sV -O -Pn "$TARGET" -oA "$OUT"

  echo -e "\n${GREEN}[+] Results saved to:${RESET} $OUT.*"
}

# -------- Device Change Detection --------
detect_new_devices() {
  read -rp "Target network: " NET
  BASE="$LOOT_DIR/baseline.txt"
  CUR="$LOOT_DIR/current.txt"

  nmap -sn "$NET" -oG - | awk '/Up$/{print $2}' > "$CUR"

  if [[ -f "$BASE" ]]; then
    echo -e "\n${YELLOW}[*] New devices detected:${RESET}"
    diff "$BASE" "$CUR" | grep ">" | sed 's/> //'
  else
    echo -e "${GREEN}[+] Baseline created${RESET}"
  fi

  cp "$CUR" "$BASE"
}

# -------- Menu --------
while true; do
  banner
  echo -e "${YELLOW}1) Subnet Calculator${RESET}"
  echo -e "${YELLOW}2) Host Discovery${RESET}"
  echo -e "${YELLOW}3) Readable Host Table${RESET}"
  echo -e "${YELLOW}4) Network Map Visualization${RESET}"
  echo -e "${YELLOW}5) Pentest Enumeration${RESET}"
  echo -e "${YELLOW}6) Detect New Devices${RESET}"
  echo -e "${YELLOW}7) Exit${RESET}\n"

  read -rp "Select option: " opt
  case $opt in
    1) calculate_network; pause ;;
    2) discover_hosts; pause ;;
    3) pretty_scan; pause ;;
    4) network_map; pause ;;
    5) pentest_enum; pause ;;
    6) detect_new_devices; pause ;;
    7) exit ;;
    *) echo "Invalid"; sleep 1 ;;
  esac
done

