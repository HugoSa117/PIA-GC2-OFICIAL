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
};

PS_Input VS_Main(VS_Input vertex)
{
	PS_Input vsOut = (PS_Input)0;
	vsOut.pos = mul(vertex.pos, worldMatrix);
	vsOut.pos = mul(vsOut.pos, viewMatrix);
	vsOut.pos = mul(vsOut.pos, projMatrix);

	vsOut.tex0 = vertex.tex0;

	/*
	vsOut.normaltex0 = vertex.normaltex0;
	vsOut.tex2 = vertex.tex2;
	vsOut.normaltex2 = vertex.normaltex2;
	*/
	vsOut.blendTex = vertex.blendTex;
	vsOut.blendTex2 = vertex.blendTex2;

	vsOut.normal = normalize(mul(vertex.normal, worldMatrix));
	vsOut.tangent = normalize(mul(vertex.tangente, worldMatrix));
	vsOut.binorm = normalize(mul(vertex.binormal, worldMatrix));

	return vsOut;
}

float4 PS_Main(PS_Input pix) : SV_TARGET
{
	float4 fColor = float4(1,0,0,1);

	float3 ambient = float3(1.0f, 1.0f, 1.0f);

	float4 text = colorMap.Sample(colorSampler, pix.tex0);
	float4 normalText = normalMap.Sample(colorSampler, pix.tex0);
	float4 text2 = colorMap2.Sample(colorSampler, pix.tex0);
	float4 normalText2 = normalMap2.Sample(colorSampler, pix.tex0);
	float4 text3 = colorMap3.Sample(colorSampler, pix.tex0);
	float4 normalText3 = normalMap3.Sample(colorSampler, pix.tex0);
	float4 blendTex1 = blendMap.Sample(colorSampler, (pix.blendTex));
	float4 blendTex2 = blendMap2.Sample(colorSampler, (pix.blendTex));


	//float4 textf = lerp(text2, text, 0.5)

	//Crear multitextura
	float4 textf = (text * blendTex1) + ((1.0 - blendTex1) * text3);
	textf = (textf * blendTex2) + ((1.0 - blendTex2) * text2);
	//Crear multitextura de nromales
	float4 textNormF = (normalText * blendTex1) + ((1.0 - blendTex1) * normalText3);
	textNormF = (textNormF * blendTex2) + ((1.0 - blendTex2) * normalText2);

	//Crear matriz de normales
	float4 bumpMap = (2.0 * textNormF) - 1.0;
	float3 bumpNorm = (bumpMap.x * pix.tangent) + (bumpMap.y * pix.binorm) + (bumpMap.z * pix.normal);
	bumpNorm = normalize(bumpNorm);

	/*
	float3 bump = (2.0 * textNormF) - 1.0;
	float3x3 TBN = { {pix.tangent}, {pix.binorm}, {pix.normal} };
	float3 newnormal = mul(TBN, bump);
	newnormal = normalize(newnormal);
	*/
	
	float3 DiffuseDirection = float3(0.0f, -1.0f, 0.0f);
	float4 DiffuseColor = float4(1.0f, 1.0f, 1.0f, 1.0f);

	//float3 diffuse = dot(-DiffuseDirection, pix.normal);
	float3 diffuse = dot(-DiffuseDirection, bumpNorm);
	diffuse = saturate(diffuse * DiffuseColor.rgb);
	diffuse = saturate(diffuse + ambient);

	fColor = float4(textf.rgb * diffuse, 1.0f);

	return fColor;
}