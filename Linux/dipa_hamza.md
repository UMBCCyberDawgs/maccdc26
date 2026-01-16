### Create SSH keys and use mozilla ssh config
### Specify keydir and lock write access to keydir
Keygen ssh: `ssh-keygen -t ed25519`  
to log into ssh with a key: `ssh -i /key/location/privatekeyname user@ip`  
copy ur pubkey to server: `ssh-copy-id -i /key/location/privatekeyname user@ip`   
1. Change default creds  
`passwd <user>`  

2. Disable users and add blueteam user  
`sudo usermod -s /bin/nologin root`  
`sudo usermod -s /bin/nologin <username>`  
`sudo usermod -L <username>`  

`sudo useradd bluey`  
`sudo usermod -aG wheel bluey`  

3. Check sudoers  
`sudo EDITOR=vim visudo`  
`%wheel ALL=(ALL:ALL) ALL`  
Remove any NOPASSWD  
Remove any user from sudo/wheel group  
`sudo deluser <username> wheel`  

4. check perms and lock files related to users  
`sudo chattr +i /etc/passwd`  
`sudo chattr +i /etc/group`  
`sudo chattr +i /etc/shadow`  
`sudo chattr +i /etc/ssh/sshd_config`  
`sudo find / -perm "/u=s,g=s" -type f 2>/dev/null` - check SUID bits  

5. Check `/etc/passwd` and `/etc/group` for guid or uid 0 users/groups and other sus content  

6. Check cron/systemd timers/at  
`sudo crontab -e` for root `crontab -e` for user  
Check `/etc` and `grep cron`  
`cat /cron*/*`  
`sudo systemctl list-timers --all`  
`atq` - list at jobs  
`atrm <job_num>` - remove at jobs  

7. Check systemd services  
`sudo systemctl list-units --type=service`  

8. Check open ports  
`sudo netstat -tulpn`  

9. Firewall rules  
`sudo iptables -L --line-numbers`  
`sudo iptables -A INPUT -j DROP` - Default deny in  
`sudo iptables -I INPUT -s 192.168.1.0/24 -p tcp --dport 22 -j ACCEPT` - Example rule  
`sudo iptables -D INPUT 2` - this deletes rule number 2  
`sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1`  
`sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1`  

10. Forensics  
`last -n <number>` - checks last n logins  
`who` - who's currently logged in  
`sudo cat /var/log/secure` or `sudo cat /var/log/auth.log`  
`sudo journalctl -u ssh` - Hamza method  
check kernel modules - baseline  
`lsmod`  
`rmmod` 
`auditctl -l` - list auditd rules  
`auditctl -w /etc/passwd -p wa -k passwd`  
`auditctl -w /etc/shadow -p war -k shadow`  
`auditctl -w /etc/group -p wa -k group`  
`auditctl -w <file> -p wa -k <keyname>`  
`ausearch -i -k <keyname>`  
`auditctl -a always,exit -F euid=0 -F arch=b64 -S execve -k cmd` - root binary run syscalls  
`ausearch -i -k cmd`  

12. PAM  
Baseline all PAM files using default configs on the same distro  
