#!/usr/bin/env bash

# COLORS
NC='\033[0m'
SUCCESS='\033[0;32m'
ERROR='\033[0;31m'
WARN='\033[0;33m'
INFO='\033[0;34m'

# SOURCE SETUP.CONF
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
if [[ -f "$SCRIPT_DIR/conf/setup.conf" ]]; then
    source "$SCRIPT_DIR/conf/setup.conf"
fi

echo -e "${INFO}##### Package: Update ${NC}"
apt --assume-yes update

echo -e "${INFO}##### NTP: Install ${NC}"
apt install --assume-yes chrony

echo -e "${INFO}##### NTP: Configure ${NC}"
sed -i '/^pool/d' $CHRONY_CONF
echo "$NTP_SERVERS" >> $CHRONY_CONF

echo -e "${INFO}##### NTP: Subnet ${NC}"
for SUBNET in $SUBNETS_ALLOWED; do
    echo "allow $SUBNET" >> $CHRONY_CONF
done

echo -e "${INFO}##### NTP: Subnet ${NC}"
echo -e "$PORT\n$BINDADD_1\n$BINDADD_2" >> $CHRONY_CONF

echo -e "${INFO}##### NTP: Service ${NC}"
systemctl enable chrony.service
systemctl restart chrony.service

echo -e "${INFO}##### NTP: Cleanup ${NC}"
apt --assume-yes autoremove
apt --assume-yes autoclean

echo -e "${SUCCESS}#### NTP: Install Complete ${NC}"

echo -e "${INFO}#### Reboot ${NC}"
# reboot
