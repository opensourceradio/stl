#!/usr/bin/liquidsoap

# Copyright 2015 Phantom Machine Works. See LICENSE for copying information.

# Where to store liquidsoap log messages
set( "log.file.path", "/var/log/liquidsoap/xmit-encode.log" )

# Use the telnet server for requests
set( "server.telnet", true )

# Set the frame size
set( "frame.audio.size", 512 )

# Get input from the on-board sound card
# Change the device parameter to match the ALSA device you want to use for audio input
input_audio = input.alsa( bufferize = false, device = "hw:0" )

# Optional: set the ALSA buffer length (in seconds).
# set( "alsa.buffer_length", 2 )

# An emergency file in case the audio card fails
emergency = single( "/etc/liquidsoap/technical-difficulties.ogg" )

# Set "emergency" as a fallback audio source
output_audio = fallback(
  track_sensitive = false,
  [input_audio, emergency]
)

##############################################################
# Output the encoded audio in Vorbis format to the transmitter
clock.assign_new(
  id = "internet",
  sync = true,
  [
    output.icecast(
      id = "stl-encoder",
      start = true,
      restart = true,
      restart_delay = 1,
      host = "stl-decoder",
      port = 8800,
      protocol = "http",
      password = "super-secure-password",
      mount = "xmit-stl",
      description = "Transmitter STL",
      name = "Transmitter STL",
      %vorbis( samplerate = 44100, channels = 2, quality = 0.9 ),
      output_audio
    ),
    # Create an archive file of the stream
    # Ideally this archive is on a file server with lots of free disk space
    #  "/audio/freenas-music/stl-archive/%Y-%m-%d/%H-%M-%S.ogg"
    #  "/var/tmp/stl-archive/%Y-%m-%d/%H-%M-%S.ogg"
    output.file(
      id = "stl-archive",
      append = true,
      # close, then re-open the file at the top of each hour
      reopen_when = { 0m0s },
      %vorbis( samplerate = 44100, channels = 2, quality = 0.25 ),
      "/mnt/stl-archive/%Y-%m-%d/%H-%M-%S.mp3",
      amplify( 10.0, mksafe( buffer( feed )))
    )
  ]
)
