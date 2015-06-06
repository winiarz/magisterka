
#directories
Lib=$(ProjectRoot)/lib

ClPlatform=$(ProjectRoot)/ClPlatform
include $(ClPlatform)/Makefiles/Directories.mk

#disable default rules
MAKEFLAGS += --no-builtin-rules

#additional makefiles
Makefiles=$(ProjectRoot)/Makefiles

include $(Makefiles)/IncludeDirectories.mk

# My library files
libClPlatform=$(Lib)/ClPlatform.a

#compilers and their flags
cpp_flags=-c --std=c++11
#-Wall -Werror

#external libraries
OpenClLib= -lpthread /usr/lib/x86_64-linux-gnu/libOpenCL.so.1
OpenGL=-lGL -lGLU -lGLEW 
