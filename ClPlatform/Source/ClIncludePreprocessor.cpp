#include "ClIncludePreprocessor.hpp"
#include "ClError.hpp"

boost::shared_ptr<std::string> ClIncludePreprocessor::replaceIncludes( boost::shared_ptr<std::string> source,
                                                                       std::set<std::string>& includeDirectories )
{
    std::stringstream output;
    std::istringstream sourceStream( *source );

    std::string line;

    while ( std::getline( sourceStream, line) ) 
    {
        if ( isLineIncludeDirective(line) )
        {
            std::string includeFilename = getIncludeFilename(line);
            std::string includeFilePath = getIncludeFilePath(includeFilename, includeDirectories);
            boost::shared_ptr<std::string> includeText = readFile(includeFilePath);
			std::string textWithReplacedIncludes = *replaceIncludes(includeText, includeDirectories);
            output << textWithReplacedIncludes;
        }
        else
        {
            output << line << std::endl;
        }
    }

    return boost::make_shared<std::string>(output.str());
}

std::string ClIncludePreprocessor::getIncludeFilePath(std::string& includeFilename, 
                                                      std::set<std::string>& includeDirectories)
{
    ifstream input;
    for(set<string>::iterator i=includeDirectories.begin(); i!= includeDirectories.end(); i++)
	{
        std::ostringstream fileNameStream;
        fileNameStream << (*i) << "/" << includeFilename;
        string fileName = fileNameStream.str();
        input.open( fileName.c_str() , std::ios::in);
        if( input.is_open() )
            return fileName;
	}

    std::cerr << "file " << includeFilename << " not found in include directories!" << std::endl;
    throw FILE_READ_ERROR;
}

std::string ClIncludePreprocessor::getIncludeFilename( std::string& line )
{
    int i=8;
    while(line[i] != '"') i++;
    char includeFileName[100];
    i++;
    int j=0;
    while(line[i] != '"')
    {
        includeFileName[j] = line[i];
        i++; j++;
    }
    includeFileName[j] = 0;
    return std::string(includeFileName);
}

bool ClIncludePreprocessor::isLineIncludeDirective( std::string& line )
{
    return (line.size()>7)&&(line[0] == '#')&&(line[1]=='i')&&(line[2]=='n')&&(line[3]=='c')&&(line[4]=='l')&&(line[5]=='u')&&(line[6]=='d')&&(line[7]=='e');
}

boost::shared_ptr<std::string> ClIncludePreprocessor::readFile(std::string& filename)
{
    std::ifstream file(filename.c_str());
    if ( !file.is_open() ) 
    {
        std::cerr << "error while reading file " << filename << std::endl;
        throw FILE_READ_ERROR;
    }

    boost::shared_ptr<std::string> text = boost::make_shared<std::string>();

    file.seekg(0, std::ios::end);   
    text->reserve(file.tellg());
    file.seekg(0, std::ios::beg);

    text->assign( std::istreambuf_iterator<char>(file),
                  std::istreambuf_iterator<char>() );

    return text;
}

