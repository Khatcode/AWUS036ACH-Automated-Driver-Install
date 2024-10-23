#!/bin/bash

# AWUS036ACH Automated Driver Install Script

# Function to check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root. Use 'sudo' or log in as the root user."
        exit 1
    fi
}

# Check for Linux distribution
detect_distribution() {
    if [[ -f /etc/debian_version ]]; then
        PACKAGE_MANAGER="apt-get"
    elif [[ -f /etc/redhat-release ]]; then
        PACKAGE_MANAGER="dnf"
    else
        echo "Unsupported Linux distribution. Exiting."
        exit 1
    fi
}

# Install git if not present
install_git() {
    if ! command -v git &> /dev/null; then
        echo "git is not installed. Installing git..."
        sudo "$PACKAGE_MANAGER" install git -y
    fi
}

# Install kernel headers
install_kernel_headers() {
    echo "Installing kernel headers..."
    if ! sudo "$PACKAGE_MANAGER" install linux-headers-$(uname -r) -y; then
        echo "Specific kernel headers not found. Installing generic headers instead..."
        sudo "$PACKAGE_MANAGER" install linux-headers-generic -y
        if [[ $? -ne 0 ]]; then
            echo "Failed to install kernel headers. Exiting."
            exit 1
        fi
    fi
}

# Update and upgrade system packages
update_system() {
    echo "Setting DEBIAN_FRONTEND to noninteractive for updates."
    export DEBIAN_FRONTEND=noninteractive

    echo "Installing updates and upgrades. Give it some time."
    sudo "$PACKAGE_MANAGER" update -y && \
    sudo "$PACKAGE_MANAGER" upgrade -y && \
    sudo "$PACKAGE_MANAGER" dist-upgrade -y
}

# Check if the Realtek driver is already installed
check_existing_driver() {
    if lsmod | grep -q "88XXau"; then
        echo "Driver already installed."
        
        # Ask the user if they want to remove the existing driver
        read -p "Do you want to remove the existing installation? (y/n): " REMOVE_CHOICE
        
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
                # Need to specify the module and version for removal
                sudo dkms remove rtl8812au/<version> --all
                if [[ $? -ne 0 ]]; then
                    echo "Failed to remove the driver using DKMS. Continuing to manual removal..."
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
}

# Option to install Realtek drivers
install_realtek_drivers() {
    read -p "Do you want to install Realtek drivers using the package manager (1) or from the source (2)? Enter 1 or 2: " INSTALL_CHOICE

    if [[ "$INSTALL_CHOICE" == "1" ]]; then
        echo "Installing Realtek drivers using the package manager."
        sudo "$PACKAGE_MANAGER" install realtek-rtl88xxau-dkms -y
    elif [[ "$INSTALL_CHOICE" == "2" ]]; then
        echo "Installing Realtek drivers from the source."
        
        echo "Cloning the rtl8812au repository from aircrack-ng..."
        git clone https://github.com/aircrack-ng/rtl8812au
        
        echo "Building all necessary rtl8812 executable files into binary applications. This will take some time."
        cd rtl8812au || { echo "Failed to change directory. Exiting."; exit 1; }
        
        echo "Cleaning previous builds..."
        make clean
        
        echo "Compiling the driver..."
        make
        if [[ $? -ne 0 ]]; then
            echo "Make command failed. Exiting."
            exit 1
        fi
        
        echo "Taking newly created binaries and copying them into the appropriate locations on the file system."
        sudo make install
        if [[ $? -ne 0 ]]; then
            echo "Installation of the driver binaries failed. Exiting."
            exit 1
        fi
    else
        echo "Invalid choice. Exiting."
        exit 1
    fi
}

# Main script execution
check_root
detect_distribution
update_system
install_git
install_kernel_headers
check_existing_driver
install_realtek_drivers

echo "Driver installation process completed. Please reboot the system to apply changes."
read -p "Do you want to reboot now? (y/n): " REBOOT_CHOICE
if [[ "$REBOOT_CHOICE" == "y" || "$REBOOT_CHOICE" == "Y" ]]; then
    echo "Rebooting now..."
    reboot
else
    echo "Please remember to reboot your system later to apply changes."
fi
