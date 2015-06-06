
struct point
{
    float4 positionMass;
    float4 oldPosition;
    float4 newPosition;
};

struct points
{
    float4 positionX;
    float4 positionY;
    float4 positionZ;

    float4 oldPositionX;
    float4 oldPositionY;
    float4 oldPositionZ;

    float4 newPositionX;
    float4 newPositionY;
    float4 newPositionZ;

    float4 mass;
};

float dist(struct point A, struct point B)
{
    float4 sub = A.positionMass - B.positionMass;
    sub = sub*sub;
    return sqrt(sub.x + sub.y + sub.z);
}

