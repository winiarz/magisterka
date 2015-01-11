#include "main.hpp"

int sprawdzWyniki(float* wynikiX, float* wynikiY, float* wynikiZ, float** daneTesoweCpu)
{
    int iloscBledow=0;
    for (uint i=0; i<c_N; i++) 
    {
        if ( fabs(wynikiX[i] - daneTesoweCpu[6][i]) > dopuszczalnyBlad ) 
        {
            cout << "Nieprawidlowy wynik!: X[" << i << "] = " << wynikiX[i] << " a powien byc " << daneTesoweCpu[6][i] << endl;
            iloscBledow++;
        }
        
        if ( fabs(wynikiY[i] - daneTesoweCpu[7][i]) > dopuszczalnyBlad ) 
        {
            cout << "Nieprawidlowy wynik!: Y[" << i << "] = " << wynikiY[i] << " a powien byc " << daneTesoweCpu[7][i] << endl;
            iloscBledow++;
        }
        
        if ( fabs(wynikiZ[i] - daneTesoweCpu[8][i]) > dopuszczalnyBlad ) 
        {
            cout << "Nieprawidlowy wynik!: Z[" << i << "] = " << wynikiZ[i] << " a powien byc " << daneTesoweCpu[8][i] << endl;
            iloscBledow++;
        }

        if ( iloscBledow >= maxBledow ) 
            return 0;
    }
    return 1;
}
