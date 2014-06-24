#include "constants.cl"
__constant const uint LOCAL_SIZE = 1024;


__kernel void with_shared_and_float4( __global float* g_X,  __global float* g_Y,  __global float* g_Z,
                                     __global float* g_rX, __global float* g_rY, __global float* g_rZ )
{
    uint r_gid = get_global_id(0);
    uint r_gsize = get_global_size(0);
    uint r_lid = get_local_id(0);
    uint r_lsize = get_local_size(0);
    uint r_group = r_gid / r_gsize;
    uint r_groupSize = r_gsize/r_lsize;

    __global float4* nx = (__global float4*) g_X;
    __global float4* ny = (__global float4*) g_Y;
    __global float4* nz = (__global float4*) g_Z;

    __local float l_X[LOCAL_SIZE];
    __local float l_Y[LOCAL_SIZE];
    __local float l_Z[LOCAL_SIZE];

    __local float l_rX[LOCAL_SIZE];
    __local float l_rY[LOCAL_SIZE];
    __local float l_rZ[LOCAL_SIZE];


    for( uint r_k=0; r_k<c_N/(LOCAL_SIZE*r_groupSize); r_k++)
    {
        uint r_offset = LOCAL_SIZE*r_group + r_k*r_groupSize*LOCAL_SIZE;
        for( uint r_i=r_lid; r_i < LOCAL_SIZE; r_i+=r_lsize)
        {
            l_X[r_i] = g_X[r_i + r_offset];
            l_Y[r_i] = g_Y[r_i + r_offset];
            l_Z[r_i] = g_Z[r_i + r_offset];

            l_rX[r_i] = 0.0f;
            l_rY[r_i] = 0.0f;
            l_rZ[r_i] = 0.0f;
        }

        for( uint r_j=0; r_j<c_N; r_j++)
        {
            float4 r_x = nx[r_j];
            float4 r_y = ny[r_j];
            float4 r_z = nz[r_j];
        
            for( uint r_i=r_lid; r_i < LOCAL_SIZE; r_i+=r_lsize)
            {
                float4 r_dx = l_X[r_i] - r_x;
                float4 r_dy = l_Y[r_i] - r_y;
                float4 r_dz = l_Z[r_i] - r_z;

                float4 r_dist_sq = r_dx*r_dx + r_dy*r_dy + r_dz*r_dz + c_Epsilon;
                float4 r_dist = sqrt( r_dist_sq);
		float4 r_dist_minus3 = 1.0f / ( r_dist_sq * r_dist );

		float4 r_rx = r_dx * r_dist_minus3;
                l_rX[r_i] += r_rx.x + r_rx.y + r_rx.z + r_rx.w;
		float4 r_ry = r_dy * r_dist_minus3;
                l_rY[r_i] += r_ry.x + r_ry.y + r_ry.z + r_ry.w;
		float4 r_rz = r_dz * r_dist_minus3; 
                l_rZ[r_i] += r_rz.x + r_rz.y + r_rz.z + r_rz.w;
            }

        }

        for( uint r_i=r_lid; r_i < LOCAL_SIZE; r_i+=r_lsize)
        {
            g_rX[r_i + r_offset] = c_G * l_rX[r_i];
            g_rY[r_i + r_offset] = c_G * l_rY[r_i];
            g_rZ[r_i + r_offset] = c_G * l_rZ[r_i];
        }
    }
}

