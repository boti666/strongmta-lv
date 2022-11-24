texture browserTexture;

sampler SamplerTex = sampler_state
{
	Texture = (browserTexture);
};

float4 PSFunction(float4 TexCoord : TEXCOORD0, float4 Diffuse : COLOR0) : COLOR0
{
	float4 Tex = tex2D(SamplerTex, float2(TexCoord.x, TexCoord.y));
	//Tex.a *= Diffuse.a;
	//return saturate(Tex);
	return Tex;
}

technique tec0
{
	pass p0
	{
		Texture[0] = browserTexture;
		PixelShader = compile ps_2_0 PSFunction();
	}
}
