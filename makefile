##############################################################################
#                                                                            #
# Standard rulesets for use when compiling ELKS applications.                #
#                                                                            #
# This file should be included in every Makefile below elkscmd/ via e.g.:    #
#   BASEDIR=..                                                               #
#   include $(BASEDIR)/Makefile-rules                                        #
#                                                                            #
##############################################################################

ifndef TOPDIR
$(error TOPDIR is not defined)
endif

include $(TOPDIR)/Make.defs

##############################################################################
#
# It is not normally necessary to make changes below this line.
#
# Specify directories.

ELKS_DIR=$(TOPDIR)/elks
ELKSCMD_DIR=$(TOPDIR)/elkscmd

INCLUDES=-I$(TOPDIR)/include -I$(TOPDIR)/libc/include -I$(ELKS_DIR)/include

##############################################################################
#
# Determine the ELKS kernel version.

E_V=$(shell if [ -f $(ELKS_DIR)/Makefile-rules ]; then \
		grep -v '^\#' $(ELKS_DIR)/Makefile-rules \
		    | fgrep = | head -4 | tr '\#' = | cut -d = -f 2 ;\
	    else echo Version not known ; fi)

ELKS_VSN=$(shell printf '%s.%s.%s%s' $(E_V))

##############################################################################
#
# Compiler variables for programs to be compiled as host applications.
HOSTCC = gcc
HOSTCFLAGS = -O3

##############################################################################
#
# Compiler variables for programs cross-compiled for ELKS.

CLBASE =  -mcmodel=medium -melks-libc -mtune=i8086 -Wall -Os
CLBASE += -msegment-relocation-stuff -ffunction-sections
CLBASE += -fno-inline -fno-builtin-printf -fno-builtin-fprintf
#CLBASE += -mregparmcall
ifeq ($(CONFIG_APPS_FTRACE), y)
    CLBASE += -fno-omit-frame-pointer -fno-optimize-sibling-calls
    CLBASE += -finstrument-functions-simple -maout-symtab
endif

# temporarily turn off typical non-K&R warnings for now
WARNINGS = -Wno-implicit-int
# temporarily turn off suggesting parenthesis around assignment used as truth value
WARNINGS += -Wno-parentheses

CC=ia16-elf-gcc
AS=ia16-elf-as
LD=ia16-elf-gcc

# LOCALFLAGS=-DLUA_USE_POSIX

CFLAGS =  $(CLBASE) $(WARNINGS) $(LOCALFLAGS) $(INCLUDES)
CFLAGS += -Wextra -Wtype-limits -Wno-unused-parameter -Wno-sign-compare -Wno-empty-body
CFLAGS += -D__ELKS__ -DELKS_VERSION=\"$(ELKS_VSN)\"
ASFLAGS = -mtune=i8086 --32-segelf
LDFLAGS = $(CLBASE)


# Some useful compiler options for internal tests:
# -DLUAI_ASSERT turns on all assertions inside Lua.
# -DHARDSTACKTESTS forces a reallocation of the stack at every point where
# the stack can be reallocated.
# -DHARDMEMTESTS forces a full collection at all points where the collector
# can run.
# -DEMERGENCYGCTESTS forces an emergency collection at every single allocation.
# -DEXTERNMEMCHECK removes internal consistency checking of blocks being
# deallocated (useful when an external tool like valgrind does the check).
# -DMAXINDEXRK=k limits range of constants in RK instruction operands.
# -DLUA_COMPAT_5_3

# -pg -malign-double
# -DLUA_USE_CTYPE -DLUA_USE_APICHECK

# The following options help detect "undefined behavior"s that seldom
# create problems; some are only available in newer gcc versions. To
# use some of them, we also have to define an environment variable
# ASAN_OPTIONS="detect_invalid_pointer_pairs=2".
# -fsanitize=undefined
# -fsanitize=pointer-subtract -fsanitize=address -fsanitize=pointer-compare
# TESTS= -DLUA_USER_H='"ltests.h"' -Og -g


LOCAL = $(TESTS) $(CWARNS)


# To enable Linux goodies, -DLUA_USE_LINUX
# For C89, "-std=c89 -DLUA_USE_C89" -std=c99 -DLUA_USE_LINUX
# Note that Linux/Posix options are not compatible with C89
# MYCFLAGS= $(LOCAL)
MYLDFLAGS= $(LOCAL) $(LDFLAGS) -Wl,-E
# MYLIBS= -ldl

AR= ia16-elf-ar rc
RANLIB= ia16-elf-ranlib
RM= rm -f



# == END OF USER SETTINGS. NO NEED TO CHANGE ANYTHING BELOW THIS LINE =========


# LIBS = -lm

CORE_T=	liblua.a
CORE_O=	lapi.o lcode.o lctype.o ldebug.o ldo.o ldump.o lfunc.o lgc.o llex.o \
	lmem.o lobject.o lopcodes.o lparser.o lstate.o lstring.o ltable.o \
	ltm.o lundump.o lvm.o lzio.o ltests.o
AUX_O=	lauxlib.o
LIB_O=	lbaselib.o ldblib.o liolib.o lmathlib.o loslib.o ltablib.o lstrlib.o \
	lutf8lib.o loadlib.o lcorolib.o linit.o

LUA_T=	lua
LUA_O=	lua.o


ALL_T= $(CORE_T) $(LUA_T)
ALL_O= $(CORE_O) $(LUA_O) $(AUX_O) $(LIB_O)
ALL_A= $(CORE_T)

all:	$(ALL_T)
	touch all

o:	$(ALL_O)

a:	$(ALL_A)

$(CORE_T): $(CORE_O) $(AUX_O) $(LIB_O)
	$(AR) $@ $?
	$(RANLIB) $@

$(LUA_T): $(LUA_O) $(CORE_T)
	$(CC) -o $@ $(MYLDFLAGS) $(LUA_O) $(CORE_T) $(LIBS) $(MYLIBS) $(DL)


clean:
	$(RM) $(ALL_T) $(ALL_O)

depend:
	@$(CC) $(CFLAGS) -MM *.c

echo:
	@echo "CC = $(CC)"
	@echo "CFLAGS = $(CFLAGS)"
	@echo "AR = $(AR)"
	@echo "RANLIB = $(RANLIB)"
	@echo "RM = $(RM)"
	@echo "MYCFLAGS = $(MYCFLAGS)"
	@echo "MYLDFLAGS = $(MYLDFLAGS)"
	@echo "MYLIBS = $(MYLIBS)"
	@echo "DL = $(DL)"

$(ALL_O): makefile ltests.h

# DO NOT EDIT
# automatically made with 'gcc -MM l*.c'

lapi.o: lapi.c lprefix.h lua.h luaconf.h lapi.h llimits.h lstate.h \
 lobject.h ltm.h lzio.h lmem.h ldebug.h ldo.h lfunc.h lgc.h lstring.h \
 ltable.h lundump.h lvm.h
lauxlib.o: lauxlib.c lprefix.h lua.h luaconf.h lauxlib.h llimits.h
lbaselib.o: lbaselib.c lprefix.h lua.h luaconf.h lauxlib.h lualib.h \
 llimits.h
lcode.o: lcode.c lprefix.h lua.h luaconf.h lcode.h llex.h lobject.h \
 llimits.h lzio.h lmem.h lopcodes.h lparser.h ldebug.h lstate.h ltm.h \
 ldo.h lgc.h lstring.h ltable.h lvm.h lopnames.h
lcorolib.o: lcorolib.c lprefix.h lua.h luaconf.h lauxlib.h lualib.h \
 llimits.h
lctype.o: lctype.c lprefix.h lctype.h lua.h luaconf.h llimits.h
ldblib.o: ldblib.c lprefix.h lua.h luaconf.h lauxlib.h lualib.h llimits.h
ldebug.o: ldebug.c lprefix.h lua.h luaconf.h lapi.h llimits.h lstate.h \
 lobject.h ltm.h lzio.h lmem.h lcode.h llex.h lopcodes.h lparser.h \
 ldebug.h ldo.h lfunc.h lstring.h lgc.h ltable.h lvm.h
ldo.o: ldo.c lprefix.h lua.h luaconf.h lapi.h llimits.h lstate.h \
 lobject.h ltm.h lzio.h lmem.h ldebug.h ldo.h lfunc.h lgc.h lopcodes.h \
 lparser.h lstring.h ltable.h lundump.h lvm.h
ldump.o: ldump.c lprefix.h lua.h luaconf.h lapi.h llimits.h lstate.h \
 lobject.h ltm.h lzio.h lmem.h lgc.h ltable.h lundump.h
lfunc.o: lfunc.c lprefix.h lua.h luaconf.h ldebug.h lstate.h lobject.h \
 llimits.h ltm.h lzio.h lmem.h ldo.h lfunc.h lgc.h
lgc.o: lgc.c lprefix.h lua.h luaconf.h ldebug.h lstate.h lobject.h \
 llimits.h ltm.h lzio.h lmem.h ldo.h lfunc.h lgc.h llex.h lstring.h \
 ltable.h
linit.o: linit.c lprefix.h lua.h luaconf.h lualib.h lauxlib.h llimits.h
liolib.o: liolib.c lprefix.h lua.h luaconf.h lauxlib.h lualib.h llimits.h
llex.o: llex.c lprefix.h lua.h luaconf.h lctype.h llimits.h ldebug.h \
 lstate.h lobject.h ltm.h lzio.h lmem.h ldo.h lgc.h llex.h lparser.h \
 lstring.h ltable.h
lmathlib.o: lmathlib.c lprefix.h lua.h luaconf.h lauxlib.h lualib.h \
 llimits.h
lmem.o: lmem.c lprefix.h lua.h luaconf.h ldebug.h lstate.h lobject.h \
 llimits.h ltm.h lzio.h lmem.h ldo.h lgc.h
loadlib.o: loadlib.c lprefix.h lua.h luaconf.h lauxlib.h lualib.h \
 llimits.h
lobject.o: lobject.c lprefix.h lua.h luaconf.h lctype.h llimits.h \
 ldebug.h lstate.h lobject.h ltm.h lzio.h lmem.h ldo.h lstring.h lgc.h \
 lvm.h
lopcodes.o: lopcodes.c lprefix.h lopcodes.h llimits.h lua.h luaconf.h \
 lobject.h
loslib.o: loslib.c lprefix.h lua.h luaconf.h lauxlib.h lualib.h llimits.h
lparser.o: lparser.c lprefix.h lua.h luaconf.h lcode.h llex.h lobject.h \
 llimits.h lzio.h lmem.h lopcodes.h lparser.h ldebug.h lstate.h ltm.h \
 ldo.h lfunc.h lstring.h lgc.h ltable.h
lstate.o: lstate.c lprefix.h lua.h luaconf.h lapi.h llimits.h lstate.h \
 lobject.h ltm.h lzio.h lmem.h ldebug.h ldo.h lfunc.h lgc.h llex.h \
 lstring.h ltable.h
lstring.o: lstring.c lprefix.h lua.h luaconf.h ldebug.h lstate.h \
 lobject.h llimits.h ltm.h lzio.h lmem.h ldo.h lstring.h lgc.h
lstrlib.o: lstrlib.c lprefix.h lua.h luaconf.h lauxlib.h lualib.h \
 llimits.h
ltable.o: ltable.c lprefix.h lua.h luaconf.h ldebug.h lstate.h lobject.h \
 llimits.h ltm.h lzio.h lmem.h ldo.h lgc.h lstring.h ltable.h lvm.h
ltablib.o: ltablib.c lprefix.h lua.h luaconf.h lauxlib.h lualib.h \
 llimits.h
ltests.o: ltests.c lprefix.h lua.h luaconf.h lapi.h llimits.h lstate.h \
 lobject.h ltm.h lzio.h lmem.h lauxlib.h lcode.h llex.h lopcodes.h \
 lparser.h lctype.h ldebug.h ldo.h lfunc.h lopnames.h lstring.h lgc.h \
 ltable.h lualib.h
ltm.o: ltm.c lprefix.h lua.h luaconf.h ldebug.h lstate.h lobject.h \
 llimits.h ltm.h lzio.h lmem.h ldo.h lgc.h lstring.h ltable.h lvm.h
lua.o: lua.c lprefix.h lua.h luaconf.h lauxlib.h lualib.h llimits.h
lundump.o: lundump.c lprefix.h lua.h luaconf.h ldebug.h lstate.h \
 lobject.h llimits.h ltm.h lzio.h lmem.h ldo.h lfunc.h lstring.h lgc.h \
 ltable.h lundump.h
lutf8lib.o: lutf8lib.c lprefix.h lua.h luaconf.h lauxlib.h lualib.h \
 llimits.h
lvm.o: lvm.c lprefix.h lua.h luaconf.h lapi.h llimits.h lstate.h \
 lobject.h ltm.h lzio.h lmem.h ldebug.h ldo.h lfunc.h lgc.h lopcodes.h \
 lstring.h ltable.h lvm.h ljumptab.h
lzio.o: lzio.c lprefix.h lua.h luaconf.h lapi.h llimits.h lstate.h \
 lobject.h ltm.h lzio.h lmem.h

# (end of Makefile)
