#ifndef __I_CL_KERNEL_FACTORY__
#define __I_CL_KERNEL_FACTORY__

#include <string>
#include "ClKernel.hpp"

class IClKernelFactory {
public:
  virtual IClKernel* buildClKernel( std::string, std::string )=0;
};

#endif
