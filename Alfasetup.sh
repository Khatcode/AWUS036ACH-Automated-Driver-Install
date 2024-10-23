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
    if [[ $? -ne 0 ]]; then
        echo "Failed to install git. Exiting."
        exit 1
    fi
fi

echo "Running as root on a $PACKAGE_MANAGER-based system. Continue with the rest of the script."

echo "Installing Updates and Upgrades. Give it some time."
sudo "$PACKAGE_MANAGER" update -y && \
sudo "$PACKAGE_MANAGER" upgrade -y && \
sudo "$PACKAGE_MANAGER" dist-upgrade -y

# Install the kernel headers
if [ "$PACKAGE_MANAGER" == "apt-get" ]; then
    echo "Installing kernel headers for Debian-based systems."
    sudo apt-get install linux-headers-$(uname -r) -y
    if [[ $? -ne 0 ]]; then
        echo "Failed to install kernel headers. Exiting."
        exit 1
    fi
elif [ "$PACKAGE_MANAGER" == "dnf" ]; then
    echo "Installing kernel headers for Fedora-based systems."
    sudo dnf install kernel-headers kernel-devel -y
    if [[ $? -ne 0 ]]; then
        echo "Failed to install kernel headers. Exiting."
        exit 1
    fi
fi

if lsmod | grep -q "88XXau"; then
    echo "Driver already installed."
    
    # Ask the user if they want to remove the existing driver
    read -p "We recommend removing the existing installation before installing a new version. Do you want to remove the existing installation? (y/n): " REMOVE_CHOICE
    
    if [[ "$REMOVE_CHOICE" == "y" || "$REMOVE_CHOICE" == "Y" ]]; then
        echo "Removing existing driver installation."
        
        # Unload the kernel module
        sudo rmmod 88XXau
        if [[ $? -ne 0 ]]; then
            echo "Failed to remove the driver from the kernel. Exiting."
            exit 1
        fi
        
        # Check if DKMS is managing the module and remove it
        if command -v dkms &> /dev/null; then
            # Replace <module-name> with the actual name of your module
            sudo dkms remove rtl8812au/<module-version> --all
            if [[ $? -ne 0 ]]; then
                echo "Failed to remove the driver using DKMS. Continuing with manual removal..."
            fi
        fi
        
        # Manually remove the driver files from /lib/modules
        DRIVER_PATH="/lib/modules/$(uname -r)/kernel/drivers/net/wireless/88XXau.ko"
        if [[ -f "$DRIVER_PATH" ]]; then
            sudo rm -f "$DRIVER_PATH"
            echo "Driver files removed from $DRIVER_PATH."
        else
            echo "Driver files not found in $DRIVER_PATH. They might have already been removed."
        fi
        
        # Update module dependencies
        sudo depmod -a
        
        echo "Driver uninstalled successfully."
    else
        echo "Skipping driver removal."
        exit 0
    fi
fi

echo "Installing realtek drivers."
sudo "$PACKAGE_MANAGER" install realtek-rtl88xxau-dkms -y

echo "Installing more drivers"
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

# Reboot the system
sudo init 6
