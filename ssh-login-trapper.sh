#!/bin/bash
LOG_FILE="/var/log/auth.log"
CONF_FILE="/etc/zabbix/zabbix_agent2.conf"
Z_HOSTNAME="$(grep '^Hostname=[^$]' $CONF_FILE | cut -d '=' -f2)"

awk -v host="$Z_HOSTNAME" '
# cache last accepted key
/Accepted publickey/ { last_key = $NF }

# Session Start
/New session [0-9]+ of user/ {
    # Extract Session ID
    n = split($0, parts, "session ");
    split(parts[2], id_parts, " ");
    sess_id = id_parts[1];

    ts = $1; "date -d \"" ts "\" +%s" | getline unix_ts; close("date -d \"" ts "\" +%s")
    
    # 1. Set key in login history item
    printf "%s ssh.auth.history %s %s\n", host, unix_ts, last_key
    
    # 2. Set Session to "open" : timestamp = login; value = publickey
    printf "%s ssh.session.status[%s] %s %s\n", host, sess_id, unix_ts, last_key
}

# Session Ende
/Removed session [0-9]+/ {
    # Extract Session ID
    n = split($0, parts, "session ");
    split(parts[2], id_parts, ".");
    sess_id = id_parts[1];

    ts = $1; "date -d \"" ts "\" +%s" | getline unix_ts; close("date -d \"" ts "\" +%s")
    
    # Set Session to literaly "closed"
    printf "%s ssh.session.status[%s] %s closed\n", host, sess_id, unix_ts
}
' "$LOG_FILE" | zabbix_sender -c "$CONF_FILE" -T -i - >/dev/null 2>&1

echo 1
