Run script to save state of the system

- Change default passwords [link to password vault]
`sudo passwd <username>`
- Check service account shells /etc/passswd (verify binaries)
`sudo cat /etc/passwd`
- Test for any passwordless logins
`su <username>`
- Check for UID/GID 0 users /etc/passwd
`sudo cat /etc/passwd`
- Check cron, systemd timers, at
```bash
# Crontabs
cat /etc/crontab
cat /cron*/*

# Systemd timers
systemctl list-timers --all

# at pending jobs
atq
```
- Check Firewall Rules
```bash
# Check status of each firewall
sudo ufw status
sudo systemctl status firewalld
sudo iptables -L # lists all active rules

# disable ipv6 temporarily
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
```
- Check open ports
`sudo ss -tulpn`
- Check permissions on critical files
        - /etc/passwd
        `ls -l /etc/passwd`
        - /etc/group
        `ls -l /etc/group`
        - /etc/shadow
        `ls -l /etc/shadow`
- Systemd service files
```bash
# Difficult to read each file, can check for last edit with
stat /etc/systemd/system/* | grep Change # this is for only one of the systemd directories
```
- Check SUID bits and owner/group of important binaries
        - /bin/sudo
        - /bin/bash (other shells too)
`find / -perm -u=s -type f 2>/dev/null # Checks all executables with SUID bit set`
- Check systemd services
`systemctl list-units --type=service`

- Basic forensics
        - bash_history
`sudo cat /root/.bash_history && sudo cat /home/*/.bash_history`
        - user login history
```bash
# Check user login history
last -n <number>
# Check who is currently logged in
who
```
        - SSH logs
``sudo journalctl -u ssh

- Add/disable users
```bash
sudo useradd <username>
# Lock account
sudo usermod -L <username>
```
- Manage user permission level
```bash
# Remove from sudo/wheel group
sudo deluser <username> sudo # use wheel instead of sudo for fedora-family distros

# Adding to group
sudo usermod -aG <groupname> <username>
# Removing from group
sudo deluser <username> <groupname>
```

- **Set password policy (min/max age, expiration, etc)**
- Disable passwordless root
`# Remove instances of NOPASSWD in sudoers file`
- Disable root login
`Change root's shell to "/sbin/nologin" in /etc/passwd

- **Copy paste configurations for these files**
        - **Secure SSH config (whitelist, noroot, etc)**
`PermitRootLogin no` and restart sshd
        **- Secure PAM config**
        **- sudoers**
`sudo visudo`
