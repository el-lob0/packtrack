# Packtrack

Tracking total internet usage

# Usage

1. git clone then

2. run ``odin build command -build-mode:exe -out:out/packtrack`` 

3. run ``odin build service -build-mode:exe -out:out/packtrack_service``

4. then set ``./out/packtrack_service`` to run on launch in your wm config

5. then to view data run ``./out/packtrack stat``
(put it in a bin PATH for easier use)

6. run ``packtrack setdev <device>`` if your network device name isnt wlan0



