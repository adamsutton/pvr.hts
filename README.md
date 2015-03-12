# Tvheadend PVR addon
Tvheadend PVR addon for [Kodi] (http://kodi.tv)

## Overview

This addon enables Kodi to communicate with a [tvheadend] (https://tvheadend.org) backend. It communicates with tvheadend using the custom HTSP protocol. The HTSP protocol makes it possible to stream readily demuxed data packets from tvheadend, removing the need for performing the demuxing in Kodi itself. The result is very fast zapping times.

Since HTSP is used, a communication channel is kept open constantly. This means that the server (tvheadend) can push updates and other notifications to the client. What this means for users is that (among other things) EPG updates can be reflected in Kodi as soon as they happen (if "asynchronous EPG transfer" is enabled, see further down), and timer notifications and such will always happen in real-time.

## Settings

Some of the settings are explained in more detail below.

* HTTP port: the HTTP port tvheadend is listening on. This is required since the channel icons are accessed through this port
* HTSP port: the HTSP port tvheadend is listening on. Almost all communication happens on this port, so if you use a tvheadend over the Internet you might want to configure your routers to prioritize traffic on this port to minimize any bandwidth issues.
* Response timeout: the time tvheadend waits for the server to respond to a specific request. Try increasing this if you know you have a lot of channels and they sometimes don't load completely during startup.
* Asynchronous EPG transfer: when this setting is enabled, tvheadend will push any EPG updates to the client as soon as they occur. The addon will then update its internal EPG table and notify Kodi that it needs to update its EPG, ensuring that updates appear as soon as possible.
* Trace debugging. Logs almost everything the addon does, only enable this if someone asks you to!

## Technical overview (mostly for coders)

As with most PVR addons, `client.cpp` is the entry point and functions mainly as a wrapper between the Kodi API and the main addon class, `CTvheadend`. The addon is heavily multi-threaded; all communication with tvheadend happens on a separate thread.

When the addon starts and successfully connects to the server, the server will send details about all the channels, recordings, timers and EPG data. While this initial update is being performed, the addon blocks any calls to methods that require them (e.g. calling `GetChannels` blocks until all the channels have been loaded) until the response timeout is reached.

The main class (`CTvheadend`) delegates certain communications to other classes. Most notable, demuxer messages are delegated to `CHTSPDemuxer`.

##### Useful links

* [Kodi's PVR user support] (http://forum.kodi.tv/forumdisplay.php?fid=167)
* [Kodi's PVR development support] (http://forum.kodi.tv/forumdisplay.php?fid=136)
