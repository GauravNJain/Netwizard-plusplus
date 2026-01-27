#!/usr/bin/env bash

# ===============================
#  NetWizard++ Installer
# ===============================

APP_NAME="nwpp"
INSTALL_PATH="/usr/local/bin/$APP_NAME"
SOURCE_SCRIPT="netwizard++.sh"

# -------- Colors --------
RED="\e[31m"; GREEN="\e[32m"; YELLOW="\e[33m"
BLUE="\e[34m"; CYAN="\e[36m"; BOLD="\e[1m"; RESET="\e[0m"

# -------- Banner --------
clear
echo -e "${CYAN}${BOLD}"
cat << "EOF"
 _   _      _   __        _                  _     ++
| \ | | ___| |_/ /_ _ __| |_ ___  _ __ ___  | |
|  \| |/ _ \ __| | '__| | __/ _ \| '__/ _ \ | |
| |\  |  __/ |_| | |  | | || (_) | | |  __/ |_|
|_| \_|\___|\__| |_|  |_|\__\___/|_|  \___| (_)

      NetWizard++ Installer
EOF
echo -e "${RESET}"

# -------- Root Check --------
if [[ "$EUID" -ne 0 ]]; then
  echo -e "${RED}[!] Please run this installer as root (sudo).${RESET}"
  exit 1
fi

# -------- Detect Package Manager --------
echo -e "${YELLOW}[*] Detecting package manager...${RESET}"

if command -v apt >/dev/null; then
  PKG_MGR="apt"
elif command -v dnf >/dev/null; then
  PKG_MGR="dnf"
elif command -v pacman >/dev/null; then
  PKG_MGR="pacman"
else
  echo -e "${RED}[!] Unsupported package manager.${RESET}"
  exit 1
fi

echo -e "${GREEN}[+] Using package manager:${RESET} $PKG_MGR"

# -------- Install Dependencies --------
echo -e "\n${YELLOW}[*] Installing dependencies...${RESET}"

set +e   # ⬅ disable instant-exit temporarily

case "$PKG_MGR" in
  apt)
    export DEBIAN_FRONTEND=noninteractive
    apt update -qq >/dev/null 2>&1
    apt install -y -qq nmap gawk util-linux graphviz >/dev/null 2>&1
    ;;
  dnf)
    dnf install -y nmap gawk util-linux graphviz >/dev/null 2>&1
    ;;
  pacman)
    pacman -Sy --noconfirm nmap gawk util-linux graphviz >/dev/null 2>&1
    ;;
esac

if [[ $? -ne 0 ]]; then
  echo -e "${RED}[!] Failed to install dependencies.${RESET}"
  echo -e "${YELLOW}    Please install them manually and re-run.${RESET}"
  exit 1
fi

set -e   # ⬅ re-enable safety

echo -e "${GREEN}[+] Dependencies installed.${RESET}"

# -------- Install Script --------
if [[ ! -f "$SOURCE_SCRIPT" ]]; then
  echo -e "${RED}[!] Source file '$SOURCE_SCRIPT' not found.${RESET}"
  exit 1
fi

echo -e "\n${YELLOW}[*] Installing NetWizard++ to ${INSTALL_PATH}...${RESET}"

cp "$SOURCE_SCRIPT" "$INSTALL_PATH"
chmod +x "$INSTALL_PATH"

# -------- Final Message --------
echo -e "\n${GREEN}${BOLD}[✓] Installation complete!${RESET}"
echo -e "${CYAN}Run it using:${RESET} ${BOLD}nwpp${RESET}\n"
echo -e "${BLUE}Happy hacking. Stay ethical. 😎${RESET}"

