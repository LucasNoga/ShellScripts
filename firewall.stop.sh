cat > /etc/rc.d/init.d/firewall.stop << "EOF"
#!/bin/sh

# Si vous avez besoin d'arrêter votre pare-feu, ce script vous le permettra:

# Début $rc_base/init.d/firewall.stop

# deactivate IP-Forwarding 
echo 0 > /proc/sys/net/ipv4/ip_forward

iptables -Z
iptables -F
iptables -t nat         -F PREROUTING
iptables -t nat         -F OUTPUT
iptables -t nat         -F POSTROUTING
iptables -t mangle      -F PREROUTING
iptables -t mangle      -F OUTPUT
iptables -X
iptables -P INPUT       ACCEPT
iptables -P FORWARD     ACCEPT
iptables -P OUTPUT      ACCEPT
EOF