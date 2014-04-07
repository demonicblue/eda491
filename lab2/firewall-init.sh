#!/bin/bash -
#

MY_NETWORK="129.16.21.0/24"

# Replace the ip address here with the ip address for your computer.
# You can use the program "/sbin/ifconfig", or "/sbin/ip addr show"
# to obtain the correct address.
MY_HOST="129.16.21.XX" 

# Network devices
IN=eth0
OUT=eth0

# Path to iptables, "/sbin/iptables"
IPTABLES="sudo /sbin/iptables"


######################################################################
### NOTE: FOLLOWING ROLES MUST BE AT THE TOP OF THIS CONFIGURATION ###
###       AND THEY SHOULD NOT BE MODIFIED IN ANY WAY(!)            ###
###       CHANGING ANY OF THESE RULES MAY RESULT IN THAT YOUR      ###
###       MACHINE FREEZES (AS YOUR NFS CONNECTION IS LOST TO YOUR  ###
###       HOME DIRECTORY).                                         ###
######################################################################

# Flushing all chains and setting default rules
$IPTABLES -P INPUT ACCEPT
$IPTABLES -P FORWARD ACCEPT
$IPTABLES -P OUTPUT ACCEPT
$IPTABLES -F
$IPTABLES -F CTH
$IPTABLES -X CTH

# Make sure NFS works (allow traffic to Chalmers)
# If NFS connection is lost, your machine will hang for eternity
$IPTABLES -N CTH
$IPTABLES -A CTH -s 129.16.20.26 -m state --state ESTABLISHED,RELATED -m comment --comment "NFS server soleil" -j ACCEPT
$IPTABLES -A CTH -s 129.16.20.0/23 -m comment --comment "Dont look at CE" -j RETURN
$IPTABLES -A CTH -m state --state ESTABLISHED,RELATED -m comment --comment "Allow the rest to Chalmers" -j ACCEPT

$IPTABLES -A INPUT -i $IN -s 129.16.0.0/16 -m comment --comment "Fix NFS traffic" -j CTH
$IPTABLES -A OUTPUT -o $OUT -d 129.16.0.0/16 -j ACCEPT

$IPTABLES -Z

#########################################
### WRITE YOUR OWN RULES FROM HERE... ###
#########################################


# Kill malformed packets
# Block XMAS packets
$IPTABLES -A INPUT -p tcp --tcp-flags FIN,PSH,URG FIN,PSH,URG -j DROP
$IPTABLES -A FORWARD -p tcp --tcp-flags FIN,PSH,URG FIN,PSH,URG -j DROP
# Block NULL packets
$IPTABLES -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
$IPTABLES -A FORWARD -p tcp --tcp-flags ALL NONE -j DROP


echo "Done!"

