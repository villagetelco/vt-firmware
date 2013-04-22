echo "Starting dhcp client in 10 seconds. This will not change the device configuration."
echo "If you are disconnected, statically configure your workstation to use"
echo "IP 172.31.255.253 NETMASK 255.255.255.252 and connect to 172.31.255.254"
echo "- thats the fallback IP setting of the Mesh-Potato." 

udhcpc -i eth0 



