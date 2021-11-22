Texture2D colorMap : register(t0);
Texture2D normalMap : register(t1);
Texture2D colorMap2 : register(t2);
Texture2D normalMap2 : register(t3);
Texture2D colorMap3 : register(t4);
Texture2D normalMap3 : register(t5);
Texture2D blendMap : register(t6);
Texture2D blendMap2 : register(t7);
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
	float3 direccionLuz;
};

struct VS_Input
{
	float4 pos : POSITION;
	float2 tex0 : TEXCOORD0;
	float2 blendTex : TEXCOORD1;
	float2 blendTex2 : TEXCOORD2;
	float3 normal : NORMAL0;
	float3 tangente : NORMAL1;
	float3 binormal : NORMAL2;
};

struct PS_Input
{
	float4 pos : SV_POSITION;
	float2 tex0 : TEXCOORD0;

	float2 blendTex : TEXCOORD1;
	float2 blendTex2 : TEXCOORD2;
	float3 normal : NORMAL0;
	float3 tangent : NORMAL1;
	float3 binorm : NORMAL2;

	float3 ambient : COLOR0;
	float3 diffuse : COLOR1;
	float3 lightDirection : TEXCOORD3;
};

PS_Input VS_Main(VS_Input vertex)
{
	PS_Input vsOut = (PS_Input)0;
	vsOut.pos = mul(vertex.pos, worldMatrix);
	vsOut.pos = mul(vsOut.pos, viewMatrix);
	vsOut.pos = mul(vsOut.pos, projMatrix);

	vsOut.tex0 = vertex.tex0;

	vsOut.blendTex = vertex.blendTex;
	vsOut.blendTex2 = vertex.blendTex2;

	vsOut.normal = normalize(mul(vertex.normal, worldMatrix));
	vsOut.tangent = normalize(mul(vertex.tangente, worldMatrix));
	vsOut.binorm = normalize(mul(vertex.binormal, worldMatrix));

	vsOut.ambient = colorAmbiental;
	vsOut.diffuse = colorDifuso;
	vsOut.lightDirection = normalize(direccionLuz);


	return vsOut;
}

float4 PS_Main(PS_Input pix) : SV_TARGET
{
	float4 fColor = float4(1,0,0,1);

	float4 text = colorMap.Sample(colorSampler, pix.tex0);
	float4 normalText = normalMap.Sample(colorSampler, pix.tex0);
	float4 text2 = colorMap2.Sample(colorSampler, pix.tex0);
	float4 normalText2 = normalMap2.Sample(colorSampler, pix.tex0);
	float4 text3 = colorMap3.Sample(colorSampler, pix.tex0);
	float4 normalText3 = normalMap3.Sample(colorSampler, pix.tex0);
	float4 blendTex1 = blendMap.Sample(colorSampler, (pix.blendTex));
	float4 blendTex2 = blendMap2.Sample(colorSampler, (pix.blendTex));


	//Crear multitextura
	float4 textf = (text * blendTex1) + ((1.0 - blendTex1) * text3);
	textf = (textf * blendTex2) + ((1.0 - blendTex2) * text2);
	//Crear multitextura de nromales
	float4 textNormF = (normalText * blendTex1) + ((1.0 - blendTex1) * normalText3);
	textNormF = (textNormF * blendTex2) + ((1.0 - blendTex2) * normalText2);

	//Bump map
	float3 bumpMap = (2.0 * textNormF) - 1.0;	
	float3x3 TBN = { { pix.tangent }, { pix.binorm }, { pix.normal} };
	float3 newNormal = normalize(mul(TBN, bumpMap));


	////////////////////////LUZ AMBIENTAL////////////////////////
	float3 LuzAmbiental = pix.ambient;	//luz ambiental
	float FA = 0.7;									//factor atenuacion ambiental
	float3 AportAmb = saturate(LuzAmbiental * FA);			//aportacion ambiental
	

	////////////////////////LUZ DIFUSA////////////////////////
	//con textura de normales
	float3 DirLuz = pix.lightDirection;						//Direccion de luz
	float3 LuzDifusa = pix.diffuse;				//luz difusa
	float FAD = 0.8;										//factor atenuacion difusa
	//float FALL = saturate(dot(-DirLuz, newNormal));					//factor atenuacion ley de lambert
	float3 FALL = saturate(dot(DirLuz, pix.normal));					//factor atenuacion ley de lambert
	float3 AportDif = saturate(LuzDifusa * FALL * FAD);		//aportacion difusa 0 a 1


	////////////////////////RESULTADO////////////////////////
	float3 Aportaciones = AportAmb + AportDif;
	fColor = float4(textf.rgb * Aportaciones, 1.0f);

	return fColor;
}