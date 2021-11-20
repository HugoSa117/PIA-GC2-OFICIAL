Texture2D colorMap : register(t0);
Texture2D normalMap : register(t1);
SamplerState colorSampler : register(s0);


cbuffer cbChangerEveryFrame : register(b0)
{
	matrix worldMatrix;
};

cbuffer cbNeverChanges : register(b1)
{
	matrix viewMatrix;
};

cbuffer cbChangeOnResize : register(b2)
{
	matrix projMatrix;
};

cbuffer cbLightBuffers : register(b3)
{
	float3 colorAmbiental;
	float3 colorDifuso;
	float3 direccionLuz;	//vector
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
	float3 diffuse : COLOR1;
	float3 lightDirection : TEXCOORD1;
};


PS_Input VS_Main(VS_Input vertex)
{
	PS_Input vsOut = (PS_Input)0;
	vsOut.pos = mul(vertex.pos, worldMatrix);
	vsOut.pos = mul(vsOut.pos, viewMatrix);
	vsOut.pos = mul(vsOut.pos, projMatrix);

	vsOut.tex0 = vertex.tex0;

	vsOut.ambient = colorAmbiental;
	vsOut.diffuse = colorDifuso;
	vsOut.lightDirection = normalize(direccionLuz);


	return vsOut;
}

float4 PS_Main(PS_Input pix) : SV_TARGET
{

	float4 textColor = colorMap.Sample(colorSampler, pix.tex0);
	float4 textNorm = normalMap.Sample(colorSampler, pix.tex0);

	if (textColor.a < 0.02) {
		
		clip(-1);
		return 0;
	}
	else {

		////////////////////////LUZ AMBIENTA////////////////////////
		float3 LuzAmbiental = pix.ambient;					//luz ambiental
		float FA = 0.65;									//factor atenuacion ambiental
		float3 AportAmb = saturate(LuzAmbiental * FA);		//aportacion ambiental

		////////////////////////LUZ DIFUSA////////////////////////
		float3 DirLuz = pix.lightDirection;				//Direccion de luz
		float3 LuzDifusa = pix.diffuse;					//luz difusa
		float FAD = 0.8;								//factor atenuacion difusa

		float3 bump = normalize(2.0 * textNorm - 1.0);			//de rgb a xyz
		float FALL = dot(normalize(DirLuz),bump);				//factor atenuacion ley de lambert
		float3 AportLuzDif = saturate(LuzDifusa * FALL * FAD);	//aportacion difusa

		////////////////////////RESULTADO////////////////////////
		float3 aportaciones = saturate(AportAmb + AportLuzDif);
		textColor = float4(textColor.rgb * aportaciones, 1);
		//textColor.a = 1;
		return textColor; 
	}
}