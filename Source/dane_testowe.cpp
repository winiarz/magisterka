#include "main.hpp"

void przygotujDaneTestowe(float** daneTesoweCpu,
			  vector<ClMemory*>& daneTestoweGpu)
{
    for (uint i=0;i<10;i++) 
        daneTesoweCpu[i] = new float[c_N];

    srand48(123456789);

    for( uint j=0;j<c_N;j++ ) 
    {
        daneTesoweCpu[0][j] = (posMax-posMin) * drand48() + posMin;
        daneTesoweCpu[1][j] = (posMax-posMin) * drand48() + posMin;
        daneTesoweCpu[2][j] = (posMax-posMin) * drand48() + posMin;

        daneTesoweCpu[3][j] = (velMax-velMin) * drand48() + velMin;
        daneTesoweCpu[4][j] = (velMax-velMin) * drand48() + velMin;
        daneTesoweCpu[5][j] = (velMax-velMin) * drand48() + velMin;

        daneTesoweCpu[9][j] = (massMax-massMin) * drand48() + massMin;
    }

    for (uint i=0;i<10;i++) 
    {
        ClTypedMemory<float>* memory = new ClTypedMemory<float>(c_N+4);
        memory->copyIn( daneTesoweCpu[i], 0, c_N );
        daneTestoweGpu.push_back( memory );
    }
}
