BOCL Full Device Deauth Tool

📡 Hostnames + MAC + Deauth (For Testing Only)
Overview

This Bash script helps you scan your local network to identify connected devices by IP, MAC address, and hostname. After identifying the devices, it allows you to launch a Wi-Fi deauthentication (deauth) attack against a specific target device for testing and educational purposes only.

⚠️ WARNING:
This tool is intended strictly for authorized testing on networks and devices you own or have explicit permission to test. Unauthorized use on networks or devices you do not own may be illegal and unethical.
Features

    Automatically detects your local IP and subnet.

    Scans the network for active devices showing their IP, MAC addresses, and hostnames.

    Validates MAC address inputs.

    Lists available Wi-Fi interfaces.

    Enables monitor mode on the selected Wi-Fi interface.

    Allows scanning for Wi-Fi routers to select your router’s BSSID and channel.

    Starts a continuous deauthentication attack on the chosen target device.

    Automatically cleans up and restores network settings on script exit.

Prerequisites

    Linux OS with bash

    Installed and configured tools:

        nmap

        airmon-ng

        airodump-ng

        aireplay-ng

        iwconfig

    User must have sudo privileges to run commands like enabling monitor mode and launching deauth attacks.

Installation

    Make sure all required tools are installed:

sudo apt update
sudo apt install aircrack-ng nmap wireless-tools

    Save the script to a file, for example:

nano bocl_deauth.sh

    Paste the script content into the file and save.

    Make the script executable:

chmod +x bocl_deauth.sh

Usage

Run the script with root privileges:

sudo ./bocl_deauth.sh

Script Flow

    The script detects your current IP and subnet.

    Scans the subnet for active devices and prints IP, MAC, and device names.

    Prompts for the MAC address of the device to target (not the router).

    Lists available Wi-Fi interfaces and asks you to specify which one to use.

    Enables monitor mode on the chosen interface.

    Runs airodump-ng so you can identify your router's BSSID and channel (press Ctrl+C once identified).

    Prompts for your router’s BSSID and channel number.

    Sets the monitor mode interface to the router’s channel.

    Starts a continuous deauth attack on the target device.

    To stop, press Ctrl+C which triggers cleanup and restores your system settings.

Important Notes

    Deauth attacks disrupt network connectivity for the target device by sending disassociation packets.

    This tool should only be used for penetration testing, learning, or on your own network.

    Misuse on unauthorized networks is illegal.

    Running airmon-ng check kill may kill network manager and other network-related services temporarily.

    Always review and understand the impact before running.

Cleanup

Pressing Ctrl+C during the attack will:

    Stop monitor mode.

    Restart NetworkManager.

    Unblock all wireless interfaces.

    Exit the script cleanly.

Troubleshooting

    Could not determine your IP address: Ensure you are connected to a network.

    No devices found: Check your network connection and try again.

    Invalid MAC/BSSID format: Make sure MAC addresses follow the format XX:XX:XX:XX:XX:XX.

    Permission denied errors: Run the script with sudo.

License & Disclaimer

This script is provided as-is for educational and authorized testing purposes only. The author is not responsible for any misuse or damages caused.
