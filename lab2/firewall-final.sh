#!/bin/bash -
#

MY_NETWORK="129.16.23.0/24"

# Replace the ip address here with the ip address for your computer.
# You can use the program "/sbin/ifconfig", or "/sbin/ip addr show"
# to obtain the correct address.
MY_HOST="129.16.23.133" 

# Network devices
IN=em1
OUT=em1

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
$IPTABLES -A CTH -s 129.16.20.0/22 -m comment --comment "Dont look at CE" -j RETURN
$IPTABLES -A CTH -m state --state ESTABLISHED,RELATED -m comment --comment "Allow the rest to Chalmers" -j ACCEPT

$IPTABLES -A INPUT -i $IN -s 129.16.0.0/16 -m comment --comment "Fix NFS traffic" -j CTH
$IPTABLES -A OUTPUT -o $OUT -d 129.16.0.0/16 -j ACCEPT

$IPTABLES -Z

#########################################
### WRITE YOUR OWN RULES FROM HERE... ###
#########################################
$IPTABLES -F LOG_DROP
$IPTABLES -X LOG_DROP

$IPTABLES -N LOG_DROP
$IPTABLES -A LOG_DROP -j LOG
$IPTABLES -A LOG_DROP -j DROP

$IPTABLES -P INPUT DROP
$IPTABLES -P FORWARD DROP
$IPTABLES -P OUTPUT DROP
# Kill malformed packets
# Block XMAS packets
$IPTABLES -A INPUT -p tcp --tcp-flags FIN,PSH,URG FIN,PSH,URG -j DROP
$IPTABLES -A FORWARD -p tcp --tcp-flags FIN,PSH,URG FIN,PSH,URG -j DROP
# Block NULL packets
$IPTABLES -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
$IPTABLES -A FORWARD -p tcp --tcp-flags ALL NONE -j DROP

$IPTABLES -A OUTPUT -o lo -j ACCEPT    			#ACCEPT all loopback traffic
$IPTABLES -A INPUT -i lo -j ACCEPT 				#ACCEPT all loopback traffic
$IPTABLES -A INPUT -s 10.0.0.0/8 -j LOG_DROP 		#LOG and DROP private address traffic
$IPTABLES -A INPUT -s 172.16.0.0/12 -j LOG_DROP		#LOG and DROP private address traffic
$IPTABLES -A INPUT -s 192.168.0.0/16 -j LOG_DROP	#LOG and DROP private address traffic
$IPTABLES -A INPUT -s 169.254.0.0/16 -j LOG_DROP	#LOG and DROP private address traffic
$IPTABLES -A OUTPUT -s 10.0.0.0/8 -j LOG_DROP 		#LOG and DROP private address traffic
$IPTABLES -A OUTPUT -s 172.16.0.0/12 -j LOG_DROP	#LOG and DROP private address traffic
$IPTABLES -A OUTPUT -s 192.168.0.0/16 -j LOG_DROP	#LOG and DROP private address traffic
$IPTABLES -A OUTPUT -s 169.254.0.0/16 -j LOG_DROP	#LOG and DROP private address traffic

$IPTABLES -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s -j ACCEPT #Ping flood block
$IPTABLES -A INPUT -p icmp --icmp-type echo-request -j DROP					   #Ping flood block

$IPTABLES -A OUTPUT -o $OUT -j ACCEPT 			#ACCEPT outgoing traffic
$IPTABLES -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT #Accept all established TCP connections

$IPTABLES -A INPUT -p tcp --dport ssh -j ACCEPT		#ACCEPT application ssh
$IPTABLES -A INPUT -p tcp --dport 8080 -j ACCEPT	#ACCEPT application web server
$IPTABLES -A INPUT -p tcp --dport 111 -j ACCEPT		#ACCEPT application rpc-bind
$IPTABLES -A INPUT -p udp --dport 111 -j ACCEPT		#ACCEPT application rpc-bind

$IPTABLES -A INPUT -p tcp -j LOG					#LOG all incoming TCP connections that did not match the other rules
$IPTABLES -A INPUT -p udp -j LOG					#LOG all incoming UDP connections that did not match the other rules
$IPTABLES -A INPUT -p icmp -j LOG					#LOG all incoming ICMP, connections that did not match the other rules


$IPTABLES -A OUTPUT -p tcp -j LOG					#LOG all outgoing TCP connections that did not match the other rules
$IPTABLES -A OUTPUT -p udp -j LOG					#LOG all outgoing UDP connections that did not match the other rules
$IPTABLES -A OUTPUT -p icmp -j LOG					#LOG all outgoing ICMP, connections that did not match the other rules

echo "Done!"

