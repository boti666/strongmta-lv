texture gTexture0 < string textureState="0,Texture"; >;
float colorMultiplier = 0.5;

sampler TextureSampler = sampler_state
{
	Texture = (gTexture0);
};

float4 PixelShaderFunction(float4 TextureCoordinate : TEXCOORD0, float4 Diffuse : COLOR0) : COLOR0
{
	float4 Tex = tex2D(TextureSampler, TextureCoordinate);

	Tex.r *= colorMultiplier;
	Tex.g *= colorMultiplier;
	Tex.b *= colorMultiplier;
	Tex.a *= Diffuse.a;

	return saturate(Tex);
}

technique Lightness
{
	pass P0
	{
		Texture[0] = gTexture0;
		PixelShader = compile ps_2_0 PixelShaderFunction();
	}
}

technique Fallback
{
	pass P0
	{
		// Do nothing
	}
}
