#include "KernelTestAOS.hpp"
#include "main.hpp"

KernelTestAOS::KernelTestAOS(ClKernelFromSourceLoader& kernelLoader,
                             std::string fileName,
                             std::string kernelName) :
    KernelTest(kernelName)
{
    kernel = kernelLoader.loadKernel(fileName, kernelName);
}

struct MaterialPoint
{
    float positionMass[4];
    float oldPosition[4];
    float newPosition[4];
};

void KernelTestAOS::prepareData(float** testDataCpu)
{
    MaterialPoint materialPoints[c_N];
    ClTypedMemory<MaterialPoint>* memory = new ClTypedMemory<MaterialPoint>(c_N);

    for (int i=0;i<c_N;i++) 
    {
        materialPoints[i].positionMass[0] = testDataCpu[0][i];
        materialPoints[i].positionMass[1] = testDataCpu[1][i];
        materialPoints[i].positionMass[2] = testDataCpu[2][i];
        materialPoints[i].positionMass[3] = testDataCpu[9][i];

        materialPoints[i].oldPosition[0] = testDataCpu[3][i];
        materialPoints[i].oldPosition[1] = testDataCpu[4][i];
        materialPoints[i].oldPosition[2] = testDataCpu[5][i];
    }

    memory->copyIn(materialPoints, 0, c_N);
    testDataGpu.push_back( memory );
}

void KernelTestAOS::runKernel(uint globalSize, uint localSize)
{
    (*kernel)[globalSize][localSize](testDataGpu);
}

void KernelTestAOS::prepareResults(float* resultsX, float* resultsY, float* resultsZ)
{
    MaterialPoint materialPoints[c_N];
    testDataGpu[0]->copyOut(materialPoints, 0, sizeof(MaterialPoint)*c_N);

    for (int i=0;i<c_N;i++) 
    {
        resultsX[i] = materialPoints[i].newPosition[0];
        resultsY[i] = materialPoints[i].newPosition[1];
        resultsZ[i] = materialPoints[i].newPosition[2];
    }
}
