#include "main.hpp"

vector<ClMemory*> konwertualDaneDo_SOAOV(float** daneTesoweCpu)
{
    float* currentPositions = new float[4*c_N];
    float* oldPositions = new float[4*c_N];
    for (uint i=0;i<c_N;i++) 
    {
        currentPositions[4*i  ] = daneTesoweCpu[0][i];
        currentPositions[4*i+1] = daneTesoweCpu[1][i];
        currentPositions[4*i+2] = daneTesoweCpu[2][i];
        currentPositions[4*i+3] = daneTesoweCpu[9][i];

        oldPositions[4*i  ] = daneTesoweCpu[3][i];
        oldPositions[4*i+1] = daneTesoweCpu[4][i];
        oldPositions[4*i+2] = daneTesoweCpu[5][i];
        oldPositions[4*i+3] = daneTesoweCpu[9][i];
    }


    vector<ClMemory*> l_daneGpu;
    ClMemory* currentPositionsGpu = new ClMemory (sizeof(float)*4*c_N);
    currentPositionsGpu->copyIn(currentPositions, 0, sizeof(float)*4*c_N);
    l_daneGpu.push_back(currentPositionsGpu);

    ClMemory* oldPositionsGpu = new ClMemory (sizeof(float)*4*c_N);
    oldPositionsGpu->copyIn(oldPositions, 0, sizeof(float)*4*c_N);
    l_daneGpu.push_back(oldPositionsGpu);

    delete [] currentPositions;
    delete [] oldPositions;

    return l_daneGpu;
}

void uruchomKernel3(boost::shared_ptr<ClKernel> kernel,
                   vector<ClMemory*>& daneTestoweGpu,
                   uint globalSize,
                   uint localSize)
{
    (*kernel)[globalSize][localSize](2, daneTestoweGpu[0], daneTestoweGpu[1]);
}

int testujKernelSOAOV(ClKernelFromSourceLoader* kernelLoader,
                      float** daneTesoweCpu,
                      string fileName,
                      string kernelName,
                      bool checkResults,
                      bool printOnlyTimes,
                      uint globalSize,
                      uint localSize)
{
    vector<ClMemory*> daneTestoweGpu = konwertualDaneDo_SOAOV(daneTesoweCpu);

    boost::shared_ptr<ClKernel> kernel = kernelLoader->loadKernel(fileName.c_str(), kernelName.c_str());

    //(*kernel)[globalSize][localSize](2, &daneTestoweGpu[0], &daneTestoweGpu[1]);
    //uint czasStart = getUsec();
    //uruchomKernel_3(kernel, daneTestoweGpu,globalSize,localSize);
    //int workTime = getUsec() - czasStart;

    int workTime = zmierzCzas( boost::bind(&uruchomKernel3, kernel, daneTestoweGpu,globalSize,localSize));
    

    if(!printOnlyTimes)
        cout << " czas: " << workTime << endl;
    else
        cout << workTime << endl;

    return workTime;
}

