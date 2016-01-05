#!/bin/zsh

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
# Fri Aug 31 13:54:09 CST 1923, dklann@phantommachineworks.media
#

##############################################################################
##############################################################################
#
# BUG ALERT!!
#
# This script completely depends on the audio encoder
# configuration. As of the time of this writing, the encoder is
# liquidsoap, and the encoder configuration is in
# /etc/liquidsoap/10-stl-encoder.liq.
#
##############################################################################
##############################################################################

zmodload zsh/regex

##############################################################################
#
# log STDOUT and STDERR of this script and all commands called by this
# script to separate files
#
exec 1> /var/tmp/${0##*/}.out
exec 2> /var/tmp/${0##*/}.err

# Get the name of the encoder port from the Liquidsoap script.
liquidsoapScript=${LIQUIDSOAP_SCRIPT:-${ROOT:-/}etc/liquidsoap/10-stl-encoder.liq}
encoderID=$(fgrep -A 1 "input.jack" ${liquidsoapScript} | tail -n 1 | cut -d'"' -f2)

# Establish up the port basenames.
systemCaptureBase=${SYSTEM_CAPTURE_BASE:-"system:capture"}
systemPlaybackBase=${SYSTEM_PLAYBACK_BASE:-"system:playback"}
encoderBase=${ENCODER_BASE:-"${encoderID}:in"}
allPorts=( ${systemCaptureBase} ${systemPlaybackBase} ${encoderBase} )

# Attempt to wait until all the ports we are looking for are actually
# ready to be connected.
attemptLimit=10
thisAttempt=1
sleepDuration=0.50

# Initial pause while jackd sets things up.
sleep $(( sleepDuration * 2 ))

while (( thisAttempt < attemptLimit )) ; do
    jackPorts=( $(/usr/bin/jack_lsp) )
    x=0
    for need in ${allPorts} ; do
	found=0
	for port in ${jackPorts} ; do
	    [[ ${port} =~ "${need}_\d+" ]] && { (( x++ )) ; found=1; }
	done
	
	(( found )) && break
    done
    if (( x == ${#allPorts} )) ; then
	: ports are connected, we are good to go
	break
    fi
    sleep ${sleepDuration}
    (( thisAttempt++ ))
done

if (( thisAttempt < attemptLimit )) ; then
    # Connect the sound card the to encoder.
    jack_connect ${systemCaptureBase}_1 ${encoderBase}_0
    jack_connect ${systemCaptureBase}_2 ${encoderBase}_1

    # Connect the sound card input to its output (for monitoring).
    jack_connect ${systemCaptureBase}_1 ${systemPlaybackBase}_1
    jack_connect ${systemCaptureBase}_2 ${systemPlaybackBase}_2

    exitValue=0
else
    echo "JACK ports were not ready after waiting $(( attemptLimit * sleepDuration )) seconds. Contact Support." 2>&1
    exitValue=1
fi

exit ${exitValue}
