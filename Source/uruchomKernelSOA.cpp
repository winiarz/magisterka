#include "main.hpp"

float zera[c_N];

void zerujWyniki(vector<ClMemory*>& daneTestoweGpu)
{
    daneTestoweGpu[3]->copyIn(zera, 0, c_N*sizeof(float));
    daneTestoweGpu[4]->copyIn(zera, 0, c_N*sizeof(float));
    daneTestoweGpu[5]->copyIn(zera, 0, c_N*sizeof(float));
}

void uruchomKernel(boost::shared_ptr<ClKernel> kernel,
		   uint globalSize,
		   uint loaclSize,
		   vector<ClMemory*>& daneTestoweGpu,
		   float* wynikiX,
		   float* wynikiY,
		   float* wynikiZ  )
{
    zerujWyniki(daneTestoweGpu);
    (*kernel)[globalSize][loaclSize](daneTestoweGpu);
    
    daneTestoweGpu[3]->copyOut(wynikiX, 0, c_N*sizeof(float));
    daneTestoweGpu[4]->copyOut(wynikiY, 0, c_N*sizeof(float));
    daneTestoweGpu[5]->copyOut(wynikiZ, 0, c_N*sizeof(float));
}

uint testujKernel(ClKernelFromSourceLoader* kernelLoader, float** daneTesoweCpu, vector<ClMemory*>& daneTestoweGpu, string fileName, string kernelName, uint globalSize, uint localSize)
{
    boost::shared_ptr<ClKernel> kernel = kernelLoader->loadKernel(fileName.c_str(), kernelName.c_str());

    float wynikiX[c_N];
    float wynikiY[c_N];
    float wynikiZ[c_N];
    
    cout << "uruchomienie kernla: " << kernelName << endl;
    int workTime = zmierzCzas( boost::bind( &uruchomKernel,
					    kernel,
					    globalSize,
					    localSize,
					    daneTestoweGpu,
					    wynikiX,
					    wynikiY,
					    wynikiZ ) );

    cout << "kernel " << kernelName << " czas: " << workTime << endl;

    if( sprawdzWyniki(wynikiX, wynikiY, wynikiZ, daneTesoweCpu ) )
      return 0xffffffff;

    return workTime;
}