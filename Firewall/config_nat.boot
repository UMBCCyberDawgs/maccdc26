interfaces {
    ethernet eth0 {
        address 10.67.2.12/16
        description external
        hw-id bc:24:11:5a:3e:77
    }
    ethernet eth1 {
        address 172.16.101.1/24
        description net1
        hw-id bc:24:11:01:4d:85
    }
    ethernet eth2 {
        address 172.16.102.1/24
        description net2
        hw-id bc:24:11:e3:fa:94
    }
    loopback lo {
    }
}
nat {
    source {
        rule 20 {
            outbound-interface eth0
            source {
                address 172.20.242.20
            }
            translation {
                address 172.25.23.9
            }
        }
        rule 30 {
            outbound-interface eth0
            source {
                address 172.20.242.30
            }
            translation {
                address 172.25.23.11
            }
        }
        rule 40 {
            outbound-interface eth0
            source {
                address 172.20.242.40
            }
            translation {
                address 172.25.23.39
            }
        }
        rule 100 {
            outbound-interface eth0
            source {
                address 172.20.240.100
            }
            translation {
                address 172.25.23.144
            }
        }
        rule 101 {
            outbound-interface eth0
            source {
                address 172.20.240.101
            }
            translation {
                address 172.25.23.140
            }
        }
        rule 102 {
            outbound-interface eth0
            source {
                address 172.20.240.102
            }
            translation {
                address 172.25.23.155
            }
        }
        rule 104 {
            outbound-interface eth0
            source {
                address 172.20.240.104
            }
            translation {
                address 172.25.23.162
            }
        }
    }
    static {
        rule 20 {
            inbound-interface eth1
        }
        rule 30 {
            inbound-interface eth1
        }
        rule 40 {
            inbound-interface eth1
        }
        rule 100 {
            inbound-interface eth2
        }
        rule 101 {
            inbound-interface eth2
        }
        rule 102 {
            inbound-interface eth2
        }
        rule 104 {
            inbound-interface eth2
        }
    }
}
protocols {
    static {
        route 0.0.0.0/0 {
            next-hop 10.67.1.1 {
            }
        }
        route 172.20.240.0/24 {
            next-hop 172.16.102.254 {
            }
        }
        route 172.20.242.0/24 {
            next-hop 172.16.101.254 {
            }
        }
        route 172.25.23.0/25 {
            next-hop 172.16.101.254 {
            }
        }
        route 172.25.23.128/25 {
            next-hop 172.16.102.254 {
            }
        }
    }
}
service {
    dns {
        forwarding {
            allow-from 172.20.240.0/24
            listen-address 172.20.240.102
            name-server 10.66.1.2 {
            }
            system
        }
    }
    ntp {
        allow-client {
            address 127.0.0.0/8
            address 169.254.0.0/16
            address 10.0.0.0/8
            address 172.16.0.0/12
            address 192.168.0.0/16
            address ::1/128
            address fe80::/10
            address fc00::/7
        }
        server time1.vyos.net {
        }
        server time2.vyos.net {
        }
        server time3.vyos.net {
        }
    }
}
system {
    config-management {
        commit-revisions 100
    }
    conntrack {
        modules {
            ftp
            h323
            nfs
            pptp
            sip
            sqlnet
            tftp
        }
    }
    console {
        device ttyS0 {
            speed 115200
        }
    }
    host-name vyos
    login {
        user vyos {
            authentication {
                encrypted-password $6$rounds=656000$SJ5iXGxxPERQWvns$R.KnAzHR9B9YgBjUGsczvveQpPMn/JW87c1oVHHJSmSSIDUSn36apze48AAboeTynAg.23YYnDJqbsbRklxRV/
                plaintext-password ""
            }
        }
    }
    name-server 8.8.8.8
    syslog {
        global {
            facility all {
                level info
            }
            facility local7 {
                level debug
            }
        }
    }
}


// Warning: Do not remove the following line.
// vyos-config-version: "bgp@4:broadcast-relay@1:cluster@1:config-management@1:conntrack@3:conntrack-sync@2:container@1:dhcp-relay@2:dhcp-server@6:dhcpv6-server@1:dns-dynamic@1:dns-forwarding@4:firewall@10:flow-accounting@1:https@4:ids@1:interfaces@29:ipoe-server@1:ipsec@12:isis@3:l2tp@4:lldp@1:mdns@1:monitoring@1:nat@5:nat66@1:ntp@3:openconnect@2:ospf@2:policy@5:pppoe-server@6:pptp@2:qos@2:quagga@11:rip@1:rpki@1:salt@1:snmp@3:ssh@2:sstp@4:system@26:vrf@3:vrrp@4:vyos-accel-ppp@2:wanloadbalance@3:webproxy@2"
// Release version: 1.4-rolling-202307271350

