#include "KernelTestAoSoA.hpp"
#include "ClTypedMemory.hpp"
#include "main.hpp"

const int pointsPerStructure = 4;

KernelTestAoSoA::KernelTestAoSoA(ClKernelFromSourceLoader& kernelLoader,
                             std::string fileName,
                             std::string kernelName) :
    KernelTest(kernelName)
{
    kernel = kernelLoader.loadKernel(fileName, kernelName);
}

struct MaterialPoints
{
    float positionX[pointsPerStructure];
    float positionY[pointsPerStructure];
    float positionZ[pointsPerStructure];

    float oldPositionX[pointsPerStructure];
    float oldPositionY[pointsPerStructure];
    float oldPositionZ[pointsPerStructure];

    float newPositionX[pointsPerStructure];
    float newPositionY[pointsPerStructure];
    float newPositionZ[pointsPerStructure];

    float mass[pointsPerStructure];
};

void KernelTestAoSoA::prepareData(float** testDataCpu)
{
    MaterialPoints materialPoints[c_N / pointsPerStructure];
    ClTypedMemory<MaterialPoints>* memory = new ClTypedMemory<MaterialPoints>(c_N);

    for (int i=0;i<c_N;i+=pointsPerStructure) 
    {
        int i2 = i / pointsPerStructure;
        for (int j=0;j<pointsPerStructure;++j) 
        {
            materialPoints[i2].positionX[j] = testDataCpu[0][i+j];
            materialPoints[i2].positionY[j] = testDataCpu[1][i+j];
            materialPoints[i2].positionZ[j] = testDataCpu[2][i+j];

            materialPoints[i2].oldPositionX[j] = testDataCpu[3][i+j];
            materialPoints[i2].oldPositionY[j] = testDataCpu[4][i+j];
            materialPoints[i2].oldPositionZ[j] = testDataCpu[5][i+j];

            materialPoints[i2].mass[j] = testDataCpu[9][i+j];
        }
    }

    memory->copyIn(materialPoints, 0, c_N/ pointsPerStructure);
    testDataGpu.push_back( memory );
}

void KernelTestAoSoA::runKernel(uint globalSize, uint localSize)
{
    (*kernel)[globalSize][localSize](testDataGpu);
}

void KernelTestAoSoA::prepareResults(float* resultsX, float* resultsY, float* resultsZ)
{
    MaterialPoints materialPoints[c_N / pointsPerStructure];
    testDataGpu[0]->copyOut(materialPoints, 0, sizeof(MaterialPoints)*c_N / pointsPerStructure);

    for (int i=0;i<c_N;i+=pointsPerStructure) 
    {
        int i2 = i / pointsPerStructure;

        for (int j=0; j<pointsPerStructure; j++) 
        {
            resultsX[i+j] = materialPoints[i2].newPositionX[j];
            resultsY[i+j] = materialPoints[i2].newPositionY[j];
            resultsZ[i+j] = materialPoints[i2].newPositionZ[j];
        }
    }
}
