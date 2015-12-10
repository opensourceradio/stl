#!/usr/bin/liquidsoap

##############################################################################
##
## Copyright 2015 Phantom Machine Works. See LICENSE for copying information.
##
## Encode from the on-board audio card via JACK, send to stlHost:stlPort
## where there is a listening icecast server.
##
## Note: the password for the source client in the icecast
## configuration MUST match the password used here

## Log dir
set ( "log.file.path", "/var/log/liquidsoap/10-stl-encoder.log" )

## Use the telnet server for run-time access
set ( "server.telnet", true )

## Get input from JACK
## NB: pay attention to JACK connections!
## See /usr/local/bin/pmw-encoder-jack-connect.sh if you make changes here!
feed = input.jack(
  id = "encode-in",
  buffer_size = 1,
  clock_safe = true,
  server = "default"
)

##############################################################################
## Settings used in the output stream
## Note that we connect the source client on TCP port 8080, and the streaming
## clients will connect on TCP port 8000.
stlID   = "PMW stl"
stlProt = "http"
stlHost = "localhost"
stlPort = 8080
stlMnt  = "live"
stlUser = "source"
stlPass = "hiQ8eCDbXyS0txD2GigSZ@3zShh7hD%x"
stlDesc = "KWVH-LP STL"
stlURL  = "http://localhost:8000/live"

## create a new clock that will handle all the stream outputs
clock.assign_new (
  id = "stl",
  sync = true,
  [
    # output the to the transmitter icecast stream server in MP3 format
    output.icecast (
      start = true,
      id = stlID,
      protocol = stlProt,
      host = stlHost,
      port = stlPort,
      user = stlUser,
      password = stlPass,
      mount = stlMnt,
      url = stlURL,
      description = stlDesc,

      # (unlabeled) format:
      # internal_quality: Lame algorithms internal quality. A value
      # between 0 and 9, 0 being highest quality and 9 the worst
      # (default: 2).
      %mp3( samplerate = 48000, stereo = true, bitrate = 320, internal_quality = 1 ),

      # (unlabeled) source:
      # buffer is necessary when using the internal liquidsoap clock
      mksafe( buffer( buffer = 0.5, max = 1.0, feed ))
    )
###
###    # Example of a local OGG Vorbis archive of the audio signal:
###
###    # Create an archive file of the stream
###    #  "/audio/archive/%Y/%m/%d/%H-%M-%S.ogg"
###    #,
###    output.file (
###      id = "archive",
###      append = true,
###
###      # close, then re-open the file at the top of each hour
###      reopen_when = { 0m0s },
###
###      # (unlabeled) format
###      %vorbis( samplerate = 48000, channels = 2, quality = 0.25 ),
###
###      # (unlabeled) filename
###      "/audio/archive/%Y/%m/%d/%H-%M-%S.ogg",
###
###      # (unlabeled) source
###      amplify( 10.0, mksafe( buffer( feed )))
###    )
  ]
)
