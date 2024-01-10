AWUS036ACH Automated Driver Install Script
Overview

This bash script automates the installation of Realtek wireless drivers for AWUS036ACH on Linux systems. It checks for the Linux distribution, installs git if not present, updates the system, installs Realtek drivers, clones the rtl8812au repository from aircrack-ng, compiles the drivers, and prompts for a reboot to apply changes.
Prerequisites

    The script must be run as root. Use 'sudo' or log in as the root user.
    Supported Linux distributions: Debian-based (e.g., Debian, Ubuntu), Fedora-based (e.g., Fedora, RHEL).

Usage

    Download the script or copy its content into a file.
    Make the script executable: chmod +x script_name.sh
    Run the script as root: sudo ./script_name.sh

Script Steps

    Root Check:
        Verifies if the script is run with root privileges.

    Distribution Detection:
        Identifies the Linux distribution to use the appropriate package manager (apt-get or dnf).

    Git Installation:
        Checks for the presence of git and installs it if necessary.

    System Updates:
        Updates the system, upgrades packages, and performs a distribution upgrade.

    Realtek Drivers Installation:
        Installs Realtek wireless drivers using the detected package manager.

    Additional Drivers Installation:
        Clones the rtl8812au repository from aircrack-ng and compiles the drivers.

    Executable Building:
        Compiles the necessary rtl8812 executable files into binary applications.

    Installation:
        Installs the compiled binaries into the appropriate locations on the file system.

    Reboot Prompt:
        Notifies the user that a system reboot is necessary to apply changes and initiates a countdown.

Note

    The script will prompt for a system reboot after completing the installation.
