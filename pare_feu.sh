cat > /etc/rc.d/init.d/firewall << "EOF"
#!/bin/sh

# Début $rc_base/init.d/firewall

# Insertion des modules de traces de connexion (pas nécessaire si intégrés au
# noyau).
modprobe ip_tables
modprobe iptable_filter
modprobe ip_conntrack
modprobe ip_conntrack_ftp
modprobe ipt_state
modprobe ipt_LOG

# permet les connexions local uniquement
iptables -A INPUT  -i lo -j ACCEPT
# free output on any interface to any ip for any service (equal to -P ACCEPT)
iptables -A OUTPUT -j ACCEPT

# autorise les réponses à des connexions déjà établies
# et permet les nouvelles connexions en relation avec celles déjà établies (par
# exemple active-ftp)
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Enregistre tout le reste:  Quelle est la dernière vulnérabilité de Windows?
iptables -A INPUT -j LOG --log-prefix "FIREWALL:INPUT "

# Met en place une politique saine:    tout ce qui n'est pas accepté > /dev/null
iptables -P INPUT    DROP
iptables -P FORWARD  DROP
iptables -P OUTPUT   DROP

# soit verbeux pour les adresses dynamiques (pas nécessaire dans le cas des adresses IP statiques)
echo 2 > /proc/sys/net/ipv4/ip_dynaddr

# désactive ExplicitCongestionNotification - trop de routeurs les ignorent encore
echo 0 > /proc/sys/net/ipv4/tcp_ecn

# Fin $rc_base/init.d/firewall
EOF