#include "constants.cl"

__kernel void simplestNbody0( __global float* g_X,  __global float* g_Y,  __global float* g_Z,
                              __global float* g_oX, __global float* g_oY, __global float* g_oZ,
                              __global float* g_nX, __global float* g_nY, __global float* g_nZ,
                              __global float* g_m )
{
    uint r_gid = get_global_id(0);
	uint r_gsize = get_global_size(0);

    for( uint r_i = r_gid; r_i<c_N; r_i+=r_gsize )
    {
        float resultX = 0.0f;
        float resultY = 0.0f;
        float resultZ = 0.0f;

        for( uint r_j=0; r_j<c_N; r_j++ )
            if ( r_i != r_j ) 
            {
            float r_dx = g_X[r_i] - g_X[r_j];
            float r_dy = g_Y[r_i] - g_Y[r_j];
            float r_dz = g_Z[r_i] - g_Z[r_j];

            float r_dist_sq = r_dx*r_dx + r_dy*r_dy + r_dz*r_dz;// + c_Epsilon;
            float r_dist = sqrt( r_dist_sq);
		    float r_dist_minus3 = g_m[r_i] * g_m[r_j] / ( r_dist_sq * r_dist );

            resultX += r_dx * r_dist_minus3;
            resultY += r_dy * r_dist_minus3;
            resultZ += r_dz * r_dist_minus3;
        }

        float forceX = c_G * resultX / g_m[r_i];
        float forceY = c_G * resultY / g_m[r_i];
        float forceZ = c_G * resultZ / g_m[r_i];

        g_nX[r_i] = 2.0f * g_X[r_i] - g_oX[r_i] + forceX * c_delta_t*c_delta_t;
        g_nY[r_i] = 2.0f * g_Y[r_i] - g_oY[r_i] + forceY * c_delta_t*c_delta_t;
        g_nZ[r_i] = 2.0f * g_Z[r_i] - g_oZ[r_i] + forceZ * c_delta_t*c_delta_t;
    }

}

__kernel void simplestNbody1( __global float* g_X,  __global float* g_Y,  __global float* g_Z,
                              __global float* g_oX, __global float* g_oY, __global float* g_oZ,
                              __global float* g_nX, __global float* g_nY, __global float* g_nZ,
                              __global float* g_m )
{
    uint r_gid = get_global_id(0);
	uint r_gsize = get_global_size(0);

    for( uint r_i = r_gid; r_i<c_N; r_i+=r_gsize )
    {
        float resultX = 0.0f;
        float resultY = 0.0f;
        float resultZ = 0.0f;

        for( uint r_j=0; r_j<c_N; r_j++ )
        {
            float r_dx = g_X[r_i] - g_X[r_j];
            float r_dy = g_Y[r_i] - g_Y[r_j];
            float r_dz = g_Z[r_i] - g_Z[r_j];

            float r_dist_sq = r_dx*r_dx + r_dy*r_dy + r_dz*r_dz + c_Epsilon;
            float r_dist = sqrt( r_dist_sq);
		    float r_dist_minus3 = g_m[r_i] * g_m[r_j] / ( r_dist_sq * r_dist );

            resultX += r_dx * r_dist_minus3;
            resultY += r_dy * r_dist_minus3;
            resultZ += r_dz * r_dist_minus3;
        }

        float forceX = c_G * resultX / g_m[r_i];
        float forceY = c_G * resultY / g_m[r_i];
        float forceZ = c_G * resultZ / g_m[r_i];

        g_nX[r_i] = 2.0f * g_X[r_i] - g_oX[r_i] + forceX * c_delta_t*c_delta_t;
        g_nY[r_i] = 2.0f * g_Y[r_i] - g_oY[r_i] + forceY * c_delta_t*c_delta_t;
        g_nZ[r_i] = 2.0f * g_Z[r_i] - g_oZ[r_i] + forceZ * c_delta_t*c_delta_t;
    }

}

__kernel void simplestNbody2( __global float* g_X,  __global float* g_Y,  __global float* g_Z,
                              __global float* g_oX, __global float* g_oY, __global float* g_oZ,
                              __global float* g_nX, __global float* g_nY, __global float* g_nZ,
                              __global float* g_m )
{
    uint r_gid = get_global_id(0);
	uint r_gsize = get_global_size(0);

    for( uint r_i = r_gid; r_i<c_N; r_i+=r_gsize )
    {
        float resultX = 0.0f;
        float resultY = 0.0f;
        float resultZ = 0.0f;

        for( uint r_j=0; r_j<c_N; r_j++ )
        {
            float r_dx = g_X[r_i] - g_X[r_j];
            float r_dy = g_Y[r_i] - g_Y[r_j];
            float r_dz = g_Z[r_i] - g_Z[r_j];

            float r_dist_sq = r_dx*r_dx + r_dy*r_dy + r_dz*r_dz + c_Epsilon;
            float r_dist = sqrt( r_dist_sq);
		    float r_dist_minus3 = g_m[r_j] / ( r_dist_sq * r_dist );

            resultX += r_dx * r_dist_minus3;
            resultY += r_dy * r_dist_minus3;
            resultZ += r_dz * r_dist_minus3;
        }

        float forceX = c_G * resultX;
        float forceY = c_G * resultY;
        float forceZ = c_G * resultZ;

        g_nX[r_i] = 2.0f * g_X[r_i] - g_oX[r_i] + forceX * c_delta_t*c_delta_t;
        g_nY[r_i] = 2.0f * g_Y[r_i] - g_oY[r_i] + forceY * c_delta_t*c_delta_t;
        g_nZ[r_i] = 2.0f * g_Z[r_i] - g_oZ[r_i] + forceZ * c_delta_t*c_delta_t;
    }

}

