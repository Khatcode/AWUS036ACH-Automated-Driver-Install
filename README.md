# AWUS036ACH Automated Driver Install Script

![Hyper-V Not Supported](https://img.shields.io/badge/Hyper--V-not%20supported-red)

---

**⚠️ This repository is not compatible with Hyper-V!**  
Please avoid using Hyper-V — use VirtualBox, VMware, or native hardware instead.

## Overview

This bash script automates the installation of Realtek wireless drivers for the **AWUS036ACH** on Linux systems. It performs the following tasks:

- Checks for the Linux distribution.
- Installs `git` if not present.
- Updates the system.
- Installs kernel headers necessary for building the driver.
- Installs Realtek drivers.
- Clones the `rtl8812au` repository from Aircrack-ng.
- Compiles the drivers.
- Prompts for a reboot to apply changes.
- Optionally removes any existing driver installations.

## Prerequisites

- The script must be run as root. Use `sudo` or log in as the root user.
- Supported Linux distributions: 
  - Debian-based (e.g., Debian, Ubuntu)
  - Fedora-based (e.g., Fedora, RHEL)

## Usage

1. Download the script or copy its content into a file.
2. Clone the repository:
    ```bash
    git clone https://github.com/Khatcode/AWUS036ACH-Automated-Driver-Install
    cd AWUS036ACH-Automated-Driver-Install
    ```
3. Make the script executable:
    ```bash
    chmod +x Alfasetup.sh
    ```
4. Run the script as root:
    ```bash
    sudo ./Alfasetup.sh
    ```
   or combine the commands:
    ```bash
    git clone https://github.com/Khatcode/AWUS036ACH-Automated-Driver-Install && cd AWUS036ACH-Automated-Driver-Install && chmod +x Alfasetup.sh && sudo ./Alfasetup.sh
    ```

## Script Steps

1. **Root Check:**
   - Verifies if the script is run with root privileges.

2. **Distribution Detection:**
   - Identifies the Linux distribution to use the appropriate package manager (`apt-get` or `dnf`).

3. **Git Installation:**
   - Checks for the presence of `git` and installs it if necessary.

4. **System Updates:**
   - Updates the system, upgrades packages, and performs a distribution upgrade.
   - Automatically restarts services during package upgrades without user interaction.

5. **Kernel Headers Installation:**
   - Installs the necessary kernel headers required for building the driver.

6. **Realtek Drivers Installation:**
   - Installs Realtek wireless drivers using the detected package manager.

7. **Existing Driver Removal:**
   - Checks if a version of the driver is already installed. 
   - Prompts the user to remove the existing installation if found, which helps avoid conflicts.

8. **Additional Drivers Installation:**
   - Clones the `rtl8812au` repository from Aircrack-ng and compiles the drivers.

9. **Executable Building:**
   - Compiles the necessary `rtl8812` executable files into binary applications.

10. **Installation:**
    - Installs the compiled binaries into the appropriate locations on the file system.

11. **Reboot Prompt:**
    - Notifies the user that a system reboot is necessary to apply changes and initiates a countdown.

## Note

- The script will prompt for a system reboot after completing the installation.
- It is recommended to remove any existing driver installations before proceeding with the new installation to ensure compatibility and avoid potential issues.
