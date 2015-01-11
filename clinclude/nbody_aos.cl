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

        points[i].newPosition = 2.0f * current.positionMass - current.oldPosition + c_G * force * c_delta_t * c_delta_t;
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
            2.0f * positionMass - points[i].oldPosition + c_G * force * c_delta_t * c_delta_t;
        points[i+get_global_size(0)].newPosition =
            2.0f * positionMass2 - points[i+get_global_size(0)].oldPosition + c_G * force * c_delta_t * c_delta_t;
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
                c_G * force[l] * c_delta_t * c_delta_t;
        }
    }
}

