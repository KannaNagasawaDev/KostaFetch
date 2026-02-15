#!/bin/bash

bash -c '
    user_host="$(whoami)@$(cat /etc/hostname 2>/dev/null || echo localhost)"
    os_name="$(grep "^NAME=" /etc/os-release | cut -d= -f2 | tr -d \")"
    kernel="$(uname -r)"
    shell="$(basename "$SHELL")"
    uptime="$(awk "{h=int(\$1/3600); m=int((\$1%3600)/60); printf \"%dh %dm\", h, m}" /proc/uptime)"
    cpu="$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | xargs)"
    gpu="$(for d in /sys/bus/pci/devices/*; do 
        [ -f "$d/config" ] || continue
        cls=$(od -An -t x1 -j 11 -N 1 "$d/config" | tr -d " ")
        if [ "$cls" = "03" ]; then 
            id=$(cat "$d/device")
            grep -i "^	${id#0x}" /usr/share/hwdata/pci.ids 2>/dev/null | grep -vi "audio" | head -n1 | xargs
        fi
    done | xargs)"
    memory="$(awk "/MemTotal/ {printf \"%.0f MB\", \$2/1024}" /proc/meminfo)"
    
    echo -e "\e[38;5;141muser@host:\e[0m $user_host"
    echo -e "\e[38;5;141mos:\e[0m $os_name"
    echo -e "\e[38;5;141mkernel:\e[0m $kernel"
    echo -e "\e[38;5;141mshell:\e[0m $shell"
    echo -e "\e[38;5;141muptime:\e[0m $uptime"
    echo -e "\e[38;5;141mcpu:\e[0m $cpu"
    echo -e "\e[38;5;141mgpu:\e[0m $gpu"
    echo -e "\e[38;5;141mmemory:\e[0m $memory"
'
