#!/usr/bin/liquidsoap

# encode from the on-board audio card send to audio.wdrt.org:8800, and
# create an icecast stream for the archive server at localhost:8800

# Log dir
set ( "log.file.path", "/var/log/liquidsoap/10-wdrt-stream-encoder.log" )

# Use the telnet server for requests
set ( "server.telnet", true )

# Set correct frame size:
set( "frame.audio.size", 512 )
# set( "frame.audio.size",1024 )

# get input from the on-board sound card
feed = input.alsa( bufferize=false, device="hw:0" )

# create a new clock that will handle all the stream outputs
clock.assign_new (
  id = "internet",
  sync = true,
  [
    # output the to the public stream server in OGG format
    output.icecast (
      id = "internet",
      start = true,
      host = "audio.wdrt.org",
      port = 8800,
      protocol = "http",
      password = "dr1$()urc3",
      public = true,
      mount = "driftless.ogg",
      url = "http://www.wdrt.org/",
      description = "WDRT 91.9fm",
      genre = "Community",
      name = "WDRT",

      # (unlabeled) format
      %vorbis( samplerate = 44100, channels = 2, quality = 0.5 ),

      # (unlabeled) source
      mksafe( buffer( feed ))
    ),
    # output the to the NEW (as of 2014-02-10) public stream server at OVH in OGG format
    output.icecast (
      id = "internet-ovh",
      start = true,
      host = "audio-ovh.wdrt.org",
      port = 8800,
      protocol = "http",
      password = "dr1$()urc3",
      public = true,
      mount = "driftless.ogg",
      url = "http://www.wdrt.org/",
      description = "WDRT 91.9fm",
      genre = "Community",
      name = "WDRT",

      # (unlabeled) format
      %vorbis( samplerate = 44100, channels = 2, quality = 0.5 ),

      # (unlabeled) source
      mksafe( buffer( feed ))
    ),
    # output the stream in 128-bit MP3 format to the archive server
    # note that the public stream server amplifies the stream; we do that
    # here for the archive stream
    output.icecast (
      id = "archive",
      start = true,
      host = "localhost",
      port = 8800,
      protocol = "http",
      password = "dr1$()urc3",
      public = false,
      mount = "high",
      url = "http://wdrt.org/",
      description = "WDRT 91.9fm",
      genre = "Community",
      name = "WDRT",

      # (unlabeled) format
      %mp3.cbr ( stereo = true, samplerate = 44100, bitrate = 128 ),

      # (unlabeled) source
      amplify( 8.0, mksafe( buffer( feed )))
    ),

    # Create an archive file of the stream
    #  "/audio/freenas-music/wdrt-archive/%Y-%m-%d/%H-%M-%S.ogg"
    #  "/var/tmp/wdrt-archive/%Y-%m-%d/%H-%M-%S.ogg"
    output.file (
      id = "archive",
      append = true,

      # close, then re-open the file at the top of each hour
      reopen_when = { 0m0s },

      # save as MP3 rather than Vorbis to facilitate archive uploads to the website
      # 2013-08-23, dklann@wdrt.org (former settings preserved here for posterity)
      # (unlabeled) format
      # %vorbis( samplerate = 44100, channels = 2, quality = 0.25 ),

      # (unlabeled) format
      %mp3.cbr( bitrate = 96 ),

      # (unlabeled) filename
      "/mnt/wdrt-archive/%Y-%m-%d/%H-%M-%S.mp3",
      # "/mnt/wdrt-archive/%Y-%m-%d/%H-%M-%S.ogg",
      # "/home/liquidsoap/wdrt-archive/%Y-%m-%d/%H-%M-%S.ogg",

      # (unlabeled) source
      amplify( 10.0, mksafe( buffer( feed )))
    )

# Break glass in case of emergency
# ,
########################################################
# Using a new clock, output the full stream in OGG format
#    output.icecast (
#      id = "1",
#      start = true,
#      restart = true,
#      restart_delay = 1,
#      host = "10.10.1.6",
#      port = 8800,
#      protocol = "http",
#      password = "dr1$()urc3",
#      public = true,
#      mount = "wdrt.ogg",
#      url = "http://www.wdrt.org/",
#      description = "WDRT 91.9fm",
#      genre = "Community",
#      name = "WDRT",
#
#      # (unlabled) format
#      %vorbis( samplerate = 44100, channels = 2, quality = 0.9 ),
#
#      # (unlabeled) source
#      mksafe( buffer( feed ))
#    )
  ]
)
