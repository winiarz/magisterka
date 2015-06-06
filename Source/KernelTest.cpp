#include "KernelTest.hpp"
#include "Clock.hpp"
#include "main.hpp"
#include <iostream>

KernelTest::KernelTest(std::string p_kernelName) :
    kernelName(p_kernelName)
{}

int KernelTest::testKernel(float** testDataCpu, bool sprawdzajWyniki, bool printTimeOnly)
{
    if (!printTimeOnly)
        std::cout << "testowanie kernela: " << kernelName << std::endl;

    const int numberOfRuns = 1;
    uint results[numberOfRuns];

    prepareData(testDataCpu);

    for (int i=0;i<numberOfRuns;++i) 
    {
        uint startTime = getUsec();
        runKernel(64, 64);
        uint workTime = getUsec() - startTime;
        results[i] = workTime;
    }

    
        float resultsX[c_N];
        float resultsY[c_N];
        float resultsZ[c_N];
        prepareResults(resultsX, resultsY, resultsZ);
        uint workTime = 0u;
        for (int i=0;i<numberOfRuns;++i) 
        {
            workTime += results[i];
        }
        workTime /= numberOfRuns;

        if (printTimeOnly)
        {
            std::cout << workTime << std::endl;
        }
        else
        {
            std::cout << "czas pracy to: " << workTime << std::endl;
        }

    if (sprawdzajWyniki) 
    {
        if( sprawdzWyniki(resultsX, resultsY, resultsZ, testDataCpu) == 1)
        {
            testStats.push_back(workTime);
            return workTime;
        }
        else
        {
            testStats.push_back(-1);
            return -1;
        }
    }
    return workTime;
}
