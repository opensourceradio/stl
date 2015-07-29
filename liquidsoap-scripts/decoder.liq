#!/usr/bin/liquidsoap

# Log liquidsoap messages to this file
set( "log.file.path", "/var/log/liquidsoap/xmit-decode.log" )

# Use the telnet server for requests
set("server.telnet", true)

# get input from the liquidsoap server in the studio
# swap in your local IP address for the "bind_addr"
set( "harbor.bind_addr", "LOCAL-IP-ADDRESS" )
set( "harbor.port", 8800 )
set( "harbor.password", "super-secure-password" )

# the "icecast" mount point
live = input.harbor( "xmit-stl" )

feed = mksafe ( live )

# An emergency file used in case the input stream fails
emergency = single( "/etc/liquidsoap/technical-difficulties.ogg" )

# fallback
audio = fallback( track_sensitive = false, [feed, emergency] )

# Output to the ALSA audio card
output.ao(
  id = "stl-decode",
  driver = "alsa",
  start = true,
  amplify( 8.0, audio )
)
