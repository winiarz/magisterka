#include "KernelTestSOA.hpp"
#include "ClTypedMemory.hpp"
#include "main.hpp"

KernelTestSOA::KernelTestSOA(ClKernelFromSourceLoader& kernelLoader,
                             std::string fileName,
                             std::string kernelName) :
    KernelTest(kernelName)
{
    kernel = kernelLoader.loadKernel(fileName, kernelName);
}

void KernelTestSOA::prepareData(float** testDataCpu)
{
    for (uint i=0;i<10;i++) 
    {
        ClTypedMemory<float>* memory = new ClTypedMemory<float>(c_N);
        memory->copyIn( testDataCpu[i], 0, c_N );
        testDataGpu.push_back( memory );
    }
}

void KernelTestSOA::runKernel(uint globalSize, uint localSize)
{
    (*kernel)[globalSize][localSize](testDataGpu);
}

void KernelTestSOA::prepareResults(float* resultsX, float* resultsY, float* resultsZ)
{
    testDataGpu[6]->copyOut(resultsX, 0, c_N*sizeof(float));
    testDataGpu[7]->copyOut(resultsY, 0, c_N*sizeof(float));
    testDataGpu[8]->copyOut(resultsZ, 0, c_N*sizeof(float));
}
