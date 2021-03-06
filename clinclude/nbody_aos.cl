#include "point.cl"
#include "constants.cl"

__kernel void nbody_aos1(__global struct point* points)
{
    for (uint i=get_global_id(0); i<c_N; i+=get_global_size(0))
    {
        struct point current = points[i];

        float4 force = 0.0f;
        for (uint j=0; j<c_N; ++j) 
        {
            struct point current2 = points[j];
            float4 sub = current.positionMass - current2.positionMass;
            float4 sub_sq = sub * sub;
            float dist_sq = sub_sq.x + sub_sq.y + sub_sq.z + c_Epsilon;
            float dist = sqrt(dist_sq);

            force += (current2.positionMass.w * sub) / ( dist * dist_sq );
        }

        points[i].newPosition = 2.0f * current.positionMass - current.oldPosition + c_G * force;// * c_delta_t * c_delta_t;
    }
}

__kernel void nbody_aos2(__global struct point* points)
{
    for (uint i=get_global_id(0); i<c_N; i+=2*get_global_size(0))
    {
        float4 positionMass = points[i].positionMass;
        float4 positionMass2 = points[i+get_global_size(0)].positionMass;

        float4 force = 0.0f;
        float4 force2 = 0.0f;

        for (uint j=0; j<c_N; ++j) 
        {
            float4 secondPositionMass = points[j].positionMass;

            {
                float4 sub = positionMass - secondPositionMass;
                float4 sub_sq = sub * sub;
                float dist_sq = sub_sq.x + sub_sq.y + sub_sq.z + c_Epsilon;
                float dist = sqrt(dist_sq);

                force += (secondPositionMass.w * sub) / ( dist * dist_sq );
            }

            {
                float4 sub = positionMass2 - secondPositionMass;
                float4 sub_sq = sub * sub;
                float dist_sq = sub_sq.x + sub_sq.y + sub_sq.z + c_Epsilon;
                float dist = sqrt(dist_sq);

                force2 += (secondPositionMass.w * sub) / ( dist * dist_sq );
            }
        }

        points[i].newPosition =
            2.0f * positionMass - points[i].oldPosition + c_G * force;
        points[i+get_global_size(0)].newPosition =
            2.0f * positionMass2 - points[i+get_global_size(0)].oldPosition + c_G;
    }
}


__constant const uint LOCAL_SIZE = 256;

__kernel void nbody_aos3(__global struct point* points)
{
    __local float4 positionMass[LOCAL_SIZE];
    float4 force[4];

    for (uint i=get_global_id(0); i<c_N; i+=4*get_global_size(0))
    {
        for (uint l=0;l<4;l++) 
        {
            force[l] = 0.0f;
            positionMass[get_local_id(0) + l*get_local_size(0)] = points[i+l*get_global_size(0)].positionMass;
        }

        for (uint j=0; j<c_N; ++j) 
        {
            float4 secondPositionMass = points[j].positionMass;
            float4 dist_sq;
            uint l = get_local_id(0);

            float4 sub1 = positionMass[l] - secondPositionMass;
            {
                float4 sub_sq = sub1 * sub1;
                dist_sq.x = sub_sq.x + sub_sq.y + sub_sq.z + c_Epsilon;
            }

            l+=get_local_size(0);
            float4 sub2 = positionMass[l] - secondPositionMass;
            {
                float4 sub_sq = sub2 * sub2;
                dist_sq.y = sub_sq.x + sub_sq.y + sub_sq.z + c_Epsilon;
            }

            l+=get_local_size(0);
            float4 sub3 = positionMass[l] - secondPositionMass;
            {
                float4 sub_sq = sub3 * sub3;
                dist_sq.z = sub_sq.x + sub_sq.y + sub_sq.z + c_Epsilon;
            }

            l+=get_local_size(0);
            float4 sub4 = positionMass[l] - secondPositionMass;
            {
                float4 sub_sq = sub4 * sub4;
                dist_sq.w = sub_sq.x + sub_sq.y + sub_sq.z + c_Epsilon;
            }

            dist_sq *= sqrt(dist_sq);

            force[0] += (secondPositionMass.w * sub1) / ( dist_sq.x );
            force[1] += (secondPositionMass.w * sub2) / ( dist_sq.y );
            force[2] += (secondPositionMass.w * sub3) / ( dist_sq.z );
            force[3] += (secondPositionMass.w * sub4) / ( dist_sq.w );
        }

        for (uint l=0;l<4;l++)
        {
            points[i+l*get_global_size(0)].newPosition =
                2.0f * positionMass[get_local_id(0) + l*get_local_size(0)] -
                points[i+l*get_global_size(0)].oldPosition +
                c_G * force[l];
        }
    }
}

//__constant const uint LOCAL_SIZE = 256;
__constant const uint PRIVATE_SIZE = 4;

__kernel void nbody_aos4(__global struct point* g_points)
{
    //uint r_group = get_global_id(0) / get_local_size(0);
    //uint r_groupSize = get_global_size(0) / get_local_size(0);

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

        //uint r_offset = LOCAL_SIZE*r_group + r_k*r_groupSize*LOCAL_SIZE;
        uint r_offset = LOCAL_SIZE*get_global_id(0)/get_local_size(0) + r_k*get_global_size(0) / get_local_size(0)*LOCAL_SIZE;

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

            /*{
            //r_rX[0] += rsqrt(l_X[get_local_id(0)] - r_current.x);
            //r_rY[0] += rsqrt(l_Y[get_local_id(0)] - r_current.y);
            //r_rZ[0] += rsqrt(l_Z[get_local_id(0)] - r_current.z);

                float4 r_dx = l_X[get_local_id(0)] - r_current.x;
                float4 r_dy = l_Y[get_local_id(0)] - r_current.y;
                float4 r_dz = l_Z[get_local_id(0)] - r_current.z;

                float4 r_dist_sq = (r_dx*r_dx + r_dy*r_dy + r_dz*r_dz + c_Epsilon);

                r_rX[0] += r_dx * r_dist_sq;
                r_rY[0] += r_dy * r_dist_sq;
                r_rZ[0] += r_dz * r_dist_sq;
            }

            r_rX[1] += rsqrt(l_X[get_local_size(0)+get_local_id(0)] - (r_current.x));
            r_rY[1] += rsqrt(l_Y[get_local_size(0)+get_local_id(0)] - (r_current.y));
            r_rZ[1] += rsqrt(l_Z[get_local_size(0)+get_local_id(0)] - (r_current.z));

            r_rX[2] += rsqrt(l_X[2*get_local_size(0)+get_local_id(0)] - (r_current.x));
            r_rY[2] += rsqrt(l_Y[2*get_local_size(0)+get_local_id(0)] - (r_current.y));
            r_rZ[2] += rsqrt(l_Z[2*get_local_size(0)+get_local_id(0)] - (r_current.z));

            r_rX[3] += rsqrt(l_X[3*get_local_size(0)+get_local_id(0)] - (r_current.x));
            r_rY[3] += rsqrt(l_Y[3*get_local_size(0)+get_local_id(0)] - (r_current.y));
            r_rZ[3] += rsqrt(l_Z[3*get_local_size(0)+get_local_id(0)] - (r_current.z));*/


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

