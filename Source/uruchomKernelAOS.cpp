#include "main.hpp"
#include "ClTypedMemory.hpp"

struct point
{
    float position[3];
    float mass;
    float oldPosition[4];
    float newPosition[4];
};



void przygotujDane(ClMemory* daneTestoweGpu, point* punktyLoc, float** daneTesoweCpu)
{
    for (uint i=0;i<c_N;i++) 
    {
        punktyLoc[i].mass =           daneTesoweCpu[9][i];

        punktyLoc[i].position[0] =    daneTesoweCpu[0][i];
        punktyLoc[i].position[1] =    daneTesoweCpu[1][i];
        punktyLoc[i].position[2] =    daneTesoweCpu[2][i];

        punktyLoc[i].oldPosition[0] = daneTesoweCpu[3][i];
        punktyLoc[i].oldPosition[1] = daneTesoweCpu[4][i];
        punktyLoc[i].oldPosition[2] = daneTesoweCpu[5][i];
    }
    daneTestoweGpu->copyIn(punktyLoc, 0, c_N*sizeof(point));
}

bool sprawdzWyniki(ClMemory* daneTestoweGpu, point* punktyLoc, float** daneTesoweCpu)
{
    int iloscBledow=0;
    for (uint i=0;i<c_N;i++)
    {
        if (fabs(punktyLoc[i].newPosition[0] - daneTesoweCpu[6][i]) > dopuszczalnyBlad ) 
        {
            cout << "Nieprawidlowy wynik!: X[" << i << "] = " << punktyLoc[i].newPosition[0]  << " a powien byc " << daneTesoweCpu[6][i] << endl;
            iloscBledow++;
        }

        if (fabs(punktyLoc[i].newPosition[1] - daneTesoweCpu[7][i]) > dopuszczalnyBlad ) 
        {
            cout << "Nieprawidlowy wynik!: Y[" << i << "] = " << punktyLoc[i].newPosition[1]  << " a powien byc " << daneTesoweCpu[7][i] << endl;
            iloscBledow++;
        }

        if (fabs(punktyLoc[i].newPosition[2] - daneTesoweCpu[8][i]) > dopuszczalnyBlad ) 
        {
            cout << "Nieprawidlowy wynik!: Z[" << i << "] = " << punktyLoc[i].newPosition[2]  << " a powien byc " << daneTesoweCpu[8][i] << endl;
            iloscBledow++;
        }

        if (iloscBledow > maxBledow) 
        {
            return false;
        }
    }

    return true;
}

void tylkoUruchomKernel(boost::shared_ptr<ClKernel> kernel,
                        ClMemory* dane,
                        point* punktyLoc,
                        uint globalSize,
                        uint localSize)
{
    (*kernel)[globalSize][localSize](1, dane);

    dane->copyOut(punktyLoc, 0, c_N*sizeof(point));
}

int uruchomKernelSOA(boost::shared_ptr<ClKernel> kernel,
                     float** daneTesoweCpu,
                     uint globalSize,
                     uint localSize,
                     bool checkResults,
                     bool printOnlyTimes)
{
    vector<point> punktyLoc(c_N);
    ClTypedMemory<point> punkty(c_N);
    przygotujDane(&punkty, &punktyLoc.front(), daneTesoweCpu);

    int workTime = zmierzCzas( boost::bind( &tylkoUruchomKernel ,kernel,&punkty,&punktyLoc.front(),globalSize,localSize) );

    if(!printOnlyTimes)
        cout << " czas: " << workTime << endl;
    else
        cout << workTime << endl;

    if ( checkResults) 
    {
        if( !sprawdzWyniki(&punkty, &punktyLoc.front(), daneTesoweCpu) )
            return 0xffffffff;
    }

    return workTime;
}

int testujKernelSOA(ClKernelFromSourceLoader* kernelLoader,
                    float** daneTesoweCpu,
                    string fileName,
                    string kernelName,
                    bool checkResults,
                    bool printOnlyTimes,
                    uint globalSize,
                    uint localSize)
{
    boost::shared_ptr<ClKernel> kernel = kernelLoader->loadKernel(fileName.c_str(), kernelName.c_str());

    if(!printOnlyTimes)
        cout << "uruchomienie kernla: " << kernelName << " " << kernel->isSetUpSuccessfully() << endl;

    return uruchomKernelSOA(kernel, daneTesoweCpu, globalSize, localSize, checkResults, printOnlyTimes);

    
}

