BRIDGE_NAME=switch
ETH_IF=$(ifconfig | grep -oE "^e(m|th)[0-9]")

#ifcfg-eth0
#sed -i 's/^BOOTPROTO=dhcp$/BOOTPROTO=none/g' /etc/sysconfig/network-scripts/ifcfg-$ETH_IF
sed -i '/^BOOTPROTO/d' /etc/sysconfig/network-scripts/ifcfg-$ETH_IF
echo "BRIDGE=switch">>/etc/sysconfig/network-scripts/ifcfg-$ETH_IF
#ifcfg-br0
echo "DEVICE=$BRIDGE_NAME
BOOTPROTO=dhcp
ONBOOT=yes
TYPE=Bridge">>/etc/sysconfig/network-scripts/ifcfg-br0

