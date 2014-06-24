#include "main.hpp"

float zera[c_N];

void zerujWyniki(vector<ClMemory*>& daneTestoweGpu)
{
    daneTestoweGpu[3]->copyIn(zera, 0, c_N*sizeof(float));
    daneTestoweGpu[4]->copyIn(zera, 0, c_N*sizeof(float));
    daneTestoweGpu[5]->copyIn(zera, 0, c_N*sizeof(float));
}
