#!/bin/sh

if [ "$2" = "hibernate" ]; then
    case "$1" in
        pre)
            echo "Running refindhibernate.sh. Setting timeout to -1"
            sed 's/timeout.*/timeout -1/g' /boot/efi/EFI/refind/themes/refind-ambience/theme.conf > /boot/efi/EFI/refind/themes/refind-ambience/theme.conf~
            mv /boot/efi/EFI/refind/themes/refind-ambience/theme.conf~ /boot/efi/EFI/refind/themes/refind-ambience/theme.conf
        ;;
        post)
            echo "Running refindhibernate.sh Setting timeout to 5"
            sed 's/timeout.*/timeout 5/g' /boot/efi/EFI/refind/themes/refind-ambience/theme.conf > /boot/efi/EFI/refind/themes/refind-ambience/theme.conf~
            mv /boot/efi/EFI/refind/themes/refind-ambience/theme.conf~ /boot/efi/EFI/refind/themes/refind-ambience/theme.conf
            ;;
    esac
fi
