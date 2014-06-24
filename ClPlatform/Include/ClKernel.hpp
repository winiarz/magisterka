
#ifndef __CL_KERNEL__
#define __CL_KERNEL__

#include "IClSingleImplementationKernel.hpp"
#include "ClClasses.hpp"
#include "ClPlatform.hpp"
#include "ClMemory.hpp"
#include "stl.hpp"

class ClKernel : public IClSingleImplementationKernel {
public:
  ClKernel( const char[], const char[]);
  ClKernel( cl_program );
  ClKernel( cl_program, const char[] );
  bool isLoaded();
  bool isSetUpSuccessfully();
  bool operator!();
  IClKernel& operator[](uint);
  IClKernel& operator()(uint, ... );
  virtual IClKernel& operator()(std::vector<ClMemory*>);
  virtual IClKernel& operator()(std::vector<boost::shared_ptr<ClMemory> >);
  virtual cl_program getProgram();
  virtual void load();
  virtual void unload();
  virtual std::string getKernelName();
  ~ClKernel();
private:
  ClPlatform& platform;
  cl_program program;
  cl_kernel kernel;

  size_t globalSize;
  size_t localSize;

  bool setUpSuccessfully;
  bool loaded;
  std::string kernelName;
  void setKernelArg(uint, ClMemory*);
  void checkThreadCount();
  void executeKernel();
};

#endif

