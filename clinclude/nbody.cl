#include "constants.cl"
__constant const uint LOCAL_SIZE = 256;


__kernel void nbody_withSharedMem( __global float* g_X,  __global float* g_Y,  __global float* g_Z,
                                   __global float* g_oX, __global float* g_oY, __global float* g_oZ,
                                   __global float* g_nX, __global float* g_nY, __global float* g_nZ,
                                   __global float* g_m )
{
    uint r_group = get_global_id(0) / get_local_size(0);
    uint r_groupSize = get_global_size(0) / get_local_size(0);

    __global float4* g_x4 = (__global float4*) g_X;
    __global float4* g_y4 = (__global float4*) g_Y;
    __global float4* g_z4 = (__global float4*) g_Z;
    __global float4* g_m4 = (__global float4*) g_m;

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

        for( uint r_j=0; r_j<c_N4; r_j++)
        {
            float4 r_x = g_x4[r_j];
            float4 r_y = g_y4[r_j];
            float4 r_z = g_z4[r_j];

            for( uint r_i=get_local_id(0); r_i < LOCAL_SIZE; r_i+=get_local_size(0))
            {
                float4 r_dx = l_X[r_i] - r_x;
                float4 r_dy = l_Y[r_i] - r_y;
                float4 r_dz = l_Z[r_i] - r_z;

                float4 r_dist_sq = r_dx*r_dx + r_dy*r_dy + r_dz*r_dz + c_Epsilon;
                float4 r_dist = sqrt( r_dist_sq);
                float4 r_dist_minus3 = g_m4[r_j] / ( r_dist_sq * r_dist );
                
                r_dx *= r_dist_minus3;
                r_dy *= r_dist_minus3;
                r_dz *= r_dist_minus3;

                l_rX[r_i] += r_dx.x + r_dx.y + r_dx.z + r_dx.w;
                l_rY[r_i] += r_dy.x + r_dy.y + r_dy.z + r_dy.w;
                l_rZ[r_i] += r_dz.x + r_dz.y + r_dz.z + r_dz.w;
            }

        }

        for( uint r_i=get_local_id(0); r_i < LOCAL_SIZE; r_i+= get_local_size(0))
        {
            g_nX[r_i + r_offset] = 2.0f * l_X[r_i] - g_oX[r_i + r_offset] + c_G * l_rX[r_i] * c_delta_t * c_delta_t;
            g_nY[r_i + r_offset] = 2.0f * l_Y[r_i] - g_oY[r_i + r_offset] + c_G * l_rY[r_i] * c_delta_t * c_delta_t;
            g_nZ[r_i + r_offset] = 2.0f * l_Z[r_i] - g_oZ[r_i + r_offset] + c_G * l_rZ[r_i] * c_delta_t * c_delta_t;
        }
    }
}

