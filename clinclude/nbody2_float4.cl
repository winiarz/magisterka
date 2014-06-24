
#include "constants.cl"

__kernel void nbody2_float4 ( __global float* x,  __global float* y,  __global float* z, 
					         __global float* rx, __global float* ry, __global float* rz)
{
	uint tid = get_global_id(0);
	uint tsize = get_global_size(0);
	
	__global float16* nx = (__global float16*) x;
	__global float16* ny = (__global float16*) y;
	__global float16* nz = (__global float16*) z;
	
	__global float16* nrx = (__global float16*) rx;
	__global float16* nry = (__global float16*) ry;
	__global float16* nrz = (__global float16*) rz;

	for( uint i=tid; i < c_N16; i+= tsize)
	{
		float16 lx = nx[i];
		float16 ly = ny[i];
		float16 lz = nz[i];

		float16 lrx=0.0f;
		float16 lry=0.0f;
		float16 lrz=0.0f;

		for( uint j=0; j < c_N; j++)
		{
			float lx2 = x[j];
			float ly2 = y[j];
			float lz2 = z[j];
			
			float16 sx1 = lx - lx2;
			float16 sy1 = ly - ly2;
			float16 sz1 = lz - lz2;
			float16 d_sq1 = sx1*sx1 + sy1*sy1 + sz1*sz1 + c_Epsilon;
			float16 d1 = sqrt( d_sq1 );
			float16 G_r3 = c_G / ( d_sq1 * d1 );

			lrx += sx1 * G_r3;
			lry += sy1 * G_r3;
			lrz += sz1 * G_r3;
		}
		
		nrx[i] = lrx;
		nry[i] = lry;
		nrz[i] = lrz;
	} 
}
