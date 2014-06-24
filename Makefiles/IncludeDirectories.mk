

#C++ include directories
ClPlatformInclude= -I$(ClPlatform)/Include -I$(ClPlatform)/Interface -I$(ClPlatform)/Mock
CommonInclude= -I$(Common)/Include -I$(Common)/Interface -I$(Common)/Mock

#Mock includes
MockIncludes= -I$(ClPlatform)/Mock

AllInclude=$(ClPlatformInclude) $(CommonInclude) -I clinclude -I Include



#OpenCL include folders
ClInclude= -I $(ProjectRoot)/clinclude
