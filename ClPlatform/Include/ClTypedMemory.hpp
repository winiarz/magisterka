
#ifndef __CL_TYPED_MEMORY__
#define __CL_TYPED_MEMORY__

#include "ClMemory.hpp"

template<typename T>
class ClTypedMemory : public ClMemory {
public:
  ClTypedMemory(uint n,ClMemoryCreation clMemoryCreation = CL_MEMORY_ALLOC ) :
	ClMemory(calculateSize(n,clMemoryCreation,sizeof(T)), clMemoryCreation)
  {
  }

  void copyIn (T* data, uint start, uint size)
  {
    ClMemory::copyIn(data, sizeof(T)*start, sizeof(T)*size);
  }

  void copyOut(T* data, uint start, uint size)
  {
    ClMemory::copyOut(data, sizeof(T)*start, sizeof(T)*size);
  }
};


#endif

