#include "constants.cl"
__constant const uint LOCAL_SIZE = 128;
__constant const uint PRIVATE_SIZE = 2;


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

    __global float4* g_nx4 = (__global float4*) g_nX;
    __global float4* g_ny4 = (__global float4*) g_nY;
    __global float4* g_nz4 = (__global float4*) g_nZ;

    __global float4* g_ox4 = (__global float4*) g_oX;
    __global float4* g_oy4 = (__global float4*) g_oY;
    __global float4* g_oz4 = (__global float4*) g_oZ;

    __local float4 l_X[LOCAL_SIZE];
    __local float4 l_Y[LOCAL_SIZE];
    __local float4 l_Z[LOCAL_SIZE];

    float4 r_rX[PRIVATE_SIZE];
    float4 r_rY[PRIVATE_SIZE];
    float4 r_rZ[PRIVATE_SIZE];

    for( uint r_k=0; r_k<c_N4/(LOCAL_SIZE*r_groupSize); r_k++)
    {
        
        uint r_offset = LOCAL_SIZE*r_group + r_k*r_groupSize*LOCAL_SIZE;

        //uint r_i=get_local_id(0);
        for( uint r_i=get_local_id(0); r_i < LOCAL_SIZE; r_i+=get_local_size(0))
        {
            l_X[r_i] = g_x4[r_i + r_offset];
            l_Y[r_i] = g_y4[r_i + r_offset];
            l_Z[r_i] = g_z4[r_i + r_offset];
        }

        r_rX[0] = r_rX[1] = 0.0f;
        r_rY[0] = r_rY[1] = 0.0f;
        r_rZ[0] = r_rZ[1] = 0.0f;

        /*r_rX[0] = r_rX[1] = r_rX[2] = r_rX[3] = 0.0f;
        r_rY[0] = r_rY[1] = r_rY[2] = r_rY[3] = 0.0f;
        r_rZ[0] = r_rZ[1] = r_rZ[2] = r_rZ[3] = 0.0f;*/

        for( uint r_j=0; r_j<c_N4; r_j++)
        {
            float r_x = g_X[r_j];
            float r_y = g_Y[r_j];
            float r_z = g_Z[r_j];

            //for( uint r_i=get_local_id(0); r_i < LOCAL_SIZE; r_i+=get_local_size(0))
            {
                float4 r_dx = l_X[get_local_id(0)] - r_x;
                float4 r_dy = l_Y[get_local_id(0)] - r_y;
                float4 r_dz = l_Z[get_local_id(0)] - r_z;

                float4 r_dist_sq = r_dx*r_dx + r_dy*r_dy + r_dz*r_dz + c_Epsilon;
                float4 r_dist_minus1 = rsqrt( r_dist_sq);
                //float4 r_dist_minus3 = g_m4[r_j] / ( r_dist_sq * r_dist );
                float4 r_dist_minus3 = g_m4[r_j] * r_dist_minus1 * r_dist_minus1 * r_dist_minus1;
                
                r_dx *= r_dist_minus3;
                r_dy *= r_dist_minus3;
                r_dz *= r_dist_minus3;

                r_rX[0] += r_dx.x + r_dx.y + r_dx.z + r_dx.w;
                r_rY[0] += r_dy.x + r_dy.y + r_dy.z + r_dy.w;
                r_rZ[0] += r_dz.x + r_dz.y + r_dz.z + r_dz.w;
            }

            {
                uint r_i=get_local_id(0) + get_local_size(0);
                float4 r_dx = l_X[r_i] - r_x;
                float4 r_dy = l_Y[r_i] - r_y;
                float4 r_dz = l_Z[r_i] - r_z;

                float4 r_dist_sq = r_dx*r_dx + r_dy*r_dy + r_dz*r_dz + c_Epsilon;
                float4 r_dist_minus1 = rsqrt( r_dist_sq);
                float4 r_dist_minus3 = g_m4[r_j] * r_dist_minus1 * r_dist_minus1 * r_dist_minus1;
                //float4 r_dist_minus3 = g_m4[r_j] / ( r_dist_sq * r_dist );
                
                r_dx *= r_dist_minus3;
                r_dy *= r_dist_minus3;
                r_dz *= r_dist_minus3;

                r_rX[1] += r_dx.x + r_dx.y + r_dx.z + r_dx.w;
                r_rY[1] += r_dy.x + r_dy.y + r_dy.z + r_dy.w;
                r_rZ[1] += r_dz.x + r_dz.y + r_dz.z + r_dz.w;
            }

            /*{
                uint r_i=get_local_id(0) + 2*get_local_size(0);
                float4 r_dx = l_X[r_i] - r_x;
                float4 r_dy = l_Y[r_i] - r_y;
                float4 r_dz = l_Z[r_i] - r_z;

                float4 r_dist_sq = r_dx*r_dx + r_dy*r_dy + r_dz*r_dz + c_Epsilon;
                float4 r_dist = sqrt( r_dist_sq);
                float4 r_dist_minus3 = g_m4[r_j] / ( r_dist_sq * r_dist );
                
                r_dx *= r_dist_minus3;
                r_dy *= r_dist_minus3;
                r_dz *= r_dist_minus3;

                r_rX[2] += r_dx.x + r_dx.y + r_dx.z + r_dx.w;
                r_rY[2] += r_dy.x + r_dy.y + r_dy.z + r_dy.w;
                r_rZ[2] += r_dz.x + r_dz.y + r_dz.z + r_dz.w;
            }

            {
                uint r_i=get_local_id(0) + 3*get_local_size(0);
                float4 r_dx = l_X[r_i] - r_x;
                float4 r_dy = l_Y[r_i] - r_y;
                float4 r_dz = l_Z[r_i] - r_z;

                float4 r_dist_sq = r_dx*r_dx + r_dy*r_dy + r_dz*r_dz + c_Epsilon;
                float4 r_dist = sqrt( r_dist_sq);
                float4 r_dist_minus3 = g_m4[r_j] / ( r_dist_sq * r_dist );
                
                r_dx *= r_dist_minus3;
                r_dy *= r_dist_minus3;
                r_dz *= r_dist_minus3;

                r_rX[3] += r_dx.x + r_dx.y + r_dx.z + r_dx.w;
                r_rY[3] += r_dy.x + r_dy.y + r_dy.z + r_dy.w;
                r_rZ[3] += r_dz.x + r_dz.y + r_dz.z + r_dz.w;
            }*/

        }

        //for( uint r_i=get_local_id(0); r_i < LOCAL_SIZE; r_i+= get_local_size(0))
        {
            uint r_i=get_local_id(0);
            g_nx4[r_i + r_offset] = 2.0f * l_X[r_i] - g_ox4[r_i + r_offset] + c_G * r_rX[0] * c_delta_t * c_delta_t;
            g_ny4[r_i + r_offset] = 2.0f * l_Y[r_i] - g_oy4[r_i + r_offset] + c_G * r_rY[0] * c_delta_t * c_delta_t;
            g_nz4[r_i + r_offset] = 2.0f * l_Z[r_i] - g_oz4[r_i + r_offset] + c_G * r_rZ[0] * c_delta_t * c_delta_t;
        }

        {
            uint r_i=get_local_id(0) + get_local_size(0);
            g_nx4[r_i + r_offset] = 2.0f * l_X[r_i] - g_ox4[r_i + r_offset] + c_G * r_rX[1] * c_delta_t * c_delta_t;
            g_ny4[r_i + r_offset] = 2.0f * l_Y[r_i] - g_oy4[r_i + r_offset] + c_G * r_rY[1] * c_delta_t * c_delta_t;
            g_nz4[r_i + r_offset] = 2.0f * l_Z[r_i] - g_oz4[r_i + r_offset] + c_G * r_rZ[1] * c_delta_t * c_delta_t;
        }

        /*{
            uint r_i=get_local_id(0) + 2*get_local_size(0);
            g_nx4[r_i + r_offset] = 2.0f * l_X[r_i] - g_ox4[r_i + r_offset] + c_G * r_rX[2] * c_delta_t * c_delta_t;
            g_ny4[r_i + r_offset] = 2.0f * l_Y[r_i] - g_oy4[r_i + r_offset] + c_G * r_rY[2] * c_delta_t * c_delta_t;
            g_nz4[r_i + r_offset] = 2.0f * l_Z[r_i] - g_oz4[r_i + r_offset] + c_G * r_rZ[2] * c_delta_t * c_delta_t;
        }

        {
            uint r_i=get_local_id(0) + 3*get_local_size(0);
            g_nx4[r_i + r_offset] = 2.0f * l_X[r_i] - g_ox4[r_i + r_offset] + c_G * r_rX[3] * c_delta_t * c_delta_t;
            g_ny4[r_i + r_offset] = 2.0f * l_Y[r_i] - g_oy4[r_i + r_offset] + c_G * r_rY[3] * c_delta_t * c_delta_t;
            g_nz4[r_i + r_offset] = 2.0f * l_Z[r_i] - g_oz4[r_i + r_offset] + c_G * r_rZ[3] * c_delta_t * c_delta_t;
        }*/
    }
}

