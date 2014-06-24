#ifndef __CL_KERNEL_FROM_SOURCE_LOADER__
#define __CL_KERNEL_FROM_SOURCE_LOADER__

#include <CL/cl.h>
#include "IClKernelFromFileLoader.hpp"
#include "ClIncludePreprocessor.hpp"

class ClKernelFromSourceLoader : public IClKernelFromFileLoader
{
public:
    ClKernelFromSourceLoader(std::set<std::string>);
    virtual boost::shared_ptr<ClKernel> loadKernel(std::string filename);
    boost::shared_ptr<ClKernel> loadKernel(std::string filename, std::string kernelName);

    ~ClKernelFromSourceLoader();
private:
    boost::shared_ptr<std::string> readFile(std::string& filename);
    cl_program compileSource(boost::shared_ptr<std::string> source);

    static const unsigned int MAX_BUILD_LOG_SIZE = 16384;
    std::set<std::string> includeDirectories;
    ClIncludePreprocessor includePreprocessor;
};

#endif
