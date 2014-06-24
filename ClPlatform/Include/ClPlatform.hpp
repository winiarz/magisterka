
#ifndef __CL_PLATFORM__
#define __CL_PLATFORM__

#include <CL/cl.h>
#include "ClClasses.hpp"
#include "ClError.hpp"

class ClKernelManager;

class ClPlatform {
friend class ClMemory;
friend class ClKernel;
public:
  static ClPlatform& getPlatform();
  bool isSetUpSuccessfully();
  void execute() const;
  cl_context getContext() const;
  cl_device_id getDevice() const;

  ~ClPlatform();
  cl_uint max_work_group_size;
private:
  ClPlatform();
  cl_platform_id platform;
  cl_device_id device;
  cl_context context;
  cl_command_queue queue;

  bool setUpSuccessfully;
};

#endif

