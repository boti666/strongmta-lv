float red;
float green;
float blue;

technique tint
{
    pass P0
    {
        MaterialAmbient = float4(red, green, blue, 1);
    }
}