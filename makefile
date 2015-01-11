
ProjectRoot=.

include config.mk

include $(ClPlatform)/ClPlatform.mk

all: nbodyProject

clean: ClPlatformClean
	@rm -f lib/*.a Obj/* nbodyProject

Obj/%.o: Source/%.cpp
	@echo "\tCXX\t"$*.o
	@g++ -fopenmp $^ -o $@ $(AllInclude) $(cpp_flags) -O2

nbodyProjectObj +=Obj/main.o
nbodyProjectObj +=Obj/nbody_cpu.o
nbodyProjectObj +=Obj/dane_testowe.o
nbodyProjectObj +=Obj/sprawdz_wyniki.o
nbodyProjectObj +=Obj/zmierzCzas.o
nbodyProjectObj +=Obj/uruchomKernelSOA.o
nbodyProjectObj +=Obj/uruchomKernelAOS.o

nbodyProject: $(nbodyProjectObj) $(libClPlatform)
	@echo "\tLD\tnbodyProject"
	@g++ -o $@ $^ $(OpenClLib) $(OpenGL) -fopenmp -O2
