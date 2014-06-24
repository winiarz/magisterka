#ifndef __CL_INCLUDE_PREPROCESSOR__
#define __CL_INCLUDE_PREPROCESSOR__

#include "IClIncludePreprocessor.hpp"

class ClIncludePreprocessor : public IClIncludePreprocessor
{
public:
    virtual boost::shared_ptr<std::string> replaceIncludes( boost::shared_ptr<std::string> source,
                                                            std::set<std::string>& includeDirectories );
private:
    bool isLineIncludeDirective( std::string& line );
    std::string getIncludeFilename( std::string& line );
    boost::shared_ptr<std::string> readFile(std::string& filename);
    std::string getIncludeFilePath(std::string&, std::set<std::string>&);
};

#endif

