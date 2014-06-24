#ifndef __I_CL_INCLUDE_PREPROCESSOR__
#define __I_CL_INCLUDE_PREPROCESSOR__

#include "boost.hpp"
#include "stl.hpp"

class IClIncludePreprocessor
{
public:
    virtual boost::shared_ptr<std::string> replaceIncludes( boost::shared_ptr<std::string> source,
                                                            std::set<std::string>& includeDirectories ) = 0;
};

#endif

