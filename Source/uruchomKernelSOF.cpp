#include "main.hpp"

float zera[c_N];

void zerujWyniki(vector<ClMemory*>& daneTestoweGpu)
{
    daneTestoweGpu[6]->copyIn(zera, 0, c_N*sizeof(float));
    daneTestoweGpu[7]->copyIn(zera, 0, c_N*sizeof(float));
    daneTestoweGpu[8]->copyIn(zera, 0, c_N*sizeof(float));
}
