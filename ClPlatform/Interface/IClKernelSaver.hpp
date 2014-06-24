#ifndef __I_CL_KERNEL_SAVER__
#define __I_CL_KERNEL_SAVER__

#include "stl.hpp"
#include "boost.hpp"
class IClSingleImplementationKernel;

class IClKernelSaver
{
public:
    virtual void saveKernel( boost::shared_ptr<IClSingleImplementationKernel> kernel, std::string filename ) = 0;
    virtual void saveKernel( boost::shared_ptr<IClSingleImplementationKernel> kernel, FILE* file ) = 0;
};

#endif
