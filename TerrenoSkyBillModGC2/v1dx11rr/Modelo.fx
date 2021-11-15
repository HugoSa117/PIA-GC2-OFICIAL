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
	float3 campos : TEXCOORD2;
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

	//
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
	float3 lightDir;
	float3 reflection;
	float4 specularMap;
	float4 finalSpec;
	float4 color;

	float4 colorText = colorMap.Sample(colorSampler, pix.tex0);
	float4 specularText = specMap.Sample(colorSampler, pix.tex0);
	float4 normalText = normalMap.Sample(colorSampler, pix.tex0);


	//Normales
	//float3 bumpMap = (2.0 * normalText) - 1.0;	//de rgb a xyz
	//float3x3 TBN = { { pix.tangent }, { pix.binorm }, { pix.normal} };
	//float3 newNormal = mul(TBN, bumpMap);
	//newNormal = normalize(newNormal);

	float3 Normal = normalize(pix.normal);
	//Normal = mul(bumpMap, Normal);
	//Normal = normalize(Normal);

	////////////////////////LUZ AMBIENTAL////////////////////////
	float4 LuzAmbiental = float4(pix.ambient, 1);	//luz ambiental
	float FA = 0.8;									//factor atenuacion ambiental
	float4 AportAmb = LuzAmbiental * FA;			//aportacion ambiental
	color = AportAmb;

	////////////////////////LUZ DIFUSA////////////////////////
	float3 DirLuz = normalize(pix.lightDirection);			//Direccion de luz
	float4 LuzDifusa = float4(pix.diffuse, 1);				//luz difusa
	float FAD = 1.0;										//factor atenuacion difusa
	float FALL = dot(-DirLuz, Normal);					//factor atenuacion ley de lambert
	float4 AportDif = saturate(LuzDifusa * FALL * FAD);		//aportacion difusa 0 a 1

	////////////////////////LUZ ESPECULAR////////////////////////
	float4 specular = float4(1.0, 1.0, 1.0, 1.0);	//color especular
	float shininess = pix.specForce;				//Factor de atenuacion especular
	float4 AportSpec;
	float lightIntensity = saturate(dot(pix.normal, -DirLuz));	//Intensidad de reflejo en pixel
	float3 reflejo;
	float3 vista = pix.campos;	//vector de vista (direccionCamara - posVertice)

	//Si la intensidad de reflejo del pixel es mayor a 0
	if (lightIntensity > 0) {
		//calcular el color difuso en base a laintensidad de reflejo
		color += (AportDif * lightIntensity);
		color = saturate(color);

		//calcular vector de reflejo
		reflejo = normalize(2 * lightIntensity * pix.normal - DirLuz);

		AportSpec = pow(saturate(dot(reflejo, vista)), shininess);
		AportSpec = AportSpec * specularText;
	}

	color = color * (AportAmb + AportDif);



	//Resultado
	color = colorText * colorText;
	color = saturate(color + AportSpec);

	return color;


	specular = float4(0.0, 0.0, 0.0, 1.0); //specular color
	specularMap = specMap.Sample(colorSampler, pix.tex0);

	lightDir = -(float3(0.5f, -1.0f, 0.0f)); // lightDirection

	lightIntensity = saturate(dot(pix.normal, lightDir));

	if (lightIntensity > 0) {
		// Determine the final diffuse color based on the diffuse color and the amount of light intensity.
		color += (float4(1.0f, 1.f, 1.f, 1.0f)/*diffuse color*/ * lightIntensity);

		// Saturate the ambient and diffuse color.
		color = saturate(color);

		// Calculate the reflection vector based on the light intensity, normal vector, and light direction.
		reflection = normalize(2 * lightIntensity * pix.normal - lightDir);

		// Determine the amount of specular light based on the reflection vector, viewing direction, and specular power.
		specular = pow(saturate(dot(reflection, pix.campos)), pix.specForce);
		finalSpec = specular * specularMap;
	}

	color = LuzAmbiental * colorText;

	color = saturate(color + finalSpec);

	return color;
}


/*

float4 PS_Main(PS_Input pix) : SV_TARGET
{
	float4 textureColor;
	float3 lightDir;
	float lightIntensity;
	float4 color;
	float3 reflection;
	float4 specular;
	float4 specularMap;
	float4 finalSpec;

	textureColor = colorMap.Sample(colorSampler, pix.tex0);
	color = float4(pix.ambient, 1);// ambient color

	specular = float4(0.0, 0.0, 0.0, 1.0); //specular color
	specularMap = specMap.Sample(colorSampler, pix.tex0);

	lightDir = -(float3(0.5f, -1.0f, 0.0f)); // lightDirection

	lightIntensity = saturate(dot(pix.normal, lightDir));

	if (lightIntensity > 0) {
		// Determine the final diffuse color based on the diffuse color and the amount of light intensity.
		color += (float4(1.0f, 1.f, 1.f, 1.0f) lightIntensity);//diffuse color

		// Saturate the ambient and diffuse color.
		color = saturate(color);

		// Calculate the reflection vector based on the light intensity, normal vector, and light direction.
		reflection = normalize(2 * lightIntensity * pix.normal - lightDir);

		// Determine the amount of specular light based on the reflection vector, viewing direction, and specular power.
		specular = pow(saturate(dot(reflection, pix.campos)), pix.specForce);
		finalSpec = specular * specularMap;
	}

	color = color * textureColor;

	color = saturate(color + finalSpec);

	return color;
}
*/