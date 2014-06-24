#include "ClKernelFromSourceLoader.hpp"
#include "ClKernel.hpp"
#include "ClTypedMemory.hpp"
#include "ClError.hpp"
#include "Clock.hpp"
#include <math.h>

#define __constant const
#include "constants.cl"

#include <iostream>
#include <fstream>
using namespace std;

void nbody_cpu(float**);
void przygotujDaneTestowe(float** daneTesoweCpu,
			  vector<ClMemory*>& daneTestoweGpu);
int sprawdzWyniki(float* wynikiX, float* wynikiY, float* wynikiZ, float** daneTesoweCpu);
void zerujWyniki(vector<ClMemory*>& daneTestoweGpu);
void uruchomKernel(boost::shared_ptr<ClKernel> kernel,
		   uint globalSize,
		   uint loaclSize,
		   vector<ClMemory*>& daneTestoweGpu,
		   float* wynikiX,
		   float* wynikiY,
		   float* wynikiZ  );
int zmierzCzas( boost::function<void()> funkcja );
int testujKernel(ClKernelFromSourceLoader*, float**, vector<ClMemory*>&, string, string, uint globalSize = 256, uint localSize = 256);
