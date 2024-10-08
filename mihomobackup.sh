#!/bin/bash

cd /tmp || { echo "Failed to change directory to /tmp"; exit 1; }

echo "Script Version: 1.5"
sleep 3
clear

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
    read -r choice

    case $choice in
        1)
            echo "Backup Full Config..."
            sleep 2
            current_time=$(date +"%Y-%m-%d_%H-%M-%S")
            output_tar_gz="/root/backup_config_mihomo_${current_time}.tar.gz"
            files_to_backup=(
                "/etc/mihomo/mixin.yaml"
                "/etc/mihomo/profiles"
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
            sleep 3
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
            sleep 3
            ;;
        3)
            echo "Download Full Backup Config By RTA-WRT"
            sleep 2
            wget -O main.zip https://github.com/rtaserver/Config-Open-ClashMeta/archive/refs/heads/main.zip
            unzip -o /tmp/main.zip -d /tmp  # Use -o to overwrite existing files
            rm -rf /tmp/main.zip
            cd /tmp/Config-Open-ClashMeta-main || { echo "Failed to change directory"; exit 1; }
            mv -f config/Country.mmdb /etc/mihomo/run/Country.mmdb && chmod +x /etc/mihomo/run/Country.mmdb
            mv -f config/GeoIP.dat /etc/mihomo/run/GeoIP.dat && chmod +x /etc/mihomo/run/GeoIP.dat
            mv -f config/GeoSite.dat /etc/mihomo/run/GeoSite.dat && chmod +x /etc/mihomo/run/GeoSite.dat
            mv -fT config/proxy_provider /etc/mihomo/run/proxy_provider && chmod +x /etc/mihomo/run/proxy_provider/*
            mv -fT config/rule_provider /etc/mihomo/run/rule_provider && chmod +x /etc/mihomo/run/rule_provider/*
            mv -f configmihomo/cache.db /etc/mihomo/run/cache.db && chmod +x /etc/mihomo/run/cache.db
            mv -f configmihomo/config-wrt.yaml /etc/mihomo/profiles/config-wrt.yaml && chmod +x /etc/mihomo/profiles/config-wrt.yaml
            mv -f configmihomo/config.yaml /etc/mihomo/run/config.yaml && chmod +x /etc/mihomo/run/config.yaml
            mv -f configmihomo/mihomo /etc/config/mihomo
            rm -rf /tmp/Config-Open-ClashMeta-main
            clear
            echo "Download Dashboard Yacd"
            wget -O gh-pages.zip https://github.com/MetaCubeX/Yacd-meta/archive/refs/heads/gh-pages.zip
            unzip -o /tmp/gh-pages.zip -d /tmp  # Use -o to overwrite existing files
            rm -rf /tmp/gh-pages.zip
            mv -fT /tmp/Yacd-meta-gh-pages /etc/mihomo/run/ui/dashboard
            echo "Installation completed successfully!"
            sleep 3
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
    cd /tmp || { echo "Failed to change directory to /tmp"; exit 1; }
    sleep 2
done
