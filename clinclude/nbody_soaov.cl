#include "constants.cl"
__constant const uint LOCAL_SIZE = 256;
__constant const uint PRIVATE_SIZE = 4;

__kernel void nbody_soaov( __global float4* g_currentPos,
                           __global float4* g_oldPos,
                           __global float4* g_newPos )
{
    uint r_group = get_global_id(0) / get_local_size(0);
    uint r_groupSize = get_global_size(0) / get_local_size(0);

    __local float4 l_X[LOCAL_SIZE];
    __local float4 l_Y[LOCAL_SIZE];
    __local float4 l_Z[LOCAL_SIZE];

    float4 r_rX[PRIVATE_SIZE];
    float4 r_rY[PRIVATE_SIZE];
    float4 r_rZ[PRIVATE_SIZE];

    for( uint r_k=0; r_k<c_N4/(LOCAL_SIZE*get_global_size(0) / get_local_size(0)); r_k++)
    {
        r_rX[0] = r_rX[1] = r_rX[2] = r_rX[3] = 0.0f;
        r_rY[0] = r_rY[1] = r_rY[2] = r_rY[3] = 0.0f;
        r_rZ[0] = r_rZ[1] = r_rZ[2] = r_rZ[3] = 0.0f;

        uint r_offset = LOCAL_SIZE*get_global_id(0)/get_local_size(0) + r_k*get_global_size(0) / get_local_size(0)*LOCAL_SIZE;

        for( uint r_i=get_local_id(0); r_i < LOCAL_SIZE; r_i+=get_local_size(0))
        {
            uint r_j=4*(r_i + r_offset);

            l_X[r_i].x = g_currentPos[r_j].x;
            l_Y[r_i].x = g_currentPos[r_j].y;
            l_Z[r_i].x = g_currentPos[r_j].z;

            l_X[r_i].y = g_currentPos[r_j+1].x;
            l_Y[r_i].y = g_currentPos[r_j+1].y;
            l_Z[r_i].y = g_currentPos[r_j+1].z;

            l_X[r_i].z = g_currentPos[r_j+2].x;
            l_Y[r_i].z = g_currentPos[r_j+2].y;
            l_Z[r_i].z = g_currentPos[r_j+2].z;

            l_X[r_i].w = g_currentPos[r_j+3].x;
            l_Y[r_i].w = g_currentPos[r_j+3].y;
            l_Z[r_i].w = g_currentPos[r_j+3].z;
        }

        for( uint r_j=0; r_j<c_N; r_j++)
        {
            float4 r_current = g_currentPos[r_j];

            {
                float4 r_dx = l_X[get_local_id(0)] - r_current.x;
                float4 r_dy = l_Y[get_local_id(0)] - r_current.y;
                float4 r_dz = l_Z[get_local_id(0)] - r_current.z;

                float4 r_dist_sq = r_dx*r_dx + r_dy*r_dy + r_dz*r_dz + c_Epsilon;
                float4 r_dist_minus1 = rsqrt( r_dist_sq);
                float4 r_dist_minus3 = r_current.w * r_dist_minus1 * r_dist_minus1 * r_dist_minus1;
                
                r_dx *= r_dist_minus3;
                r_dy *= r_dist_minus3;
                r_dz *= r_dist_minus3;

                r_rX[0] += r_dx;
                r_rY[0] += r_dy;
                r_rZ[0] += r_dz;
            }

            {
                uint r_i=get_local_id(0) + get_local_size(0);
                float4 r_dx = l_X[r_i] - r_current.x;
                float4 r_dy = l_Y[r_i] - r_current.y;
                float4 r_dz = l_Z[r_i] - r_current.z;

                float4 r_dist_sq = r_dx*r_dx + r_dy*r_dy + r_dz*r_dz + c_Epsilon;
                float4 r_dist_minus1 = rsqrt( r_dist_sq);
                float4 r_dist_minus3 = r_current.w * r_dist_minus1 * r_dist_minus1 * r_dist_minus1;
                
                r_dx *= r_dist_minus3;
                r_dy *= r_dist_minus3;
                r_dz *= r_dist_minus3;

                r_rX[1] += r_dx;
                r_rY[1] += r_dy;
                r_rZ[1] += r_dz;
            }

            {
                uint r_i=get_local_id(0) + get_local_size(0) + get_local_size(0);
                float4 r_dx = l_X[r_i] - r_current.x;
                float4 r_dy = l_Y[r_i] - r_current.y;
                float4 r_dz = l_Z[r_i] - r_current.z;

                float4 r_dist_sq = r_dx*r_dx + r_dy*r_dy + r_dz*r_dz + c_Epsilon;
                float4 r_dist_minus1 = rsqrt( r_dist_sq);
                float4 r_dist_minus3 = r_current.w * r_dist_minus1 * r_dist_minus1 * r_dist_minus1;
                
                r_dx *= r_dist_minus3;
                r_dy *= r_dist_minus3;
                r_dz *= r_dist_minus3;

                r_rX[2] += r_dx;
                r_rY[2] += r_dy;
                r_rZ[2] += r_dz;
            }

            {
                uint r_i=get_local_id(0) + get_local_size(0) + get_local_size(0) + get_local_size(0);
                float4 r_dx = l_X[r_i] - r_current.x;
                float4 r_dy = l_Y[r_i] - r_current.y;
                float4 r_dz = l_Z[r_i] - r_current.z;

                float4 r_dist_sq = r_dx*r_dx + r_dy*r_dy + r_dz*r_dz + c_Epsilon;
                float4 r_dist_minus1 = rsqrt( r_dist_sq);
                float4 r_dist_minus3 = r_current.w * r_dist_minus1 * r_dist_minus1 * r_dist_minus1;
                
                r_dx *= r_dist_minus3;
                r_dy *= r_dist_minus3;
                r_dz *= r_dist_minus3;

                r_rX[3] += r_dx;
                r_rY[3] += r_dy;
                r_rZ[3] += r_dz;
            }
        }

        for (uint r_j=0;r_j<4;r_j++) 
        {
            uint r_i = get_local_id(0) + get_local_size(0)*r_j;
            uint pointNb = 4*(r_i + r_offset);
            
            g_newPos[pointNb  ].x = 2.0f * l_X[r_i].x - g_oldPos[pointNb  ].x + c_G * r_rX[r_j].x;
            g_newPos[pointNb  ].y = 2.0f * l_Y[r_i].x - g_oldPos[pointNb  ].y + c_G * r_rY[r_j].x;
            g_newPos[pointNb  ].z = 2.0f * l_Z[r_i].x - g_oldPos[pointNb  ].z + c_G * r_rZ[r_j].x;

            g_newPos[pointNb+1].x = 2.0f * l_X[r_i].y - g_oldPos[pointNb+1].x + c_G * r_rX[r_j].y;
            g_newPos[pointNb+1].y = 2.0f * l_Y[r_i].y - g_oldPos[pointNb+1].y + c_G * r_rY[r_j].y;
            g_newPos[pointNb+1].z = 2.0f * l_Z[r_i].y - g_oldPos[pointNb+1].z + c_G * r_rZ[r_j].y;

            g_newPos[pointNb+2].x = 2.0f * l_X[r_i].z - g_oldPos[pointNb+2].x + c_G * r_rX[r_j].z;
            g_newPos[pointNb+2].y = 2.0f * l_Y[r_i].z - g_oldPos[pointNb+2].y + c_G * r_rY[r_j].z;
            g_newPos[pointNb+2].z = 2.0f * l_Z[r_i].z - g_oldPos[pointNb+2].z + c_G * r_rZ[r_j].z;

            g_newPos[pointNb+3].x = 2.0f * l_X[r_i].w - g_oldPos[pointNb+3].x + c_G * r_rX[r_j].w;
            g_newPos[pointNb+3].y = 2.0f * l_Y[r_i].w - g_oldPos[pointNb+3].y + c_G * r_rY[r_j].w;
            g_newPos[pointNb+3].z = 2.0f * l_Z[r_i].w - g_oldPos[pointNb+3].z + c_G * r_rZ[r_j].w;
        }
    }
}

