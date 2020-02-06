cat > /etc/rc.d/init.d/firewall << "EOF"
#!/bin/sh

# Début $rc_base/init.d/firewall

echo
echo "You're using the example-config for a setup of a firewall"
echo "from the firewalling-hint written for LinuxFromScratch."
echo "This example is far from being complete, it is only meant"
echo "to be a reference."
echo "Firewall security is a complex issue, that exceeds the scope"
echo "of the quoted configuration rules."
echo "You can find some quite comprehensive information"
echo "about firewalling in Chapter 4 of the BLFS book."
echo "http://beyond.linuxfromscratch.org/"
echo

# Insert iptables modules (not needed if built into the kernel).

modprobe ip_tables
modprobe iptable_filter
modprobe ip_conntrack
modprobe ip_conntrack_ftp
modprobe ipt_state
modprobe iptable_nat
modprobe ip_nat_ftp
modprobe ipt_MASQUERADE
modprobe ipt_LOG
modprobe ipt_REJECT

# allow local-only connections
iptables -A INPUT  -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# allow forwarding
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state NEW -i ! ppp+	 -j ACCEPT

# do masquerading    (not needed if intranet is not using private ip-addresses)
iptables -t nat -A POSTROUTING -o ppp+ -j MASQUERADE

# Log everything for debugging (last of all rules, but before DROP/REJECT)
iptables -A INPUT   -j LOG --log-prefix "FIREWALL:INPUT  "
iptables -A FORWARD -j LOG --log-prefix "FIREWALL:FORWARD"
iptables -A OUTPUT  -j LOG --log-prefix "FIREWALL:OUTPUT "

# set a sane policy
iptables -P INPUT   DROP
iptables -P FORWARD DROP
iptables -P OUTPUT  DROP

# be verbose on dynamic ip-addresses (not needed in case of static IP)
echo 2 > /proc/sys/net/ipv4/ip_dynaddr

# disable ExplicitCongestionNotification
echo 0 > /proc/sys/net/ipv4/tcp_ecn

# activate TCPsyncookies
echo 1 > /proc/sys/net/ipv4/tcp_syncookies

# activate Route-Verification = IP-Spoofing_protection
for f in /proc/sys/net/ipv4/conf/*/rp_filter; do
	echo 1 > $f
done

# activate IP-Forwarding 
echo 1 > /proc/sys/net/ipv4/ip_forward
EOF