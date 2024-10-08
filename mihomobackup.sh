#!/bin/bash

clone_gh() {
    local REPO_URL="$1"
    local BRANCH="$2"
    local TARGET_DIR="$3"
    rm -rf $TARGET_DIR
    echo "Cloning repository..."
    git clone -b $BRANCH $REPO_URL $TARGET_DIR
}

cd /tmp
while true; do
    clear
    echo "================================================"
    echo "           Auto Script | MihomoTProxy           "
    echo "================================================"
    echo ""
    echo "    [*]   Auto Script By : RizkiKotet  [*]"
    echo ""
    echo "================================================"
    echo ""
    echo " >> MENU BACKUP"
    echo " > 1 - Backup Full Config"
    echo ""
    echo " >> MENU RESTORE"
    echo " > 2 - Restore Backup Full Config"
    echo ""
    echo " >> MENU CONFIG"
    echo " > 3 - Download Full Backup Config By RTA-WRT"
    echo ""
    echo "================================================"
    echo " > X - Exit Script"
    echo "================================================"
    read choice

    case $choice in
        1)
            echo "Backup Full Config..."
            sleep 2
            current_time=$(date +"%Y-%m-%d_%H-%M-%S")
            output_tar_gz="backup_config_mihomo_${current_time}.tar.gz"
            files_to_backup=(
                "/etc/mihomo/mixin.yaml"
                "/etc/mihomo/prifiles"
                "/etc/mihomo/run"
                "/etc/config/mihomo"
            )
            echo "Archiving and compressing files and folders..."
            tar -czvf "$output_tar_gz" "${files_to_backup[@]}"
            if [ $? -eq 0 ]; then
                echo "Files successfully archived into $output_tar_gz"
            else
                echo "Failed to create the archive"
            fi
            ;;
        2)
            echo "Restore Backup Full Config..."
            read -p "Enter the path to the backup archive (e.g., /tmp/backup.tar.gz): " backup_file
            if [ -f "$backup_file" ]; then
                echo "Restoring files..."
                tar -xzvf "$backup_file" -C / --overwrite
                if [ $? -eq 0 ]; then
                    echo "Backup successfully restored and files overwritten."
                else
                    echo "Failed to restore from the backup."
                fi
            else
                echo "Backup file does not exist: $backup_file"
            fi
            ;;
        3)
            echo "Download Full Backup Config By RTA-WRT"
            sleep 2
            clone_gh "https://github.com/rtaserver/Config-Open-ClashMeta.git" "main" "/tmp/cfgmihomo"
            cd /tmp/cfgmihomo
            mv config/Country.mmdb /etc/mihomo/run/Country.mmdb
            mv config/GeoIP.dat /etc/mihomo/run/GeoIP.dat
            mv config/GeoSite.dat /etc/mihomo/run/GeoSite.dat
            mv config/proxy_provider /etc/mihomo/run/proxy_provider
            mv config/rule_provider /etc/mihomo/run/rule_provider
            mv configmihomo/cache.db /etc/mihomo/run/cache.db
            mv configmihomo/config-wrt.yaml /etc/mihomo/prifiles/config-wrt.yaml
            mv configmihomo/config.yaml /etc/mihomo/run/config.yaml
            mv configmihomo/mihomo /etc/config/mihomo
            echo "Installation completed successfully!"
            ;;
        x|X)
            echo "Exiting..."
            exit
            ;;
        *)
            echo "Invalid option selected!"
            ;;
    esac

    echo "Returning to the menu..."
    cd /tmp
    sleep 2
done
