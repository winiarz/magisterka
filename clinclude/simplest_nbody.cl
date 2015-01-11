#include "constants.cl"

__kernel void simplestNbody( __global float* g_X,  __global float* g_Y,  __global float* g_Z,
                             __global float* g_oX, __global float* g_oY, __global float* g_oZ )
{
    uint r_gid = get_global_id(0);
	uint r_gsize = get_global_size(0);

    for( uint r_i = r_gid; r_i<c_N; r_i+=r_gsize )
    {
        g_rX[r_i] = 0.0f;
        g_rY[r_i] = 0.0f;
        g_rZ[r_i] = 0.0f;

        for( uint r_j=0; r_j<c_N; r_j++ )
        {
            float r_dx = g_X[r_i] - g_X[r_j];
            float r_dy = g_Y[r_i] - g_Y[r_j];
            float r_dz = g_Z[r_i] - g_Z[r_j];

            float r_dist_sq = r_dx*r_dx + r_dy*r_dy + r_dz*r_dz + c_Epsilon;
            float r_dist = sqrt( r_dist_sq);
					float r_dist_minus3 = 1.0f / ( r_dist_sq * r_dist );

            g_rX[r_i] += r_dx * r_dist_minus3;
            g_rY[r_i] += r_dy * r_dist_minus3;
            g_rZ[r_i] += r_dz * r_dist_minus3;
        }

        g_rX[r_i] *= c_G;
        g_rY[r_i] *= c_G;
        g_rZ[r_i] *= c_G;
    }
}

