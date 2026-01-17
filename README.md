Cool stuff:

#!/bin/bash
# Detect outbound SSH connections (zero-day exfil indicator)

SSH_PORTS="22"
STATE="/var/tmp/ssh_outbound.state"
WHITELIST="/etc/ssh_outbound.whitelist"   # lines: CIDR:PORT or IP:PORT or CIDR:*

touch "$STATE"

ss -H -pt state established | while read -r line; do
  laddr=$(awk '{print $4}' <<<"$line")
  raddr=$(awk '{print $5}' <<<"$line")
  proc=$(sed -n 's/.*users:(("\([^"]*\)".*/\1/p' <<<"$line")
  pid=$(sed -n 's/.*pid=\([0-9]*\).*/\1/p' <<<"$line")

  r_ip=${raddr%:*}
  r_port=${raddr##*:}

  # flag if remote port is SSH or process is ssh
  [[ "$SSH_PORTS" == *"$r_port"* || "$proc" == "ssh" ]] || continue

  # whitelist check
  if [[ -f "$WHITELIST" ]] && grep -qE "^($r_ip|.*/.*):($r_port|\*)$" "$WHITELIST"; then
    continue
  fi

  key="$pid-$r_ip-$r_port"
  grep -q "$key" "$STATE" && continue
  echo "$key" >> "$STATE"

  user=$(ps -o user= -p "$pid" 2>/dev/null)
  exe=$(readlink -f /proc/$pid/exe 2>/dev/null)
  cmd=$(tr '\0' ' ' </proc/$pid/cmdline 2>/dev/null)

  logger -p auth.warning \
    "Outbound SSH detected dst=$r_ip:$r_port pid=$pid user=$user exe=$exe cmd=\"$cmd\""
done
