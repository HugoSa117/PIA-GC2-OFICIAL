Texture2D colorMap : register(t0);
Texture2D specMap : register(t1);
Texture2D normalMap : register(t2);

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

cbuffer cbChangesOccasionally : register(b4)
{
	float specForce;
};

cbuffer cbLightBuffers : register(b5)
{
	float3 colorAmbiental;
	float3 colorDifuso;
	float3 direccionLuz;
}

struct VS_Input
{
	float4 pos : POSITION;
	float2 tex0 : TEXCOORD0;
	float3 normal : NORMAL0;
};

struct PS_Input
{
	float4 pos : SV_POSITION;
	float2 tex0 : TEXCOORD0;
	float3 normal : TEXCOORD1;
	float3 campos : TEXCOORD2;	//pos vertice
	float specForce : TEXCOORD3;

	float3 ambient : COLOR0;
	float3 diffuse : COLOR1;
	float3 lightDirection : TEXCOORD4;
};

PS_Input VS_Main(VS_Input vertex)
{

	float4 worldPosition;

	PS_Input vsOut = (PS_Input)0;

	vsOut.pos = mul(vertex.pos, worldMatrix);
	vsOut.pos = mul(vsOut.pos, viewMatrix);
	vsOut.pos = mul(vsOut.pos, projMatrix);

	vsOut.tex0 = vertex.tex0;
	vsOut.normal = normalize(mul(vertex.normal, worldMatrix));

	worldPosition = mul(vertex.pos, worldMatrix);

	//posicion camara
	vsOut.campos = cameraPos.xyz - worldPosition.xyz;
	vsOut.campos = normalize(vsOut.campos);

	vsOut.specForce = specForce;

	vsOut.ambient = colorAmbiental;
	vsOut.diffuse = colorDifuso;
	vsOut.lightDirection = normalize(direccionLuz);

	return vsOut;
}

float4 PS_Main(PS_Input pix) : SV_TARGET
{

	float4 color;

	float4 colorText = colorMap.Sample(colorSampler, pix.tex0);
	float4 specularText = specMap.Sample(colorSampler, pix.tex0);
	float4 normalText = normalMap.Sample(colorSampler, pix.tex0);


	//Normales
	float3 bumpMap = (2.0 * normalText) - 1.0;	//de rgb a xyz
	//float3x3 TBN = { { pix.tangent }, { pix.binorm }, { pix.normal} };
	//float3 newNormal = normalize(mul(TBN, bumpMap));


	////////////////////////LUZ AMBIENTAL////////////////////////
	float3 LuzAmbiental = pix.ambient;					//luz ambiental
	float FA = 0.65;										//factor atenuacion ambiental
	float3 AportAmb = saturate(LuzAmbiental * FA);		//aportacion ambiental
	//color = AportAmb;

	////////////////////////LUZ DIFUSA////////////////////////
	float3 DirLuz = normalize(pix.lightDirection);			//Direccion de luz
	float3 LuzDifusa = pix.diffuse;							//luz difusa
	float FAD = 0.9;										//factor atenuacion difusa
	float3 FALL = dot(DirLuz, pix.normal);					//factor atenuacion ley de lambert
	float3 AportDif = saturate(LuzDifusa * FALL * FAD);		//aportacion difusa 0 a 1

	////////////////////////LUZ ESPECULAR////////////////////////
	float3 intensidadR = dot(pix.normal, DirLuz);					//Intensidad de reflejo
	float3 reflejo = normalize(2 * intensidadR * pix.normal - DirLuz);	//vector de reflejo 
	float shininess = 10.0;								//Factor de atenuacion especular 
	float FAS = 1.0;									//Intensidad de especularidad
	float3 vista = normalize(pix.campos - pix.pos);		//vector de vista (posCamara - posVertice)
	//calcular componente especular: 
	float Specular = pow(saturate(dot(reflejo, pix.campos)), shininess) * FAS;
	float3 AportSpec = Specular * specularText;



	////////////////////////RESULTADO////////////////////////
	float3 aportaciones = AportAmb + AportDif + AportSpec;
	color = float4(colorText * aportaciones, 1);
	return color;

}
