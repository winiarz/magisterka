#include "constants.cl"
__constant const uint LOCAL_SIZE = 256;


__kernel void nbody_withSharedMem( __global float* g_X,  __global float* g_Y,  __global float* g_Z,
                                     __global float* g_rX, __global float* g_rY, __global float* g_rZ )
{
    uint r_group = get_global_id(0) / get_local_size(0);
    uint r_groupSize = get_global_size(0) / get_local_size(0);

    __global float16* g_x4 = (__global float16*) g_X;
    __global float16* g_y4 = (__global float16*) g_Y;
    __global float16* g_z4 = (__global float16*) g_Z;

    __local float l_X[LOCAL_SIZE];
    __local float l_Y[LOCAL_SIZE];
    __local float l_Z[LOCAL_SIZE];

    __local float l_rX[LOCAL_SIZE];
    __local float l_rY[LOCAL_SIZE];
    __local float l_rZ[LOCAL_SIZE];

    for( uint r_k=0; r_k<c_N/(LOCAL_SIZE*r_groupSize); r_k++)
    {
        
        uint r_offset = LOCAL_SIZE*r_group + r_k*r_groupSize*LOCAL_SIZE;

        for( uint r_i=get_local_id(0); r_i < LOCAL_SIZE; r_i+=get_local_size(0))
        {
            l_X[r_i] = g_X[r_i + r_offset];
            l_Y[r_i] = g_Y[r_i + r_offset];
            l_Z[r_i] = g_Z[r_i + r_offset];

            l_rX[r_i] = 0.0f;
            l_rY[r_i] = 0.0f;
            l_rZ[r_i] = 0.0f;
        }

        for( uint r_j=0; r_j<c_N16; r_j++)
        {
            float16 r_x = g_x4[r_j];
            float16 r_y = g_y4[r_j];
            float16 r_z = g_z4[r_j];

            for( uint r_i=get_local_id(0); r_i < LOCAL_SIZE; r_i+=get_local_size(0))
            {
                float16 r_dx = l_X[r_i] - r_x;
                float16 r_dy = l_Y[r_i] - r_y;
                float16 r_dz = l_Z[r_i] - r_z;

                float16 r_dist_sq = r_dx*r_dx + r_dy*r_dy + r_dz*r_dz + c_Epsilon;
                float16 r_dist = sqrt( r_dist_sq);
				float16 r_dist_minus3 = c_G / ( r_dist_sq * r_dist );
                
                r_dx *= r_dist_minus3;
                r_dy *= r_dist_minus3;
                r_dz *= r_dist_minus3;

                float4 r_res4x = r_dx.lo.lo + r_dx.lo.hi + r_dx.hi.lo + r_dx.hi.hi;
                float4 r_res4y = r_dy.lo.lo + r_dy.lo.hi + r_dy.hi.lo + r_dy.hi.hi;
                float4 r_res4z = r_dz.lo.lo + r_dz.lo.hi + r_dz.hi.lo + r_dz.hi.hi;
                l_rX[r_i] += r_res4x.x + r_res4x.y + r_res4x.z + r_res4x.w;
                l_rY[r_i] += r_res4y.x + r_res4y.y + r_res4y.z + r_res4y.w;
                l_rZ[r_i] += r_res4z.x + r_res4z.y + r_res4z.z + r_res4z.w;
            }

        }

        for( uint r_i=get_local_id(0); r_i < LOCAL_SIZE; r_i+= get_local_size(0))
        {
            g_rX[r_i + r_offset] = l_rX[r_i];
            g_rY[r_i + r_offset] = l_rY[r_i];
            g_rZ[r_i + r_offset] = l_rZ[r_i];
        }
    }
}

