
#include "constants.cl"

__kernel void nbody_float4 ( __global float* g_X,  __global float* g_Y,  __global float* g_Z, 
					         __global float* g_oX, __global float* g_oY, __global float* g_oZ,
                             __global float* g_nX, __global float* g_nY, __global float* g_nZ,
                             __global float* g_m)
{
	uint tid = get_global_id(0);
	uint tsize = get_global_size(0);
	
	__global float4* x = (__global float4*) g_X;
	__global float4* y = (__global float4*) g_Y;
	__global float4* z = (__global float4*) g_Z;
	
	__global float4* ox = (__global float4*) g_oX;
	__global float4* oy = (__global float4*) g_oY;
	__global float4* oz = (__global float4*) g_oZ;

    __global float4* nx = (__global float4*) g_nX;
	__global float4* ny = (__global float4*) g_nY;
	__global float4* nz = (__global float4*) g_nZ;

	for( uint i=tid; i < c_N4; i+= tsize)
	{
		float4 lx = x[i];
		float4 ly = y[i];
		float4 lz = z[i];

		float4 lrx=0.0f;
		float4 lry=0.0f;
		float4 lrz=0.0f;

		for( uint j=0; j < c_N; j++)
		{
			float lx2 = g_X[j];
			float ly2 = g_Y[j];
			float lz2 = g_Z[j];
			
			float4 sx1 = lx - lx2;
			float4 sy1 = ly - ly2;
			float4 sz1 = lz - lz2;
			float4 d_sq1 = sx1*sx1 + sy1*sy1 + sz1*sz1 + c_Epsilon;
			float4 d1 = sqrt( d_sq1 );
			float4 G_r3 = g_m[j] / ( d_sq1 * d1 );

			lrx += sx1 * G_r3;
			lry += sy1 * G_r3;
			lrz += sz1 * G_r3;
		}
		
		nx[i] = 2.0f * x[i] - ox[i] + c_G * lrx * c_delta_t * c_delta_t;
		ny[i] = 2.0f * y[i] - oy[i] + c_G * lry * c_delta_t * c_delta_t;
		nz[i] = 2.0f * z[i] - oz[i] + c_G * lrz * c_delta_t * c_delta_t;
	} 
}
