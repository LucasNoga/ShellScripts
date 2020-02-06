cat > /etc/rc.d/init.d/firewall.status << "EOF"
#!/bin/sh

# Si vous souhaitez jeter un oeil sur les chaînes de votre pare-feu et l'ordre dans lesquelles elles prendront effet:

# Début $rc_base/init.d/firewall.status

echo "iptables.mangling:"
iptables -t mangle  -v -L -n --line-numbers

echo
echo "iptables.nat:"
iptables -t nat	    -v -L -n --line-numbers

echo
echo "iptables.filter:"
iptables	    -v -L -n --line-numbers
EOF