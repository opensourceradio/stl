#!/bin/zsh

trap "" 2 3

typeset -a menu command
typeset -R 2 count

while : ; do
    count=0

    # The primary interface is the interface with which the default route
    # is associated.
    primaryInterface=${PRIMARY_INTERFACE:-$(ip route | awk '/^default/{print $5}')}

    menu=(
	"Quit and log out"
	"Show active network interfaces"
	"Show MAC address for \${primaryInterface}"
	"Show IP address for \${primaryInterface}"
	"Show JACK status"
	"Show Liquidsoap status"
	"Show Icecast status"
    )
    # Note: We start with the first actual menu choice here even
    # though the menu starts with "Quit". This is due to the ZSH
    # arrays being 1-based rather than 0-based.
    command=(
	"ip link show up"
	"cat /sys/class/net/\${primaryInterface}/address"
	"ip -o -4 addr show dev \${primaryInterface} | awk '/ inet /{print \$4}' | cut -d/ -f1"
	"systemctl status jackd@pmwsrv.service"
	"systemctl status liquidsoap@pmwsrv.service"
	"systemctl status icecast2.service"
    )

    for menuItem in ${menu} ; do
	echo "${count}) $(eval echo ${menuItem})"
	(( count++ ))
    done
    echo 

    read choice\?"Type your choice and press <Enter>: "

    echo

    if [[ -z "${choice}" ]] ; then
	echo "Please enter a number between 0 and $(( count - 1 ))."
    elif [[ "${choice}" =~ '[[:space:]]*[Ss][Hh][Ee][Ll]{1,2}$' ]] ; then
	echo "Launching a 'shell'. Press <Ctrl-D> or type the word 'exit' to quit the shell.\n"
	${SHELL} -i -f
    elif [[ "${choice}" =~ '[[:space:]]*[[:alpha:]]{1,}' ]] ; then
	echo "'${choice}' is not an option. Please enter a number between 0 and $(( count - 1 ))."
    elif [[ "${choice}" =~ '[[:space:]]*[[:alnum:]]+[[:space:]]+' ]] ; then
	echo "'${choice}' is not an option. Please enter a number between 0 and $(( count - 1 ))."
    elif (( choice == 0 )) ; then
	exit
    elif (( choice > 0 && choice < count )) ; then
	eval $(echo ${command[${choice}]})
    else
	echo "'${choice}' is not an option. Please enter a number between 0 and $(( count - 1 ))."
    fi

    echo

    read -q choice\?"Press any key to continue: "
    echo
done
