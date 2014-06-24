#include "main.hpp"

void przygotujDaneTestowe(float** daneTesoweCpu,
			  vector<ClMemory*>& daneTestoweGpu)
{
    for (uint i=0;i<6;i++) 
    {
        daneTesoweCpu[i] = new float[c_N];
        for (uint j=0;j<c_N;j++) 
        {
            daneTesoweCpu[i][j] = sin( float(i)*0.00314 + float(j)*0.00273 );
        }
        ClTypedMemory<float>* memory = new ClTypedMemory<float>(c_N);
        memory->copyIn( daneTesoweCpu[i], 0, c_N );
        daneTestoweGpu.push_back( memory );
    }
}
