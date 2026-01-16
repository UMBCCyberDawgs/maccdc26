`------------------------------------------------------------------------------`  
`|  Cursor parking lot  |     |     |     |     |     |     |     |     |     |   ------------------------------------------------------------------------------`

`Everything below needs to be sorted by priority`

- [ ] Change default passwords \[link to password vault\]
    - [ ] `passwd <user>`
    - [ ] `chpasswd` Type in user:pass format

- [ ] Add/disable users  
    - [ ] `sudo usermod -s /bin/nologin root`
    - [ ] `sudo usermod -s /bin/nologin <username>`

- [ ] Check for UID/GID 0 users /etc/passwd  
    - [ ] `cat /etc/passwd`

- [ ] Check sudoers
    - [ ] `sudo EDITOR=vim visudo`
    - [ ] `%wheel ALL=(ALL:ALL) ALL`
    - [ ] remove any `NOPASSWD`

- [ ] Check systemd services
    - [ ] `sudo systemctl` lists all running services
    - [ ] `sudo systemctl stop <service>`
    - [ ] `sudo systemctl disable <service>`

- [ ] Check cron, systemd timers, at  
    - [ ] `sudo crontab -e` View and edit crontabs
    - [ ] `sudo systemctl stop cron` crond for RHEL
    - [ ] `sudo systemctl disable cron`
    - [ ] `sudo systemctl list-timers --all` lists all timers
    - [ ] `sudo systemctl disable --now <name>.timer` disable timer
    - [ ] `sudo systemctl disable --now atd` disable at

- [ ] Check permissions on critical files  
    - [ ] /etc/passwd  
        - [ ] check for every account with UID 0 that isn't root
        - [ ] `sudo chmod 644 /etc/passwd`

    - [ ] /etc/group
        - [ ] check for every group with GID 0 that isn't root
        - [ ] check for unnecessary users in groups. Especially for groups in sudoers
        - [ ] `sudo groupdel <group>` remove group
        - [ ] `sudo gpasswd -d <user> <group>` Remove user from group
        - [ ] `sudo chmod 644 /etc/group`

    - [ ] /etc/shadow
        - [ ] check for no "long hash value" accounts
        - [ ] `sudo chmod 600 /etc/shadow`

    - [ ] Systemd service files
        - [ ] `sudo chmod 644 /usr/lib/systemd/system/*.service`
        - [ ] `sudo chmod 644 /etc/systemd/system/*.service`
    
    - [ ] /etc/ssh/sshd_config
        - [ ] `PubkeyAuthentication yes` 
        - [ ] `LogLevel VERBOSE`
        - [ ] `PermitRootLogin no`
        - [ ] `PermitEmptyPasswords no`
        - [ ] `ChallengeResponseAuthentication no`
        - [ ] `UsePAM yes`
        - [ ] `PermitUserEnvironment no`
        - [ ] `AllowUsers <user>`

- [ ] immutable files
    - [ ] `chattr +i /etc/passwd`
    - [ ] `chattr +i /etc/shadow`
    - [ ] `chattr +i /etc/group`
    - [ ] `chattr +i /etc/ssh/sshd_config`
    - [ ] `chattr +a -R /var/log`
    - [ ] `chattr -i <filename>` to edit file

- [ ] Check SUID bits and owner/group of important binaries
    - [ ] `sudo find / -perm "/u=s,g=s" -type f 2>/dev/null`

- [ ] Check open ports  
    -[ ] `sudo netstat -tulpn`

- [ ] Check Firewall Rules  
    - [ ] `sudo iptables -L`

- [ ] Basic forensics  
      - [ ] Bash\_history  
        - [ ] `cat .bash_history`
      - [ ] User login history  
        - [ ] `w`, `who`, `last`
      - [ ] SSH logs
        - [ ] `/var/log/auth.log` Debian
        - [ ] `/var/log/secure` RHEL
        - [ ] `sudo journalctl -u sshd`

- [ ] Run script to save state of the system  
      - [ ] List users  
      - [ ] List running processes  
      - [ ] List systemd services  
      - [ ] etc


**Copy paste configurations for these files**

- [ ] Secure SSH config (whitelist, noroot, etc)  
- [ ] Secure PAM config  

\*Create default configs for SSH, PAM, other services (eg databases)

Services

**Firewall**

- [ ] Every team member should write host firewall rules (iptables) when we get blue team packet  
      - [ ] Default deny in  
        - [ ] `iptables -A INPUT -j DROP` only put this all the way at the bottom
      - [ ] Default deny out (but research what does actually need to go out)
        - [ ] `iptables -A OUTPUT -j DROP`
