#ifndef __I_CL_KERNEL_FROM_FILE_LOADER__
#define __I_CL_KERNEL_FROM_FILE_LOADER__

#include "boost.hpp"
#include "stl.hpp"

class ClKernel;

class IClKernelFromFileLoader
{
public:
    virtual boost::shared_ptr<ClKernel> loadKernel(std::string filename) = 0;
};

#endif

