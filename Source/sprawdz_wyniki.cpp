#include "main.hpp"

const float dopuszczalnyBlad = 0.005;

int sprawdzWyniki(float* wynikiX, float* wynikiY, float* wynikiZ, float** daneTesoweCpu)
{
    for (uint i=0; i<c_N; i++) 
    {
        if ( fabs(wynikiX[i] - daneTesoweCpu[3][i]) > dopuszczalnyBlad ) 
        {
            cout << "Nieprawidlowy wynik!: X[" << i << "] = " << wynikiX[i] << " a powien byc " << daneTesoweCpu[3][i] << endl;
            return 1;
        }
        
        if ( fabs(wynikiY[i] - daneTesoweCpu[4][i]) > dopuszczalnyBlad ) 
        {
            cout << "Nieprawidlowy wynik!: Y[" << i << "] = " << wynikiY[i] << " a powien byc " << daneTesoweCpu[4][i] << endl;
            return 1;
        }
        
        if ( fabs(wynikiZ[i] - daneTesoweCpu[5][i]) > dopuszczalnyBlad ) 
        {
            cout << "Nieprawidlowy wynik!: Z[" << i << "] = " << wynikiZ[i] << " a powien byc " << daneTesoweCpu[5][i] << endl;
            return 1;
        }
    }
    return 0;
}
