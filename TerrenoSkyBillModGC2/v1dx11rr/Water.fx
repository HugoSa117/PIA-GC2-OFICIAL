Texture2D colorMap : register(t0);
Texture2D normalMap : register(t1);
Texture2D specularMap : register(t2);
Texture2D colorMap2 : register(t3);
Texture2D normalMap2 : register(t4);
Texture2D specularMap2 : register(t5);

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

cbuffer cbChangesOccasionally : register(b3)
{
	float3 cameraPos;
};


cbuffer cbLightBuffers : register(b4)
{
	float3 colorAmbiental;
	float3 colorDifuso;
	float3 direccionLuz;
	float3 blendWater;
};



struct VS_Input
{
	float4 pos : POSITION;
	float2 tex0 : TEXCOORD0;

	float3 normal : NORMAL0;
	float3 tangente : NORMAL1;
	float3 binormal : NORMAL2;

};

struct PS_Input
{
	float4 pos : SV_POSITION;
	float2 tex0 : TEXCOORD0;

	float3 normal : NORMAL0;
	float3 tangent : NORMAL1;
	float3 binorm : NORMAL2;

	float3 campos : TEXCOORD1;	

	float3 ambient : COLOR0;
	float3 diffuse : COLOR1;
	float3 lightDirection : TEXCOORD2;

	float3 blend : COLOR2;
	
};

PS_Input VS_Main(VS_Input vertex)
{
	PS_Input vsOut = (PS_Input)0;
	vsOut.pos = mul(vertex.pos, worldMatrix);
	vsOut.pos = mul(vsOut.pos, viewMatrix);
	vsOut.pos = mul(vsOut.pos, projMatrix);

	vsOut.tex0 = vertex.tex0;

	vsOut.normal = normalize(mul(vertex.normal, worldMatrix));
	vsOut.tangent = normalize(mul(vertex.tangente, worldMatrix));
	vsOut.binorm = normalize(mul(vertex.binormal, worldMatrix));

	//posicion camara
	float4 worldPosition;
	worldPosition = mul(vertex.pos, worldMatrix);
	vsOut.campos = cameraPos.xyz - worldPosition.xyz;
	vsOut.campos = normalize(vsOut.campos);

	vsOut.ambient = colorAmbiental;
	vsOut.diffuse = colorDifuso;
	vsOut.lightDirection = normalize(direccionLuz);

	vsOut.blend = blendWater;

	return vsOut;
}


float4 PS_Main(PS_Input pix) : SV_TARGET
{
	float4 fColor = float4(1,1,1,1);

	float4 text = colorMap.Sample(colorSampler, pix.tex0);
	float4 normalText = normalMap.Sample(colorSampler, pix.tex0);
	float4 specularText = specularMap.Sample(colorSampler, pix.tex0);
	float4 text2 = colorMap2.Sample(colorSampler, pix.tex0);
	float4 normalText2 = normalMap2.Sample(colorSampler, pix.tex0);
	float4 specularText2 = specularMap2.Sample(colorSampler, pix.tex0);
	
	float4 colorTextF = lerp(text, text2, pix.blend.x);
	float4 normalTextF = lerp(normalText, normalText2, pix.blend.x);
	float4 specularTextF = lerp(specularText, specularText2, pix.blend.x);


	//Bump map
	float4 bumpMap = (2.0 * normalTextF) - 1.0;
	float3x3 TBN = { { pix.tangent }, { pix.binorm }, { pix.normal} };
	float3 newNormal = normalize(mul(TBN, bumpMap.xyz));

	////////////////////////LUZ AMBIENTAL////////////////////////
	float3 LuzAmbiental = pix.ambient;	//luz ambiental
	float FA = 0.6;									//factor atenuacion ambiental
	float3 AportAmb = saturate(LuzAmbiental * FA);			//aportacion ambiental

	////////////////////////LUZ DIFUSA////////////////////////
	//con textura de normales
	float3 DirLuz = pix.lightDirection;						//Direccion de luz
	float3 LuzDifusa = pix.diffuse;				//luz difusa
	float FAD = 0.8;										//factor atenuacion difusa
	//float FALL = saturate(dot(-DirLuz, newNormal));					//factor atenuacion ley de lambert
	float FALL = saturate(dot(DirLuz, newNormal));					//factor atenuacion ley de lambert
	float3 AportDif = saturate(LuzDifusa * FALL * FAD);		//aportacion difusa 0 a 1


	////////////////////////LUZ ESPECULAR////////////////////////
	float3 intensidadR = dot(pix.normal, -DirLuz);					//Intensidad de reflejo
	float3 reflejo = normalize(2 * intensidadR * pix.normal + DirLuz);	//vector de reflejo 
	float shininess = 30.0;								//Factor de atenuacion especular 
	float FAS = 1.0;									//Intensidad de especularidad
	float3 vista = normalize(pix.campos - pix.pos);		//vector de vista (posCamara - posVertice)
	//calcular componente especular: 
	float Specular = pow(saturate(dot(reflejo, pix.campos)), shininess) * FAS;
	float3 AportSpec = Specular * specularTextF;


	////////////////////////RESULTADO////////////////////////
	float3 Aportaciones = AportAmb + AportDif + AportSpec;
	fColor = float4(colorTextF.rgb * Aportaciones, 1.0f);
	return fColor;
}