#include <iostream>
using namespace std;
#include <omp.h>
#include <math.h>

typedef unsigned int uint;

#define __constant const
#include "constants.cl"

void nbody_cpu(float** dane)
{
    float** polozenia = dane;
    float** starePolozenia = &dane[3];
    float** wyniki = &dane[6];
    float*  masy   = dane[9];

    //omp_set_num_threads(6);

#pragma omp parallel for
    for (uint i=0; i<c_N; i++)
    {
        //cout << "START!! " << i << omp_get_thread_num() << endl;
        float silaX=0.0f;
        float silaY=0.0f;
        float silaZ=0.0f;

        for (uint j=0;j<c_N;j++) 
        {
            float odleglosc_x = dane[0][i] - polozenia[0][j];
            float odleglosc_y = dane[1][i] - polozenia[1][j];
            float odleglosc_z = dane[2][i] - polozenia[2][j];

            float odleglosc_sq = odleglosc_x * odleglosc_x + 
                                 odleglosc_y * odleglosc_y + 
                                 odleglosc_z * odleglosc_z +
                                 c_Epsilon;
            float odleglosc = sqrt( odleglosc_sq );

            silaX += masy[j] * odleglosc_x / ( odleglosc * odleglosc_sq );
            silaY += masy[j] * odleglosc_y / ( odleglosc * odleglosc_sq );
            silaZ += masy[j] * odleglosc_z / ( odleglosc * odleglosc_sq );
        }

        wyniki[0][i] = 2.0f * polozenia[0][i] - starePolozenia[0][i] + c_G * silaX * c_delta_t *c_delta_t;
        wyniki[1][i] = 2.0f * polozenia[1][i] - starePolozenia[1][i] + c_G * silaY * c_delta_t *c_delta_t;
        wyniki[2][i] = 2.0f * polozenia[2][i] - starePolozenia[2][i] + c_G * silaZ * c_delta_t *c_delta_t;

        //cout << "END!! " << i << omp_get_thread_num() << endl;
    }
}
