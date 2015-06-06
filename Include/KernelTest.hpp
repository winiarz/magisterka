#pragma once
#include <string>
#include <vector>

class KernelTest
{
public:
    KernelTest(std::string);
    virtual void prepareData(float**) = 0;
    virtual void runKernel(uint globalSize, uint localSize) = 0;
    virtual void prepareResults(float*, float*, float*) = 0;
    int testKernel(float**, bool sprawdzajWyniki, bool);
private:
    std::string kernelName;
    std::vector<int> testStats;
};

