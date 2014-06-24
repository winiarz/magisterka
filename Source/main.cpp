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
    float* daneTesoweCpu[6];
    vector<ClMemory*> daneTestoweGpu;
    cout << "przygotowanie danych do testow" << endl;

    przygotujDaneTestowe(daneTesoweCpu, daneTestoweGpu);

    cout << "wersja na cpu (OpenMP):" << endl;

    int czasCPU = zmierzCzas( boost::bind( &nbody_cpu, daneTesoweCpu) );
    cout << "czas CPU = " << czasCPU << endl;

    cout << "Testowanie kerneli:" << endl;
    przygotujKompilator();

    int czasGPU;
    czasGPU = testujKernel(kernelLoader, daneTesoweCpu, daneTestoweGpu, "clinclude/simplest_nbody.cl","simplestNbody");
    cout << "Przycpieszenie: " << (czasCPU / czasGPU ) << endl;
    czasGPU = testujKernel(kernelLoader, daneTesoweCpu, daneTestoweGpu, "clinclude/simplest2.cl","simplestNbody2");
    cout << "Przycpieszenie: " << (czasCPU / czasGPU ) << endl;
    czasGPU = testujKernel(kernelLoader, daneTesoweCpu, daneTestoweGpu, "clinclude/nbody_float4.cl","nbody_float4");
    cout << "Przycpieszenie: " << (czasCPU / czasGPU ) << endl;
    czasGPU = testujKernel(kernelLoader, daneTesoweCpu, daneTestoweGpu, "clinclude/nbody.cl","nbody_withSharedMem");
    cout << "Przycpieszenie: " << (czasCPU / czasGPU ) << endl;
    czasGPU = testujKernel(kernelLoader, daneTesoweCpu, daneTestoweGpu, "clinclude/nbody2_float4.cl","nbody2_float4");
    cout << "Przycpieszenie: " << (czasCPU / czasGPU ) << endl;
}

