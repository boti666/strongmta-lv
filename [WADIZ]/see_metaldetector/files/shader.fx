#include "mta-helper.fx"

struct PSInput
{
	float4 Position : POSITION0;

	float4 WorldPos : TEXCOORD0;
	float2 Pos : TEXCOORD1;
	float3 Normal : TEXCOORD2;


	float4 Diffuse : COLOR0;

};

struct VSInput
{
	float3 Position : POSITION0;
	float3 Normal : NORMAL0;

	float4 Diffuse : COLOR0;
};

const float PI = 3.14159265f;

PSInput VertexShaderFunction(VSInput VS)
{
	PSInput PS = (PSInput)0;

	MTAFixUpNormal( VS.Normal );

	PS.Position = mul(float4(VS.Position, 1), gWorldViewProjection);
	
	float4 worldPos = mul( float4(VS.Position.xyz,1) , gWorld );

	PS.WorldPos.xyz = worldPos.xyz;
	PS.Pos.xy = VS.Position.xy;

	float3 WorldNormal = MTACalcWorldNormal( VS.Normal );
	PS.Normal = WorldNormal;

	PS.Diffuse = MTACalcGTABuildingDiffuse(VS.Diffuse);

	return PS;
}

texture reflectionTexture;

sampler2D ReflectionSampler = sampler_state
{
	Texture = (reflectionTexture);
};

float RaySphereIntersect(float3 r0, float3 rd, float3 s0, float sr) {
	float a = dot(rd, rd);

	float3 s0_r0 = r0 - s0;
	float b = 2.0 * dot(rd, s0_r0);
	float c = dot(s0_r0, s0_r0) - (sr * sr);

	float disc = b * b - 4.0 * a* c;

	if (disc < 0.0) {
		return -1.0;
	}
	
	//return (-b - sqrt((b*b) - 4.0*a*c))/(2.0*a);

	return (-b + sqrt(disc)) / (2.0 * a);
}

const float3 ObjectPos = float3(0, 0, 0);

const float zcos = 0;
const float zsin = 0;

const float xcos = 0;
const float xsin = 0;

float3 rotpoint(float3 p) {
	float3 rotationZX = float3(zcos, zsin, 0);
	float3 rotationZY = float3(-zsin, zcos, 0);
	float3 rotationZZ = float3(0, 0, 1);
	
	float3 rotationYX = float3(1, 0, 0);
	float3 rotationYY = float3(0, xcos, xsin);
	float3 rotationYZ = float3(0, -xsin, xcos);

	float3 rotationABX = float3(
		rotationZX.x * rotationYX.x + rotationZX.y * rotationYY.x + rotationZX.z * rotationYZ.x,
		rotationZX.x * rotationYX.y + rotationZX.y * rotationYY.y + rotationZX.z * rotationYZ.y,
		rotationZX.x * rotationYX.z + rotationZX.y * rotationYY.z + rotationZX.z * rotationYZ.z
	);
	
	float3 rotationABY = float3(
		rotationZY.x * rotationYX.x + rotationZY.y * rotationYY.x + rotationZY.z * rotationYZ.x,
		rotationZY.x * rotationYX.y + rotationZY.y * rotationYY.y + rotationZY.z * rotationYZ.y,
		rotationZY.x * rotationYX.z + rotationZY.y * rotationYY.z + rotationZY.z * rotationYZ.z
	);
	
	float3 rotationABZ = float3(
		rotationZZ.x * rotationYX.x + rotationZZ.y * rotationYY.x + rotationZZ.z * rotationYZ.x,
		rotationZZ.x * rotationYX.y + rotationZZ.y * rotationYY.y + rotationZZ.z * rotationYZ.y,
		rotationZZ.x * rotationYX.z + rotationZZ.y * rotationYY.z + rotationZZ.z * rotationYZ.z
	);

	return float3(
			p.x*rotationABX.x + p.y*rotationABY.x + p.z*rotationABZ.x,
			p.x*rotationABX.y + p.y*rotationABY.y + p.z*rotationABZ.y,
			p.x*rotationABX.z + p.y*rotationABY.z + p.z*rotationABZ.z
		);
}

float easeOutQuad(float x, float p) {
	return 1 - pow((1 - x), p);
}

const float radius = 0.334406;
const float zp = 1;

float4 PixelShaderFunction(PSInput PS) : COLOR0
{
	float3 vec = normalize(PS.WorldPos.xyz - gCameraPosition);
	float d = RaySphereIntersect(gCameraPosition, vec, ObjectPos, radius);

	float3 dir = normalize(gCameraPosition + vec*d - ObjectPos);

	dir = rotpoint(dir);
		
	float theta;

	if(zp > 1)
		theta = acos( -easeOutQuad(-dir.z, zp) );
	else
		theta = acos( dir.z );
	
	float phi = atan2( dir.y, dir.x );

	phi += ( phi < 0 ) ? 2*PI : 0; 

	float4 col = tex2D(ReflectionSampler, float2(phi/(2*PI), (theta-PI/2)/(PI/2) ));

	//return float4((theta-PI/2)/(PI/2), 0, 0, 1);

	return col*PS.Diffuse;// + float4((theta-PI/2)/(PI/2)*0.36, (theta-PI/2)/(PI/2)*0.8, (theta-PI/2)/(PI/2)*0.2, 1)*0.25;
}

technique Technique1 
{
	pass Pass1 
	{
		//CullMode = 2;
		//ZEnable = true;

		VertexShader = compile vs_2_0 VertexShaderFunction();
		PixelShader = compile ps_2_a PixelShaderFunction(); 
	} 
}
