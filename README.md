This is an ELKS (Linux 8086) port to Lua, with minimal patching. 

How to build?

Lua is built with OWC and soft-fpu. For compiler setup check [here](https://github.com/ghaerr/elks/wiki/Using-OpenWatcom-C-with-ELKS).
To compile run: `make -f Makefile.elks`

Branches are:
https://github.com/rafael2k/lua/tree/lua-5.1 - Lua 5.1.5 with minimal patching to run on ELKS
https://github.com/rafael2k/lua/tree/lua-5.1i - Special integer-only Lua 5.1.5 (does not have most mathlib functions)
https://github.com/rafael2k/lua/tree/master - Tracking PUC-Rio upstream Lua with minimal patching for ELKS port

# Lua

This is the repository of Lua development code, as seen by the Lua team. It contains the full history of all commits but is mirrored irregularly. For complete information about Lua, visit [Lua.org](https://www.lua.org/).

Please **do not** send pull requests. To report issues, post a message to the [Lua mailing list](https://www.lua.org/lua-l.html).

Download official Lua releases from [Lua.org](https://www.lua.org/download.html).
