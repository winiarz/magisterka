#include "main.hpp"
#include "KernelTestSOA.hpp"
#include "KernelTestAOS.hpp"
//#include "KernelTestAoSoA.hpp"
#include "KernelTestSoAoV.hpp"

ClKernelFromSourceLoader* kernelLoader;

void przygotujKompilator()
{
    set<string> includeDirs;
    includeDirs.insert(".");
    includeDirs.insert("clinclude");
    kernelLoader = new ClKernelFromSourceLoader(includeDirs);
}

int main(int argc, const char* argv[])
{
    bool checkResults = true;
    bool printOnlyTimes = false;
    for (int i=1; i<argc; ++i) 
    {
        if ( strcmp(argv[i], "--time_only" ) == 0) 
            checkResults = false;
        if ( strcmp(argv[i], "--print_time_only" ) == 0 ) 
        { 
            printOnlyTimes = true;
            checkResults = false;
        }
    }

    float* daneTesoweCpu[10];
    vector<ClMemory*> daneTestoweGpu;
    if (!printOnlyTimes) 
        cout << "przygotowanie danych do testow" << endl;

    przygotujDaneTestowe(daneTesoweCpu, daneTestoweGpu);

    if (!printOnlyTimes) 
        cout << "wersja na cpu (OpenMP):" << endl;

    uint czasCPU = 9999999;
    if (checkResults) 
    {
        czasCPU = zmierzCzas( boost::bind( &nbody_cpu, daneTesoweCpu) );
        if (!printOnlyTimes) 
            cout << "czas CPU = " << czasCPU << endl;
    }

    if (!printOnlyTimes) 
        cout << "Testowanie kerneli:" << endl;
    przygotujKompilator();

    std::vector<KernelTest*> kernelsToTest;
    //kernelsToTest.push_back( new KernelTestSOA(*kernelLoader, "clinclude/simplest2.cl", "simplestNbody0") );
    //kernelsToTest.push_back( new KernelTestSOA(*kernelLoader, "clinclude/simplest2.cl", "simplestNbody1") );
    //kernelsToTest.push_back( new KernelTestSOA(*kernelLoader, "clinclude/simplest2.cl", "simplestNbody2") );
    //kernelsToTest.push_back( new KernelTestSOA(*kernelLoader, "clinclude/simplest2.cl", "simplestNbody3") );
    //kernelsToTest.push_back( new KernelTestSOA(*kernelLoader, "clinclude/nbody_float4.cl", "nbody_float4") );
    //kernelsToTest.push_back( new KernelTestSOA(*kernelLoader, "clinclude/nbody.cl", "nbody_withSharedMem") );
    //kernelsToTest.push_back( new KernelTestSOA(*kernelLoader, "clinclude/nbody2.cl", "nbody_withSharedMem2") );
    //kernelsToTest.push_back( new KernelTestSOA(*kernelLoader, "clinclude/nbody3.cl", "nbody_withSharedMem3") );
    //kernelsToTest.push_back( new KernelTestSOA(*kernelLoader, "clinclude/nbody4.cl", "nbody_withSharedMem4") );
    kernelsToTest.push_back( new KernelTestSOA(*kernelLoader, "clinclude/nbody5.cl", "nbody_withSharedMem5") );

    //kernelsToTest.push_back( new KernelTestAOS(*kernelLoader, "clinclude/nbody_aos.cl", "nbody_aos1"));
    //kernelsToTest.push_back( new KernelTestAOS(*kernelLoader, "clinclude/nbody_aos.cl", "nbody_aos2"));
    //kernelsToTest.push_back( new KernelTestAOS(*kernelLoader, "clinclude/nbody_aos.cl", "nbody_aos3"));
    kernelsToTest.push_back( new KernelTestAOS(*kernelLoader, "clinclude/nbody_aos.cl", "nbody_aos4"));

    kernelsToTest.push_back( new KernelTestSoAoV(*kernelLoader, "clinclude/nbody_soaov.cl", "nbody_soaov"));

    for (auto test : kernelsToTest) 
    {
        test->testKernel(daneTesoweCpu, checkResults, printOnlyTimes);
    }
}

