
#include "constants.cl"

__kernel void nbody_float4 ( __global float* x,  __global float* y,  __global float* z, 
					         __global float* rx, __global float* ry, __global float* rz)
{
	uint tid = get_global_id(0);
	uint tsize = get_global_size(0);
	
	__global float4* nx = (__global float4*) x;
	__global float4* ny = (__global float4*) y;
	__global float4* nz = (__global float4*) z;
	
	__global float4* nrx = (__global float4*) rx;
	__global float4* nry = (__global float4*) ry;
	__global float4* nrz = (__global float4*) rz;

	for( uint i=tid; i < c_N4; i+= tsize)
	{
		float4 lx = nx[i];
		float4 ly = ny[i];
		float4 lz = nz[i];

		float4 lrx=0.0f;
		float4 lry=0.0f;
		float4 lrz=0.0f;

		for( uint j=0; j < c_N; j++)
		{
			float lx2 = x[j];
			float ly2 = y[j];
			float lz2 = z[j];
			
			float4 sx1 = lx - lx2;
			float4 sy1 = ly - ly2;
			float4 sz1 = lz - lz2;
			float4 d_sq1 = sx1*sx1 + sy1*sy1 + sz1*sz1 + c_Epsilon;
			float4 d1 = sqrt( d_sq1 );
			float4 G_r3 = c_G / ( d_sq1 * d1 );

			lrx += sx1 * G_r3;
			lry += sy1 * G_r3;
			lrz += sz1 * G_r3;
		}
		
		nrx[i] = lrx;
		nry[i] = lry;
		nrz[i] = lrz;
	} 
}
