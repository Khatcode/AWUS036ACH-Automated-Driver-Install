#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Please use 'sudo' or log in as the root user."
    exit 1
fi

# Detect the Linux distribution
if command -v apt-get &> /dev/null; then
    # Debian-based distribution (e.g., Debian, Ubuntu)
    PACKAGE_MANAGER="apt-get"
elif command -v dnf &> /dev/null; then
    # Fedora-based distribution (e.g., Fedora, RHEL)
    PACKAGE_MANAGER="dnf"
else
    echo "Unsupported Linux distribution. Exiting."
    exit 1
fi

# Check if git is installed, and install it if not
if ! command -v git &> /dev/null; then
    echo "Git is not installed. Installing git..."
    sudo "$PACKAGE_MANAGER" install git -y
fi


echo "Running as root on a $PACKAGE_MANAGER-based system. Continue with the rest of the script."

echo "Installing Updates and Upgrades. Give it some time."

sudo "$PACKAGE_MANAGER" update -y && \
sudo "$PACKAGE_MANAGER" upgrade -y && \
sudo "$PACKAGE_MANAGER" dist-upgrade -y

echo "Installing realtek drivers."

sudo "$PACKAGE_MANAGER" install realtek-rtl88xxau-dkms -y

echo "installing more drivers"
git clone https://github.com/aircrack-ng/rtl8812au

echo "Building all necessary rtl8812 executable files into binary applications. This will take some time"

cd rtl8812au

make

echo "Taking newly created binaries and copying them into the appropriate locations on the file system."

sudo make install

echo "The system needs to be rebooted to apply changes."

for i in {5..1}; do
    echo "Rebooting in $i seconds. Press Ctrl+C to cancel."
    sleep 1
done
