#include "ClMemory.hpp"
#include "stl.hpp"

uint getSizeOfBuffer(uint p_size, ClMemoryCreation creationType)
{
  switch( creationType )
  {
    case CL_MEMORY_ALLOC:
        return p_size;
    case CL_MEMORY_USE_GL_BUFFER:
    {
        GLuint glBuffer = p_size;
        int bufferSize = 0;
        glBindBuffer(GL_ARRAY_BUFFER, glBuffer);
        glGetBufferParameteriv(GL_ARRAY_BUFFER, GL_BUFFER_SIZE, &bufferSize);
        return bufferSize;
    }
    default:
      return 0;
  }
}

ClMemory::ClMemory(uint p_size, ClMemoryCreation creationType) :
	      platform(ClPlatform::getPlatform()),
	      size(getSizeOfBuffer(p_size, creationType))
{
  cl_int error;
  switch( creationType )
  {
    case CL_MEMORY_ALLOC:
    {
      memory = clCreateBuffer(platform.context, CL_MEM_READ_WRITE, size, NULL, &error);
      break;
    }
    case CL_MEMORY_USE_GL_BUFFER:
    {
      GLuint glBuffer = p_size;
      memory = clCreateFromGLBuffer(platform.context, CL_MEM_READ_WRITE, glBuffer, NULL);
      break;
    }
  }
  if( (!memory) || (error != CL_SUCCESS) )
  {
      std::cerr << "error in memory allocation OpenCL error = " << error << std::endl;
      setUpSuccessfully=false;
      return;
  }
    
  setUpSuccessfully = true;
}

bool ClMemory::isSetUpSuccessfully()
{
  return setUpSuccessfully;
}

bool ClMemory::operator!()
{
   return !isSetUpSuccessfully();
}

void ClMemory::copyIn(void* data, uint start, uint p_size)
{
  cl_int error;
  error = clEnqueueWriteBuffer( platform.queue, memory, CL_TRUE, start, p_size, data, 0, NULL, NULL);
  if(error != CL_SUCCESS)
  {
      std::cerr << "error in copying memory to device, OpenCL error = " << error << std::endl;
      throw INTER_DEVICE_COPY_ERROR;
  }
}

void ClMemory::copyOut(void* data, uint start, uint p_size)
{
  cl_int error;
  error = clEnqueueReadBuffer( platform.queue, memory, CL_TRUE, start, p_size, data, 0, NULL, NULL);
  if(error != CL_SUCCESS)
  {
      std::cerr << "error in copying memory to device, OpenCL error = " << error << std::endl;
      throw INTER_DEVICE_COPY_ERROR;
  }
  platform.execute();
}

uint ClMemory::getSize()
{
  return size;
}

uint calculateSize(uint n, ClMemoryCreation clMemoryCreation, size_t sizeOfType)
{
  switch( clMemoryCreation )
  {
    case CL_MEMORY_ALLOC:
      return sizeOfType * n;
    case CL_MEMORY_USE_GL_BUFFER:
      return n;
    default:
      return 0;
  }
}
