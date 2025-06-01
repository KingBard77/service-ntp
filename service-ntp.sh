#!/usr/bin/env bash

set -euo pipefail

# COLORS
NC='\033[0m'
SUCCESS='\033[0;32m'
ERROR='\033[0;31m'
WARN='\033[0;33m'
INFO='\033[0;34m'

# SOURCE SETUP.CONF
if [[ -n "${BASH_SOURCE[0]:-}" && "${BASH_SOURCE[0]}" != "bash" && "${BASH_SOURCE[0]}" != "-bash" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
else
    SCRIPT_DIR="$(pwd)"
fi

# USAGE FUNCTION
usage() {
    echo -e "${INFO} #####################################################################${NC}"
    echo -e "${INFO} #                Install (NTP) Service - Usage Guide                #${NC}"
    echo -e "${INFO} #####################################################################${NC}"
    echo -e ""
    echo -e "${INFO} Usage:${NC}"
    echo -e "${WARN}   sudo bash -x ./[SCRIPT_NAME]${NC}"
    echo -e ""
    echo -e "${INFO} Description:${NC}"
    echo -e "   This script installs and configures Network Time Protocol (NTP) service"
    echo -e ""
    echo -e "${INFO} Requirements:${NC}"
    echo -e "   - Must be run as root (use sudo)"
    echo -e "   - Make sure conf/setup.conf is present with valid variables"
    echo -e ""
    echo -e "${INFO} Example:${NC}"
    echo -e "   sudo bash -x ./service-ntp.sh"
    echo -e ""
    exit 1
}

# AGRS FOR HELP USAGE
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
fi

echo -e "${INFO}  ##### Package: Update ${NC}"
apt --assume-yes update

echo -e "${INFO}  ##### NTP: Install ${NC}"
apt --assume-yes install chrony

echo -e "${INFO}  ##### NTP: Configure ${NC}"
sed -i '/^pool/d' "$NTP_CHRONY_CONF"
echo "$NTP_CHRONY_SERVER" >> "$NTP_CHRONY_CONF"

echo -e "${INFO}  ##### NTP: Allow Subnets ${NC}"
echo "allow $NTP_LOCAL_SUBNET" >> "$NTP_CHRONY_CONF"

echo -e "${INFO}  ##### NTP: Bind Address & Port ${NC}"
echo -e "$NTP_LOCAL_PORT\n$NTP_CHRONY_BINDADD_1\n$NTP_CHRONY_BINDADD_2" >> "$NTP_CHRONY_CONF"

echo -e "${INFO}  ##### NTP: Service ${NC}"
systemctl enable chrony.service
systemctl restart chrony.service

echo -e "${INFO}  ##### NTP: Cleanup ${NC}"
apt --assume-yes autoremove
apt --assume-yes autoclean

echo -e "${SUCCESS}#### NTP: Install Complete ${NC}"

echo -e "${INFO}#### Reboot ${NC}"
# reboot
