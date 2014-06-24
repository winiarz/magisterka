#include "clcc.hpp"
#include "ClPlatform.hpp"
#include "ClKernelSaver.hpp"
#include "ClKernelFromSourceLoader.hpp"
#include "ClKernel.hpp"

int compile(const char input_file[],set<string>  includeDirectories,const char output_file[])
{
    ClKernelFromSourceLoader kernelLoader(includeDirectories);
  
    try
    {
        boost::shared_ptr<ClKernel> kernel = 
            kernelLoader.loadKernel(std::string(input_file));

        ClKernelSaver().saveKernel( kernel, std::string(output_file) );
    }
    catch ( ClError )
    {
        return 1;
    }

    return 0;
}
