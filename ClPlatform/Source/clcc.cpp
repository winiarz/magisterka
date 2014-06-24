#include <iostream>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <set>

using namespace std;

#include "ClPlatform.hpp"
#include "clcc.hpp"

int main(int argc,char* argv[])
{
  if(argc <= 1)
  {
    cout << "no files to compile" << endl;
    exit(0);
  }
  ClPlatform& platform = ClPlatform::getPlatform();
  if(!platform.isSetUpSuccessfully())
  {
    cerr << "Error in initialising OpenCL" << endl;
    exit(1);
  }
  
  char input_file[200];
  char input_file2[200];
  char output_file[200];
  strcpy(input_file,argv[1]);
  strcpy(output_file,argv[1]);
  strcpy(input_file2,argv[1]);
  strcat(input_file2,".2");
  strcat(output_file,"bin");
  
  set<string> includeDirectories;
  includeDirectories.insert(".");
  
  for(int i=2;i<argc;i++)
  {
    if( !strcmp(argv[i],"-o") )
    {
      if( i+1 >= argc )
      {
	cout << "No file name after option -o\n";
	exit(1);
      }
      i++;
      strcpy(output_file,argv[i]);
    }
    if( !strcmp(argv[i],"-I") )
    {
      if( i+1 >= argc )
      {
	cout << "No directory after option -I\n";
      }
      i++;
      includeDirectories.insert(string(argv[i]));;
    }
  } 
  return compile(input_file, includeDirectories,output_file);
}
