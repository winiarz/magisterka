#ifndef __I_CL_KERNEL__
#define __I_CL_KERNEL__

#include <CL/cl.h>
#include <stl.hpp>
#include "boost.hpp"

typedef unsigned int uint;

class IClKernelCallStats;
class ClMemory;

class IClKernel {
public:
    virtual bool isSetUpSuccessfully()=0;
    virtual bool operator!()=0;
    virtual IClKernel& operator[](uint n)=0;
    virtual IClKernel& operator()(uint, ... )=0;
    virtual IClKernel& operator()(std::vector<ClMemory*>)=0;
  
    virtual ~IClKernel(){}
};

#endif
