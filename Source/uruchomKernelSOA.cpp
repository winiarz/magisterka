#include "main.hpp"

float zera[c_N];

void zerujWyniki(vector<ClMemory*>& daneTestoweGpu)
{
    daneTestoweGpu[6]->copyIn(zera, 0, c_N*sizeof(float));
    daneTestoweGpu[7]->copyIn(zera, 0, c_N*sizeof(float));
    daneTestoweGpu[8]->copyIn(zera, 0, c_N*sizeof(float));
}

void uruchomKernel(boost::shared_ptr<ClKernel> kernel,
		   uint globalSize,
		   uint localSize,
		   vector<ClMemory*>& daneTestoweGpu,
		   float* wynikiX,
		   float* wynikiY,
		   float* wynikiZ  )
{
    zerujWyniki(daneTestoweGpu);
    (*kernel)[globalSize][localSize](daneTestoweGpu);
    
    daneTestoweGpu[6]->copyOut(wynikiX, 0, c_N*sizeof(float));
    daneTestoweGpu[7]->copyOut(wynikiY, 0, c_N*sizeof(float));
    daneTestoweGpu[8]->copyOut(wynikiZ, 0, c_N*sizeof(float));
}

int testujKernel(ClKernelFromSourceLoader* kernelLoader,
                 float** daneTesoweCpu,
                 vector<ClMemory*>& daneTestoweGpu,
                 string fileName,
                 string kernelName,
                 bool checkResults,
                 bool printOnlyTimes,
                 uint globalSize,
                 uint localSize)
{
    boost::shared_ptr<ClKernel> kernel = kernelLoader->loadKernel(fileName.c_str(), kernelName.c_str());
    vector<float> wynikiX(c_N);
    vector<float> wynikiY(c_N);
    vector<float> wynikiZ(c_N);
    
    if (!printOnlyTimes) 
        cout << "uruchomienie kernla: " << kernelName << endl;
    int workTime = zmierzCzas( boost::bind( &uruchomKernel,
					    kernel,
					    globalSize,
					    localSize,
					    daneTestoweGpu,
					    &wynikiX.front(),
					    &wynikiY.front(),
					    &wynikiZ.front() ) );

    if (!printOnlyTimes) 
        cout << "kernel " << kernelName << " czas: " << workTime << endl;
    else
        cout << workTime << endl;

    if ( checkResults ) 
    {
        if( !sprawdzWyniki(&wynikiX.front(),
                           &wynikiY.front(),
                           &wynikiZ.front(),
                           daneTesoweCpu ) )
            return 0xffffffff;
    }

    return workTime;
    //return 1;
}