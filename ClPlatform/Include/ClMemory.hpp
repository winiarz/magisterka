
#ifndef __CL_MEMORY__
#define __CL_MEMORY__

#include "ClPlatform.hpp"
#include <GL/glew.h>
#include <CL/cl_gl.h>

enum ClMemoryCreation {
  CL_MEMORY_ALLOC,
  CL_MEMORY_USE_GL_BUFFER
};

uint calculateSize(uint, ClMemoryCreation, size_t);

class ClMemory {
friend class ClKernel;
public:
  ClMemory(uint, ClMemoryCreation = CL_MEMORY_ALLOC );
  bool operator!();
  bool isSetUpSuccessfully();
  void copyIn (void*,uint,uint);
  void copyOut(void*,uint,uint);
  uint getSize();
private:
  const ClPlatform& platform;
  const uint size;
  cl_mem memory;
  bool setUpSuccessfully;
};

#endif

