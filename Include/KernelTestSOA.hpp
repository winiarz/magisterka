#include "KernelTest.hpp"
#include "ClKernelFromSourceLoader.hpp"
#include "ClMemory.hpp"
#include <string>

class KernelTestSOA : public KernelTest
{
public:
    KernelTestSOA(ClKernelFromSourceLoader&,
                  std::string,
                  std::string);
    virtual void prepareData(float**);
    virtual void runKernel(uint globalSize, uint localSize);
    virtual void prepareResults(float*, float*, float*);
private:
    boost::shared_ptr<ClKernel> kernel;
    vector<ClMemory*> testDataGpu;
};

