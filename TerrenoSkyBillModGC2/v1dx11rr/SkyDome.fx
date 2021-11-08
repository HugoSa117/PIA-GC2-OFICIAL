Texture2D textures : register(t0);
Texture2D textures2 : register(t1);
SamplerState colorSampler : register(s0);

cbuffer MatrixBuffer
{
	matrix worldMatrix;
	matrix viewMatrix;
	matrix projMatrix;
	float4 valores;
};

cbuffer cbLightBuffers 
{
	float3 colorAmbiental;
	float blendSky;
}

struct VS_Input
{
	float4 pos : POSITION;
	float2 tex0 : TEXCOORD0;
};

struct PS_Input
{
	float4 pos : SV_POSITION;
	float2 tex0 : TEXCOORD0;
	float3 ambient : COLOR0;
	float blend : COLOR1;
};

PS_Input VS_Main(VS_Input vertex)
{
	PS_Input vsOut = (PS_Input)0;
	vsOut.pos = mul(vertex.pos, worldMatrix);
	vsOut.pos = mul(vsOut.pos, viewMatrix);
	vsOut.pos = mul(vsOut.pos, projMatrix);

	vsOut.tex0 = vertex.tex0;
	vsOut.ambient = colorAmbiental;
	vsOut.blend = blendSky;
	return vsOut;
}

float4 PS_Main(PS_Input pix) : SV_TARGET
{
	
	float4 tex1 = textures.Sample(colorSampler, pix.tex0);
	float4 tex2 = textures2.Sample(colorSampler, pix.tex0);
	//pix.blend
	float4 finalColor = lerp(tex1, tex2, pix.blend);
	//float4 finalColor = tex1;

	////////////////////////LUZ AMBIENTAL////////////////////////
	float4 luz = float4(1,1,1, 1);
	float4 LuzAmbiental = float4(pix.ambient, 1);	//luz ambiental
	float FA = 1.2;									//factor atenuacion ambiental
	float4 AportAmb = LuzAmbiental * FA;			//aportacion ambiental


	return finalColor * AportAmb;
}