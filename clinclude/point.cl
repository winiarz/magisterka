
struct point
{
    float4 positionMass;
    float4 oldPosition;
    float4 newPosition;
};

float dist(struct point A, struct point B)
{
    float4 sub = A.positionMass - B.positionMass;
    sub = sub*sub;
    return sqrt(sub.x + sub.y + sub.z);
}

