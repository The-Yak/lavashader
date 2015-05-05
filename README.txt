# lavashader
lava shader for SpringRTS

How do I use this shit in my map?
-----------
Just extract the .7z into your map folder. That's all, works out of the box. Set voidwater=0 in your mapconfig or you will see water flicker above lava on some settings.


How do I change the lavatexture?
-----------
Find all instances of lavacolor3.png in lava gadget and change to desired image (make sure it's in /LuaRules/images/). One changes texture for GLSL shader and one for fallback mode.


Can I change the height of the lavaplane?
-----------
Yes, just change lavaLevel, but this will break hover playability. Right now it is set equal to waterlevel.


Can this extend beyond map edges/onto an infinite plane?
-----------
As of version 2.2, somewhat, not an infinite plane but a large one
