#include "KernelTestSoAoV.hpp"
#include "main.hpp"

KernelTestSoAoV::KernelTestSoAoV(ClKernelFromSourceLoader& kernelLoader,
                                 std::string fileName,
                                 std::string kernelName) :
    KernelTest(kernelName)
{
    kernel = kernelLoader.loadKernel(fileName, kernelName);
}

struct PositionMass
{
    float x,y,z,m;
};

void KernelTestSoAoV::prepareData(float** testDataCpu)
{
    PositionMass currentPositions[c_N];
    ClTypedMemory<PositionMass>* memoryCurrentPos = new ClTypedMemory<PositionMass>(c_N);

    PositionMass oldPositions[c_N];
    ClTypedMemory<PositionMass>* memoryOldPos = new ClTypedMemory<PositionMass>(c_N);

    ClTypedMemory<PositionMass>* memoryNewPos = new ClTypedMemory<PositionMass>(c_N);
    
    for (int i=0;i<c_N;i++) 
    {
        currentPositions[i].x = testDataCpu[0][i];
        currentPositions[i].y = testDataCpu[1][i];
        currentPositions[i].z = testDataCpu[2][i];
        currentPositions[i].m = testDataCpu[9][i];

        oldPositions[i].x = testDataCpu[3][i];
        oldPositions[i].y = testDataCpu[4][i];
        oldPositions[i].z = testDataCpu[5][i];
        oldPositions[i].m = testDataCpu[9][i];
    }

    memoryCurrentPos->copyIn(currentPositions, 0, c_N);
    testDataGpu.push_back( memoryCurrentPos );

    memoryOldPos->copyIn(oldPositions, 0, c_N);
    testDataGpu.push_back( memoryOldPos );

    testDataGpu.push_back( memoryNewPos );
}

void KernelTestSoAoV::runKernel(uint globalSize, uint localSize)
{
    (*kernel)[globalSize][localSize](testDataGpu);
}

void KernelTestSoAoV::prepareResults(float* resultsX, float* resultsY, float* resultsZ)
{
    PositionMass newPositions[c_N];
    testDataGpu[2]->copyOut(newPositions, 0, sizeof(PositionMass)*c_N);

    for (int i=0;i<c_N;i++) 
    {
        resultsX[i] = newPositions[i].x;
        resultsY[i] = newPositions[i].y;
        resultsZ[i] = newPositions[i].z;
    }
}

