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
		   float* wynikiZ );
int zmierzCzas( boost::function<void()> funkcja );
int testujKernel(ClKernelFromSourceLoader*,
                 float**,
                 vector<ClMemory*>&,
                 string, string,
                 bool checkResults,
                 bool printOnlyTimes,
                 uint globalSize = 32,
                 uint localSize = 64);

int testujKernelSOA(ClKernelFromSourceLoader* kernelLoader,
                    float** daneTesoweCpu,
                    string fileName,
                    string kernelName,
                    bool checkResults,
                    bool printOnlyTimes,
                    uint globalSize = 32,
                    uint localSize = 64);

const float posMin = -100.0f;
const float posMax = -posMin;
const float velMin = -1.0f;
const float velMax = -velMin;
const float massMin = 1.0f;
const float massMax = 10.0f;

const float dopuszczalnyBlad = 0.05;
const int maxBledow = 10;


