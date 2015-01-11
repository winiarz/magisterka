#include "main.hpp"

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

    uint czasGPU;
    czasGPU = testujKernel(kernelLoader, daneTesoweCpu, daneTestoweGpu, "clinclude/simplest2.cl","simplestNbody0", checkResults,printOnlyTimes);
    if (!printOnlyTimes) cout << "Przycpieszenie: " << (czasCPU / czasGPU ) << endl;
    czasGPU = testujKernel(kernelLoader, daneTesoweCpu, daneTestoweGpu, "clinclude/simplest2.cl","simplestNbody1", checkResults,printOnlyTimes);
    if (!printOnlyTimes) cout << "Przycpieszenie: " << (czasCPU / czasGPU ) << endl;
    czasGPU = testujKernel(kernelLoader, daneTesoweCpu, daneTestoweGpu, "clinclude/simplest2.cl","simplestNbody2", checkResults,printOnlyTimes);
    if (!printOnlyTimes) cout << "Przycpieszenie: " << (czasCPU / czasGPU ) << endl;
    czasGPU = testujKernel(kernelLoader, daneTesoweCpu, daneTestoweGpu, "clinclude/nbody_float4.cl","nbody_float4", checkResults,printOnlyTimes);
    if (!printOnlyTimes) cout << "Przycpieszenie: " << (czasCPU / czasGPU ) << endl;
    czasGPU = testujKernel(kernelLoader, daneTesoweCpu, daneTestoweGpu, "clinclude/nbody.cl","nbody_withSharedMem", checkResults,printOnlyTimes);
    if (!printOnlyTimes) cout << "Przycpieszenie: " << (czasCPU / czasGPU ) << endl;
    czasGPU = testujKernel(kernelLoader, daneTesoweCpu, daneTestoweGpu, "clinclude/nbody2.cl","nbody_withSharedMem", checkResults,printOnlyTimes);
    if (!printOnlyTimes) cout << "Przycpieszenie: " << (czasCPU / czasGPU ) << endl;
    czasGPU = testujKernel(kernelLoader, daneTesoweCpu, daneTestoweGpu, "clinclude/nbody3.cl","nbody_withSharedMem", checkResults,printOnlyTimes);
    if (!printOnlyTimes) cout << "Przycpieszenie: " << (czasCPU / czasGPU ) << endl;
    czasGPU = testujKernel(kernelLoader, daneTesoweCpu, daneTestoweGpu, "clinclude/nbody4.cl","nbody_withSharedMem", checkResults,printOnlyTimes);
    if (!printOnlyTimes) cout << "Przycpieszenie: " << (czasCPU / czasGPU ) << endl;
    czasGPU = testujKernelSOA(kernelLoader, daneTesoweCpu, "clinclude/nbody_aos.cl", "nbody_aos1", checkResults, printOnlyTimes);
    if (!printOnlyTimes) cout << "Przycpieszenie: " << (czasCPU / czasGPU ) << endl;
    czasGPU = testujKernelSOA(kernelLoader, daneTesoweCpu, "clinclude/nbody_aos.cl", "nbody_aos2", checkResults, printOnlyTimes);
    if (!printOnlyTimes) cout << "Przycpieszenie: " << (czasCPU / czasGPU ) << endl;
    czasGPU = testujKernelSOA(kernelLoader, daneTesoweCpu, "clinclude/nbody_aos.cl", "nbody_aos3", checkResults, printOnlyTimes);
    if (!printOnlyTimes) cout << "Przycpieszenie: " << (czasCPU / czasGPU ) << endl;

    czasGPU = testujKernel(kernelLoader, daneTesoweCpu, daneTestoweGpu, "clinclude/nbody5.cl","nbody_withSharedMem", checkResults,printOnlyTimes);
    if (!printOnlyTimes) cout << "Przycpieszenie: " << (czasCPU / czasGPU ) << endl;
}

