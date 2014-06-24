
ClPlatformLibObj=    $(ClPlatformObj)/ClPlatform.o
ClPlatformLibObj+=   $(ClPlatformObj)/ClKernel.o
ClPlatformLibObj+=   $(ClPlatformObj)/ClMemory.o
ClPlatformLibObj+=   $(ClPlatformObj)/compile.o
ClPlatformLibObj+=   $(ClPlatformObj)/ClKernelFromBinaryLoader.o
ClPlatformLibObj+=   $(ClPlatformObj)/ClKernelFromSourceLoader.o
ClPlatformLibObj+=   $(ClPlatformObj)/ClKernelSaver.o
ClPlatformLibObj+=   $(ClPlatformObj)/ClIncludePreprocessor.o
ClPlatformLibObj+=   $(ClPlatformObj)/Clock.o
ClccObj=             $(ClPlatformObj)/clcc.o

$(clcc): $(ClPlatformLibObj) $(ClccObj) $(libLogs)
	@echo "\tLD\t"clcc
	@g++ $^ -o $@ $(OpenClLib) $(OpenGL)

ClPlatformClean:
	@rm -f $(ClPlatform)/TestPlatform $(ClPlatformObj)/*.o $(libClPlatform) $(clcc) $(ClPlatform)/TestData/*.clbin

$(libClPlatform): $(ClPlatformLibObj)
	@echo "\tLD\t"ClPlatform.a
	@ar rvs $@ $^ 2> /dev/null > /dev/null

$(ClPlatformObj)/%.o: $(ClPlatformSource)/%.cpp
	@echo "\tCXX\t"$*.o
	@g++ $^ -o $@ $(AllInclude) $(cpp_flags)

