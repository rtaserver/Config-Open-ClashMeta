#!/bin/bash

# Script configuration
VERSION="1.9"
LOCKFILE="/tmp/mihomotproxy.lock"
BACKUP_DIR="/root/backups-mihomo"
TEMP_DIR="/tmp"
MIHOMO_CONFIG_DIR="/etc/mihomo"

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display colored messages
log_message() {
    local level=$1
    local message=$2
    case $level in
        "info")
            echo -e "${GREEN}[INFO]${NC} $message"
            ;;
        "warn")
            echo -e "${YELLOW}[WARN]${NC} $message"
            ;;
        "error")
            echo -e "${RED}[ERROR]${NC} $message"
            ;;
    esac
}

# Function to handle errors
handle_error() {
    local error_message=$1
    log_message "error" "$error_message"
    cleanup
    exit 1
}

# Function to check required commands
check_dependencies() {
    local required_commands=("wget" "unzip" "tar")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" > /dev/null 2>&1; then
            handle_error "Required command '$cmd' not found. Please install it first."
        fi
    done
}

# Enhanced cleanup function
cleanup() {
    log_message "info" "Performing cleanup..."
    rm -f "$LOCKFILE"
    rm -rf "$TEMP_DIR/Config-Open-ClashMeta-main" "$TEMP_DIR/Yacd-meta-gh-pages"
    rm -f "$TEMP_DIR/main.zip" "$TEMP_DIR/gh-pages.zip"
}

# Function to create backup directory if it doesn't exist
ensure_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR" || handle_error "Failed to create backup directory"
    fi
}

# Function to perform backup
perform_backup() {
    ensure_backup_dir
    local current_time=$(date +"%Y-%m-%d_%H-%M-%S")
    local output_tar_gz="$BACKUP_DIR/backup_config_mihomo_${current_time}.tar.gz"
    local files_to_backup=(
        "$MIHOMO_CONFIG_DIR/mixin.yaml"
        "$MIHOMO_CONFIG_DIR/profiles"
        "$MIHOMO_CONFIG_DIR/run"
        "/etc/config/mihomo"  # Added mihomo config file
    )

    log_message "info" "Starting backup process..."
    # Check if files/directories exist before backup
    for file in "${files_to_backup[@]}"; do
        if [ ! -e "$file" ]; then
            log_message "warn" "Warning: $file does not exist, but continuing backup..."
        fi
    done

    # Perform the backup
    tar -czvf "$output_tar_gz" "${files_to_backup[@]}" 2>/dev/null || handle_error "Backup failed"
    log_message "info" "Backup successfully created at: $output_tar_gz"
}

# Function to perform restore
perform_restore() {
    local backup_file=$1
    if [ ! -f "$backup_file" ]; then
        handle_error "Backup file not found: $backup_file"
    fi

    log_message "info" "Starting restore process..."
    
    # Create necessary directories if they don't exist
    mkdir -p "$MIHOMO_CONFIG_DIR/profiles" "$MIHOMO_CONFIG_DIR/run" || handle_error "Failed to create directories"
    
    # Backup existing mihomo config if it exists
    if [ -f "/etc/config/mihomo" ]; then
        cp "/etc/config/mihomo" "/etc/config/mihomo.bak" || log_message "warn" "Failed to backup existing mihomo config"
    fi

    # Perform the restore
    tar -xzvf "$backup_file" -C / --overwrite || handle_error "Restore failed"

    # Restore existing mihomo config if it exists
    mv "$MIHOMO_CONFIG_DIR/mihomo" "/etc/config/mihomo" || log_message "warn" "Failed to Restore mihomo config"
    
    # Set proper permissions
    chmod 644 "/etc/config/mihomo" || log_message "warn" "Failed to set permissions on mihomo config"
    
    log_message "info" "Restore completed successfully"
}

# Function to download and install configuration
install_config() {
    log_message "info" "Downloading configuration files..."
    
    wget -q --show-progress -O "$TEMP_DIR/main.zip" \
        "https://github.com/rtaserver/Config-Open-ClashMeta/archive/refs/heads/main.zip" || \
        handle_error "Failed to download configuration"
    
    unzip -o "$TEMP_DIR/main.zip" -d "$TEMP_DIR" || handle_error "Failed to extract configuration"

    cd "$TEMP_DIR/Config-Open-ClashMeta-main" || handle_error "Failed to change directory"
    
    # Move files to their respective locations
    mv -f config/Country.mmdb "$MIHOMO_CONFIG_DIR/run/Country.mmdb" && chmod +x "$MIHOMO_CONFIG_DIR/run/Country.mmdb"
    mv -f config/GeoIP.dat "$MIHOMO_CONFIG_DIR/run/GeoIP.dat" && chmod +x "$MIHOMO_CONFIG_DIR/run/GeoIP.dat"
    mv -f config/GeoSite.dat "$MIHOMO_CONFIG_DIR/run/GeoSite.dat" && chmod +x "$MIHOMO_CONFIG_DIR/run/GeoSite.dat"
    mv -fT config/proxy_provider "$MIHOMO_CONFIG_DIR/run/proxy_provider" && chmod +x "$MIHOMO_CONFIG_DIR/run/proxy_provider"/*
    mv -fT config/rule_provider "$MIHOMO_CONFIG_DIR/run/rule_provider" && chmod +x "$MIHOMO_CONFIG_DIR/run/rule_provider"/*
    mv -f config/config/config-rule-wrt.yaml "$MIHOMO_CONFIG_DIR/profiles/config-rule-wrt.yaml" && chmod +x "$MIHOMO_CONFIG_DIR/profiles/config-rule-wrt.yaml"
    mv -f config/config/config-simple-wrt.yaml "$MIHOMO_CONFIG_DIR/profiles/config-simple-wrt.yaml" && chmod +x "$MIHOMO_CONFIG_DIR/profiles/config-simple-wrt.yaml"
    mv -f config/mihomo /etc/config/mihomo && chmod 644 /etc/config/mihomo

    log_message "info" "Installing Yacd dashboard..."
    cd "$TEMP_DIR" || handle_error "Failed to change directory"
    wget -q --show-progress -O "$TEMP_DIR/gh-pages.zip" \
        "https://github.com/MetaCubeX/Yacd-meta/archive/refs/heads/gh-pages.zip" || \
        handle_error "Failed to download dashboard"
    
    unzip -o "$TEMP_DIR/gh-pages.zip" -d "$TEMP_DIR" || handle_error "Failed to extract dashboard"
    mv -fT "$TEMP_DIR/Yacd-meta-gh-pages" "$MIHOMO_CONFIG_DIR/run/ui/dashboard" || handle_error "Failed to install dashboard"

    log_message "info" "Configuration installation completed successfully!"
}

# Function to display menu
display_menu() {
    clear
    cat << EOF
================================================
           Auto Script | MihomoTProxy           
================================================

    [*]   Auto Script By : RizkiKotet  [*]
    Version: $VERSION

================================================

 >> MENU BACKUP
 > 1 - Backup Full Config

 >> MENU RESTORE
 > 2 - Restore Backup Full Config

 >> MENU CONFIG
 > 3 - Download Full Backup Config By RTA-WRT

================================================
 > X - Exit Script
================================================
EOF
}

# Main script execution
main() {
    # Check if script is already running
    if [ -e "$LOCKFILE" ]; then
        handle_error "Script is already running"
    fi

    # Create lock file and set cleanup trap
    touch "$LOCKFILE" || handle_error "Failed to create lock file"
    trap cleanup EXIT

    # Check dependencies
    check_dependencies

    # Main loop
    while true; do
        display_menu
        read -r choice

        case $choice in
            1)
                perform_backup
                ;;
            2)
                read -p "Enter backup file path: " backup_file
                perform_restore "$backup_file"
                ;;
            3)
                install_config
                ;;
            [xX])
                log_message "info" "Exiting..."
                exit 0
                ;;
            *)
                log_message "warn" "Invalid option selected!"
                ;;
        esac

        read -p "Press Enter to continue..."
    done
}

# Start script
main