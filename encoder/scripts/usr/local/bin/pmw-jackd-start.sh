#!/bin/zsh

##############################################################################
#
# Query the audio devices and set up jack to start and load the off-board
# sound card(s).
#

##############################################################################
##############################################################################
##############################################################################
###          DO NOT USE THIS SCRIPT WITHOUT MAKING MODIFICATIONS!          ###
##############################################################################
##############################################################################
##############################################################################
#
# NOTE:
# This script is COMPLETELY installation-specific! See the "BUG ALERT" below.
#
# Note your modification acknowledgment here:
# e.g., in vim, say  :map K !!date; logname<CR>A, <Esc>JI# <Esc>A@phantommachineworks.media<Esc>
# then simply touch the 'K' key to 'fill in the blanks'
# for example:
# Mon Nov 16 16:18:57 CST 2015, dklann@phantommachineworks.media

##############################################################################
##############################################################################
#
# BUG ALERT!!
# this script completely depends on the add-on audio adapter being a
# Digigram vx222e audio interface that ALSA identifies as "VX222e0".
#
##############################################################################
##############################################################################

stlInputDevice=${STL_INPUT_DEVICE:-VX222e0}

##############################################################################
#
# log STDOUT and STDERR of this script and all commands called by this
# script to separate files
#
exec 1> /var/tmp/${0##*/}.out
exec 2> /var/tmp/${0##*/}.err

RATE=${RATE:-48000}
PERIODS=${PERIODS:-1024}
NPERIODS=${NPERIODS:-2}

##############################################################################
#
# Use aplay(1) to list the installed audio cards and massage the data
# to get the card numbers. See example output at the end of this
# script.
#
typeset -A jackDevices
# We are looking only for the "primary" instance of each device ("device 0")
aplay -l | grep '^card[[:space:]].*device 0:' | while read line ; do
    thisDeviceID=$(echo ${line} | awk '{print $2}' | tr -d ':')
    thisDeviceName=$(echo ${line} | awk '{print $3}')
    jackDevices+=( ${thisDeviceName} ${thisDeviceID} )
done

##############################################################################
#
# Create the initial jack instance.
#
stlInputIndex=${(v)jackDevices[${stlInputDevice}]}

exec /usr/bin/jackd -r -n default -d alsa -d hw:${stlInputIndex},0 -r ${RATE} -p ${PERIODS} -n ${NPERIODS}

exit

# Example output of
# sudo -u pmwsrv aplay -l (with ARC-8 connected to USB)
cat << EOF
**** List of PLAYBACK Hardware Devices ****
card 0: PCH [HDA Intel PCH], device 0: ALC892 Analog [ALC892 Analog]
  Subdevices: 0/1
  Subdevice #0: subdevice #0
card 0: PCH [HDA Intel PCH], device 1: ALC892 Digital [ALC892 Digital]
  Subdevices: 1/1
  Subdevice #0: subdevice #0
card 1: CODEC [USB Audio CODEC], device 0: USB Audio [USB Audio]
  Subdevices: 0/1
  Subdevice #0: subdevice #0
EOF
# with Digigram vx222e installed
cat <<EOF
**** List of PLAYBACK Hardware Devices ****
card 0: VX222e0 [Digigram VX222e [PCM #0]], device 0: pcxhr 0 [pcxhr 0]
  Subdevices: 4/4
  Subdevice #0: subdevice #0
  Subdevice #1: subdevice #1
  Subdevice #2: subdevice #2
  Subdevice #3: subdevice #3
card 1: PCH [HDA Intel PCH], device 0: ALC662 rev1 Analog [ALC662 rev1 Analog]
  Subdevices: 1/1
  Subdevice #0: subdevice #0
card 1: PCH [HDA Intel PCH], device 3: HDMI 0 [HDMI 0]
  Subdevices: 1/1
  Subdevice #0: subdevice #0
card 1: PCH [HDA Intel PCH], device 7: HDMI 1 [HDMI 1]
  Subdevices: 1/1
  Subdevice #0: subdevice #0
EOF
