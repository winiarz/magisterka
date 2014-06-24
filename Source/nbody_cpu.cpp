
#include <omp.h>
#include <math.h>

typedef unsigned int uint;

#define __constant const
#include "constants.cl"

void nbody_cpu(float** dane)
{
    float** punkty = dane;
    float** wyniki = &dane[3];

#pragma omp parallel for
    for (uint i=0; i<c_N; i++)
    {
        wyniki[0][i] = wyniki[1][i] = wyniki[2][i] = 0.0f;

        for (uint j=0;j<c_N;j++) 
        {
            float odleglosc_x = dane[0][i] - punkty[0][j];
            float odleglosc_y = dane[1][i] - punkty[1][j];
            float odleglosc_z = dane[2][i] - punkty[2][j];

            float odleglosc_sq = odleglosc_x * odleglosc_x + 
                                 odleglosc_y * odleglosc_y + 
                                 odleglosc_z * odleglosc_z +
                                 c_Epsilon;
            float odleglosc = sqrt( odleglosc_sq );

            wyniki[0][i] += odleglosc_x / ( odleglosc * odleglosc_sq );
            wyniki[1][i] += odleglosc_y / ( odleglosc * odleglosc_sq );
            wyniki[2][i] += odleglosc_z / ( odleglosc * odleglosc_sq );
        }

        wyniki[0][i] *= c_G;
        wyniki[1][i] *= c_G;
        wyniki[2][i] *= c_G;
    }
}
