#include "point.cl"
#include "constants.cl"


__constant const uint LOCAL_SIZE = 256;
__constant const uint PRIVATE_SIZE = 4;

__kernel void nbody_aos4(__global struct point* g_points)
{
    uint r_group = get_global_id(0) / get_local_size(0);
    uint r_groupSize = get_global_size(0) / get_local_size(0);

    __local float4 l_X[LOCAL_SIZE];
    __local float4 l_Y[LOCAL_SIZE];
    __local float4 l_Z[LOCAL_SIZE];

    float4 r_rX[PRIVATE_SIZE];
    float4 r_rY[PRIVATE_SIZE];
    float4 r_rZ[PRIVATE_SIZE];

    for( uint r_k=0; r_k<c_N4/(LOCAL_SIZE*r_groupSize); r_k++)
    {
        r_rX[0] = r_rX[1] = r_rX[2] = r_rX[3] = 0.0f;
        r_rY[0] = r_rY[1] = r_rY[2] = r_rY[3] = 0.0f;
        r_rZ[0] = r_rZ[1] = r_rZ[2] = r_rZ[3] = 0.0f;

        uint r_offset = LOCAL_SIZE*r_group + r_k*r_groupSize*LOCAL_SIZE;

        for( uint r_i=get_local_id(0); r_i < LOCAL_SIZE; r_i+=get_local_size(0))
        {
            uint r_j=4*(r_i + r_offset);
            /*float4 l_readPositionMass = g_points[r_j  ].positionMass;
            l_X[r_i].x = l_readPositionMass.x;
            l_Y[r_i].x = l_readPositionMass.y;
            l_Z[r_i].x = l_readPositionMass.z;

            r_j++;
            l_readPositionMass = g_points[r_j  ].positionMass;
            l_X[r_i].y = l_readPositionMass.x;
            l_Y[r_i].y = l_readPositionMass.y;
            l_Z[r_i].y = l_readPositionMass.z;

            r_j++;
            l_readPositionMass = g_points[r_j  ].positionMass;
            l_X[r_i].z = l_readPositionMass.x;
            l_Y[r_i].z = l_readPositionMass.y;
            l_Z[r_i].z = l_readPositionMass.z;

            r_j++;
            l_readPositionMass = g_points[r_j  ].positionMass;
            l_X[r_i].w = l_readPositionMass.x;
            l_Y[r_i].w = l_readPositionMass.y;
            l_Z[r_i].w = l_readPositionMass.z;*/

            {
                l_X[r_i].x = g_points[r_j].positionMass.x;
                l_Y[r_i].x = g_points[r_j].positionMass.y;
                l_Z[r_i].x = g_points[r_j].positionMass.z;

                l_X[r_i].y = g_points[r_j+1].positionMass.x;
                l_Y[r_i].y = g_points[r_j+1].positionMass.y;
                l_Z[r_i].y = g_points[r_j+1].positionMass.z;

                l_X[r_i].z = g_points[r_j+2].positionMass.x;
                l_Y[r_i].z = g_points[r_j+2].positionMass.y;
                l_Z[r_i].z = g_points[r_j+2].positionMass.z;

                l_X[r_i].w = g_points[r_j+3].positionMass.x;
                l_Y[r_i].w = g_points[r_j+3].positionMass.y;
                l_Z[r_i].w = g_points[r_j+3].positionMass.z;
            }
        }

        for( uint r_j=0; r_j<c_N; r_j++)
        {
            float4 r_current = g_points[r_j].positionMass;
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


        //for( uint r_i=get_local_id(0); r_i < LOCAL_SIZE; r_i+=get_local_size(0))
        for (uint r_j=0;r_j<4;r_j++) 
        {
            uint r_i = get_local_id(0) + get_local_size(0)*r_j;
            //uint r_j = r_i / get_local_size(0);
            uint pointNb = 4*(r_i + r_offset);
            
            g_points[pointNb  ].newPosition.x = 2.0f * l_X[r_i].x - g_points[pointNb  ].oldPosition.x + c_G * r_rX[r_j].x;
            g_points[pointNb  ].newPosition.y = 2.0f * l_Y[r_i].x - g_points[pointNb  ].oldPosition.y + c_G * r_rY[r_j].x;
            g_points[pointNb  ].newPosition.z = 2.0f * l_Z[r_i].x - g_points[pointNb  ].oldPosition.z + c_G * r_rZ[r_j].x;

            g_points[pointNb+1].newPosition.x = 2.0f * l_X[r_i].y - g_points[pointNb+1].oldPosition.x + c_G * r_rX[r_j].y;
            g_points[pointNb+1].newPosition.y = 2.0f * l_Y[r_i].y - g_points[pointNb+1].oldPosition.y + c_G * r_rY[r_j].y;
            g_points[pointNb+1].newPosition.z = 2.0f * l_Z[r_i].y - g_points[pointNb+1].oldPosition.z + c_G * r_rZ[r_j].y;

            g_points[pointNb+2].newPosition.x = 2.0f * l_X[r_i].z - g_points[pointNb+2].oldPosition.x + c_G * r_rX[r_j].z;
            g_points[pointNb+2].newPosition.y = 2.0f * l_Y[r_i].z - g_points[pointNb+2].oldPosition.y + c_G * r_rY[r_j].z;
            g_points[pointNb+2].newPosition.z = 2.0f * l_Z[r_i].z - g_points[pointNb+2].oldPosition.z + c_G * r_rZ[r_j].z;

            g_points[pointNb+3].newPosition.x = 2.0f * l_X[r_i].w - g_points[pointNb+3].oldPosition.x + c_G * r_rX[r_j].w;
            g_points[pointNb+3].newPosition.y = 2.0f * l_Y[r_i].w - g_points[pointNb+3].oldPosition.y + c_G * r_rY[r_j].w;
            g_points[pointNb+3].newPosition.z = 2.0f * l_Z[r_i].w - g_points[pointNb+3].oldPosition.z + c_G * r_rZ[r_j].w;


            /*float4 r_newPosition = (float4)(r_rX[r_j].x, r_rY[r_j].x, r_rZ[r_j].x, 0.0f);
            g_points[pointNb].newPosition = r_newPosition;

            r_newPosition = (float4)(r_rX[r_j].y, r_rY[r_j].y, r_rZ[r_j].y, 0.0f);
            g_points[pointNb+1].newPosition = r_newPosition;

            r_newPosition = (float4)(r_rX[r_j].z, r_rY[r_j].z, r_rZ[r_j].z, 0.0f);
            g_points[pointNb+2].newPosition = r_newPosition;

            r_newPosition = (float4)(r_rX[r_j].w, r_rY[r_j].w, r_rZ[r_j].w, 0.0f);
            g_points[pointNb+3].newPosition = r_newPosition;*/

        }
    }
}


