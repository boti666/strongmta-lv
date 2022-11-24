texture gTexture0           < string textureState="0,Texture"; >;
bool state = false;
float4 color = float4(1.0,0.0,0.0,1.0);
float brightness = 0.35;
float colorMul = 2;

sampler gTex = sampler_state
{
    Texture = <gTexture0>;
};

float4 JustColor(float4 dif : COLOR0, float4 spec :COLOR1, float2 TexCoord : TEXCOORD0) : COLOR0
{
    float4 mainColor = tex2D(gTex, TexCoord);
    if(state == true)
    {
        float4 finalColor = mainColor * dif;
        finalColor += spec;
        finalColor += color * brightness;
        return finalColor * colorMul;
    }
    float4 finalColor = mainColor * dif;
    finalColor += spec;
    return finalColor;
}

technique tec0
{
    pass P0
    {
        PixelShader = compile ps_2_0 JustColor();//compile ps_2_0 JustColor();
    }
}
