# docker-srt

The SRT protocol itself is UDP based.

When using SRT, there are parameters like `passphrase` and `key_length` that must be negotiated for a stream ahead of time.

This is a simple HTTP+JSON response service that contains SRT configuration parameters if they are defined in the environment before this is run.

# Usage:

On a Mac, you might run:

    $ dns-sd -B _x-srt._udp
    Browsing for _x-srt._udp
    DATE: ---Wed 09 Jan 2019---
    16:56:40.350  ...STARTING...
    Timestamp     A/R    Flags  if Domain               Service Type         Instance Name
    16:56:40.350  Add        2   5 local.               _x-srt._udp.         Outside_North

The above represents an SRT stream that has no passphrase requirement.

    dns-sd -B _x-srt._udp
    dns-sd -B _x-srt._tcp

