# Linux WRCCDC Checklist
**Minute 0 / Hour 0 Response Plan**

---

## MINUTE ZERO — Immediate Actions (System Triage & Baseline)

### 1. System State Snapshot
* Run bash script
* SCP compressed directory locally

### List all users
`cat /etc/passwd`

### Check for UID 0 users (should only be root)
`awk -F: '($3 == "0") {print}' /etc/passwd`

### List user shells (check for invalid or dangerous shells)
`awk -F: '{print $1, $7}' /etc/passwd`

### Find empty password accounts
`awk -F: '($2 == "") {print}' /etc/shadow`

### Lock any empty password accounts
`passwd -l <username>`

### Review login history
`last -a && lastlog`

### List active processes
`ps aux`

### Find suspicious processes
`ps aux | grep -E 'nc|netcat|bash|python|perl|sh'`

### List running services
`systemctl list-units --type=service --state=running`

### List all services set to start at boot
`systemctl list-unit-files --type=service | grep enabled`

### Disable unnecessary services
`sudo systemctl stop <service_name>`
`sudo systemctl disable <service_name>`

### List all open ports
`sudo netstat -tulnp`
`sudo ss -tulnp`

### Identify processes bound to ports
`sudo lsof -i -P -n`

### Basic Nmap local scan
`sudo apt install -y nmap || sudo yum install -y nmap`
`nmap -sT -O localhost` - Scans only the local system
- Identify local networks and scan accordingly

### Check and configure firewall
Investigate what firewall system is being used, set appropriate firewall rules, only allowing in and out what is neccesary.

### List scheduled tasks
```bash
cat /etc/crontab
ls /etc/cron.d/
ls /etc/cron.{hourly,daily,weekly,monthly}/
ls /var/spool/cron/
ls /var/spool/cron/crontabs/
```

### List systemd timers
`systemctl list-timers --all`

### Check permissions on critical files
`ls -l /etc/*-*`
`stat /etc/*-`

### Find files with SUID bit set
`find / -perm -4000 -type f 2>/dev/null`

### Verify ownership of key binaries
`ls -l /bin/{sudo,bash,sh}`

### Review bash history
`cat ~/.bash_history`
`for user in /home/*; do cat $user/.bash_history; done`

### Check auth logs
`sudo less /var/log/auth.log`
`sudo less /var/log/secure`

### Disable Passwordless root login

`sudo passwd -l root`

### Set password policy pam.d `/etc/pam.d/common-password`

Need to add, have a standard config?

### Set ssh config `/etc/ssh/sshd_config`
* copy config
* restart ssh

### Make critical files immutable (after confirming configs)
```bash sudo chattr +i /etc/passwd
sudo chattr +i /etc/shadow
sudo chattr +i /etc/group
```

# Hour Zero

### Identify all listening services and versions
`sudo nmap -sV localhost`
`sudo nmap -p- 127.0.0.1`

### Identify external hosts in the subnet
`sudo nmap -sn 192.168.0.0/24`
- Resarch unknown ports and services

### Disable or uninstall unneccesary software 
`sudo apt-get remove <pkg>` - purge also works
`sudo yum erase <pkg>`

#### Remove insecure services
`sudo systemctl stop telnet`
`sudo systemctl disable telnet`
`sudo apt-get --purge remove telnet`

### List all installed packages
`dpkg --list`     # Debian/Ubuntu
`yum list installed`  # RHEL/CentOS

### Fail2Ban?

### Apparmor, SeLinux?

### Security Auditing (Load packages manually if needed) - Resarch that procedure
```bash
sudo apt install lynis rkhunter clamav
sudo lynis audit system
sudo rkhunter --check
sudo freshclam && sudo clamscan -r /
```
