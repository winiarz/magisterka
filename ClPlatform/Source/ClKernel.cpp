#include <stdarg.h>
#include "ClKernel.hpp"
#include "ClMemory.hpp"
#include "ClKernelFromBinaryLoader.hpp"

ClKernel::ClKernel( const char fileName[], const char p_kernelName[] ) :
    platform(ClPlatform::getPlatform()),
    kernel(0),
    loaded(false),
    kernelName(p_kernelName)
{
    setUpSuccessfully = false;
    try
    {
        boost::shared_ptr<ClKernel> tempKernel = ClKernelFromBinaryLoader().loadKernel(fileName);
        program = tempKernel->getProgram();
    }
    catch ( ClError error ) 
    {
        std::cerr << "Error while loading kernel " << kernelName << " from file " << fileName << std::endl;
        return;
    }

    if( !program )
    {
        std::cerr << "Error in creating program from file: " << fileName << std::endl;
        setUpSuccessfully = false;
        return;
    }

    localSize = 0;
    globalSize = 0;

    setUpSuccessfully = true;
}

ClKernel::ClKernel( cl_program p_program, const char p_kernelName[] ) :
    platform(ClPlatform::getPlatform()),
    program(p_program),
    kernel(0),
    loaded(false),
    kernelName( p_kernelName )
{
    localSize = 0;
    globalSize = 0;

    setUpSuccessfully = true;
}

ClKernel::ClKernel( cl_program p_program ) :
    platform(ClPlatform::getPlatform()),
    program(p_program),
    kernel(0),
    loaded(false),
    kernelName("KERNEL")
{
    localSize = 0;
    globalSize = 0;

    setUpSuccessfully = true;
}

void ClKernel::load()
{
    cl_int error;
    kernel = clCreateKernel( program, kernelName.c_str(), &error );
    if( (!kernel) || (error != CL_SUCCESS) )
    {
        std::cerr << "error in creating kernel OpenCL error = " << error << std::endl;
        loaded = false;
        delete this;
        if( error == CL_OUT_OF_RESOURCES )
        {
            throw OUT_OF_RESOURCES;
        }
        else
        {
            throw OPEN_CL_ERROR;
        }
    }
    else
        loaded = true;
}

void ClKernel::unload()
{
    if ( kernel ) 
    {
      clReleaseKernel(kernel);
      kernel = 0;
      loaded = false;
    }
}

ClKernel::~ClKernel()
{
    unload();
}

bool ClKernel::isLoaded()
{
  return loaded;
}

bool ClKernel::isSetUpSuccessfully()
{
  return setUpSuccessfully;
}

bool ClKernel::operator!()
{
  return !isSetUpSuccessfully();
}

IClKernel& ClKernel::operator[](uint size)
{
  if( size <= 0 )
    return *this;

  if( globalSize <= 0 )
  {
    globalSize = size;
    return *this;
  }

  if( localSize <= 0 )
  {
    localSize = size;
    globalSize*=size;
    return *this;
  }
  
  return *this;
}

IClKernel& ClKernel::operator()(uint argumentNb, ...  )
{
    va_list li;
  
    if ( !loaded ) 
    {
        load();
    }

    va_start(li,argumentNb);
    for(uint i=0; i < argumentNb; i++)
    {
        ClMemory* memory = va_arg(li,ClMemory*);
        setKernelArg(i, memory);
    }
    va_end(li);

    executeKernel();
    return *this;
}

cl_program ClKernel::getProgram()
{
    return program;
}

void ClKernel::setKernelArg(uint idx, ClMemory* arg)
{
    cl_int error = clSetKernelArg( kernel, idx, sizeof(arg->memory), &(arg->memory) );
    if( error != CL_SUCCESS )
    {
        std::cerr << "error in setting kernel arg argNb = " << idx << "OpenCL error = " << error << std::endl;
        throw KERNEL_SET_ARG_ERROR;
    }
}

void ClKernel::checkThreadCount()
{
    if( (globalSize <= 0) || (localSize <= 0) )
    {
        std::cerr << "running kernel without setting threads nb first" << std::endl;
        throw KERNEL_SIZE_NOT_SET; 
    }
}

void ClKernel::executeKernel()
{
    checkThreadCount();
    cl_int error = clEnqueueNDRangeKernel( platform.queue, kernel, 1, NULL,  &globalSize, &localSize, 0, NULL, NULL);
    if( error != CL_SUCCESS )
    {
        std::cerr << "error in kernel execution OpenCL error = " << error << std::endl;
        throw KERNEL_EXEC_ERROR;
    }
    platform.execute();
}

IClKernel& ClKernel::operator()(std::vector<ClMemory*> args)
{
    if ( !loaded ) 
    {
        load();
    }

    for ( uint i = 0; i < args.size(); ++i) 
    {
        setKernelArg(i, args.at(i));
    }

    executeKernel();
    return *this;
}

IClKernel& ClKernel::operator()(std::vector<boost::shared_ptr<ClMemory> > args)
{
    std::cout << "Kernel: " << kernelName << std::endl;
    if ( !loaded ) 
    {
        load();
    }

    for ( uint i = 0; i < args.size(); ++i) 
    {
        setKernelArg(i, args.at(i).get());
    }

    executeKernel();
    return *this;
}

std::string ClKernel::getKernelName()
{
    return kernelName;
}

