#!/bin/bash

# --- KONFIGURATION ---
LOG_FILE="/var/log/auth.log"
CONF_FILE="/etc/zabbix/zabbix_agent2.conf"
# ---------------------

if [ ! -r "$LOG_FILE" ]; then echo 0; exit 1; fi

Z_HOSTNAME="$(grep '^Hostname=[^$]' $CONF_FILE | cut -d '=' -f2)"

awk -v host="$Z_HOSTNAME" '
/Accepted publickey/ {
    # Calc Unix-Timestamp for histical data
    cmd = "date -d \"" $1 "\" +%s"
    cmd | getline unix_ts
    close(cmd)
    
    key_val = $NF
    
    # Send to Item "ssh.auth.history"
    # Format: Hostname Key Timestamp SSH-Key
    printf "%s ssh.auth.history %s %s\n", host, unix_ts, key_val
}' "$LOG_FILE" | zabbix_sender -c "$CONF_FILE" -T -i - >/dev/null 2>&1

echo 1