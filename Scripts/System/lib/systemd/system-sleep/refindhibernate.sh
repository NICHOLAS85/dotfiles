#!/bin/sh

if [ "$2" = "hibernate" ]; then
    case "$1" in
        pre)
            echo "refindhibernate.sh: Setting timeout to -1"
            sed 's/timeout.*/timeout -1/g' /boot/efi/EFI/refind/timeout.conf > /boot/efi/EFI/refind/timeout.conf~
            mv /boot/efi/EFI/refind/timeout.conf~ /boot/efi/EFI/refind/timeout.conf
        ;;
        post)
            echo "refindhibernate.sh: Setting timeout to 5"
            sed 's/timeout.*/timeout 5/g' /boot/efi/EFI/refind/timeout.conf > /boot/efi/EFI/refind/timeout.conf~
            mv /boot/efi/EFI/refind/timeout.conf~ /boot/efi/EFI/refind/timeout.conf
            ;;
    esac
fi
