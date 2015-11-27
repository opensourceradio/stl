#!/bin/zsh

trap "" 2 3

# The primary interface is the interface with which the default route
# is associated.
primaryInterface=${PRIMARY_INTERFACE:-$(ip route | awk '/^default/{print $5}')}

typeset -a menu command
menu=(
    "Show active network interfaces"
    "Show MAC address for ${primaryInterface}"
    "Show IP address for ${primaryInterface}"
    "Show JACK status"
    "Show Encoder (Liquidsoap) status"
    "Show Icecast status"
)
command=(
    "ip link show up"
    "cat /sys/class/net/${primaryInterface}/address"
    "ip -o -4 addr show dev ${primaryInterface} | awk '/ inet /{print \$4}' | cut -d/ -f1"
    "systemctl status jackd@pmwsrv.service"
    "systemctl status liquidsoap@pmwsrv.service"
    "systemctl status icecast2.service"
)

while : ; do
    count=1
    for menuItem in ${menu} ; do
	echo "${count}) ${menuItem}"
	(( count++ ))
    done
    echo "\ns) Escape this menu and start a shell"
    echo "q) Quit and log out"

    read choice\?"Enter your choice: "

    echo

    if (( choice > 1 && choice < count )) ; then
	eval $(echo ${command[${choice}]})
    elif [[ "${choice}" =~ 'q' ]] ; then
	 exit
    elif [[ "${choice}" =~ 's' ]] ; then
	${SHELL} -i
    elif [[ -z "${choice}" ]] ; then
	echo "Please enter a number, 'q' to quit or 's' for a shell."
    else
	echo "Did not understand '${choice}'. Please enter a number, 'q' to quit or 's' for a shell."
    fi

    echo

    read -q choice\?"Press any key to continue: "
    echo
done
