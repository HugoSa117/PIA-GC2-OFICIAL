#ifndef _dxrr
#define _dxrr
#include <d3d11.h>
#include <d3dx11.h>
#include <d3dx10.h>
#include <d3dx10math.h>
#include "TerrenoRR.h"
#include "Camara.h"
#include "SkyDome.h"
#include "Billboard.h"
#include "ModeloRR.h"
#include "XACT3Util.h"

class DXRR{	

private:
	int ancho;
	int alto;
	int prueba2;
	int prueba;	//Variable de prueba commit

public:	
	HINSTANCE hInstance;
	HWND hWnd;

	D3D_DRIVER_TYPE driverType;
	D3D_FEATURE_LEVEL featureLevel;

	ID3D11Device* d3dDevice;
	ID3D11DeviceContext* d3dContext;
	IDXGISwapChain* swapChain;
	ID3D11RenderTargetView* backBufferTarget;

	ID3D11Texture2D* depthTexture;
	ID3D11DepthStencilView* depthStencilView;

	ID3D11DepthStencilState* depthStencilState;
	ID3D11DepthStencilState* depthStencilDisabledState;

	ID3D11BlendState *alphaBlendState, *commonBlendState;

	int frameBillboard;

	TerrenoRR *terreno;
	SkyDome *skydome;
	BillboardRR *billboard;
	//Billboards
	BillboardRR* arbol01;
	BillboardRR* arbol02;
	BillboardRR* arbol03;
	BillboardRR* arbol04;


	Camara *camara;
	ModeloRR* model;

	//Nuevos modelos
	ModeloRR* banca01;
	ModeloRR* cabaña01;
	ModeloRR* techoCabaña01;
	ModeloRR* cabaña02;
	ModeloRR* cabaña03;
	ModeloRR* troncos01;
	ModeloRR* camioneta01;
	
	float izqder;
	float arriaba;
	float vel;
	float vel2;

	bool breakpoint;
	vector2 uv1[32];
	vector2 uv2[32];
	vector2 uv3[32];
	vector2 uv4[32];

	XACTINDEX cueIndex;
	CXACT3Util m_XACT3;
	
    DXRR(HWND hWnd, int Ancho, int Alto)
	{
		breakpoint = false;
		frameBillboard = 0;
		ancho = Ancho;
		alto = Alto;
		driverType = D3D_DRIVER_TYPE_NULL;
		featureLevel = D3D_FEATURE_LEVEL_11_0;
		d3dDevice = 0;
		d3dContext = 0;
		swapChain = 0;
		backBufferTarget = 0;
		IniciaD3D(hWnd);
		izqder = 0;
		arriaba = 0;
		billCargaFuego();
		camara = new Camara(D3DXVECTOR3(0,80,6), D3DXVECTOR3(0,80,0), D3DXVECTOR3(0,1,0), Ancho, Alto);
		terreno = new TerrenoRR(300, 300, d3dDevice, d3dContext);
		skydome = new SkyDome(40, 40, 200.0f, &d3dDevice, &d3dContext, L"skydome1.png", L"skydome2.jpg");
		billboard = new BillboardRR(L"Assets/Billboards/fuego-anim.png",L"Assets/Billboards/fuego-anim-normal.png", d3dDevice, d3dContext, 5);
		model = new ModeloRR(d3dDevice, d3dContext, "Assets/Cofre/Cofre.obj", L"Assets/Cofre/Cofre-color.png", L"Assets/Cofre/Cofre-spec.png", 0, 0);

		//Billboards
		arbol01 = new BillboardRR(L"Assets/Billboards/tree01_colorMap.png", L"Assets/Billboards/tree01_normalMap.png", d3dDevice, d3dContext, 10);
		arbol02 = new BillboardRR(L"Assets/Billboards/tree02_colorMap.png", L"Assets/Billboards/tree02_normalMap.png", d3dDevice, d3dContext, 10);
		arbol03 = new BillboardRR(L"Assets/Billboards/tree03_colorMap.png", L"Assets/Billboards/tree03_normalMap.png", d3dDevice, d3dContext, 10);
		arbol04 = new BillboardRR(L"Assets/Billboards/tree04_colorMap.png", L"Assets/Billboards/tree04_normalMap.png", d3dDevice, d3dContext, 10);

		//Nuevos modelos
		banca01 = new ModeloRR(d3dDevice, d3dContext, "Assets/Banca01/banca01.obj", L"Assets/Banca01/color_banca01.png", L"Assets/Banca01/specular_banca01.png", 40, 0);
		cabaña01 = new ModeloRR(d3dDevice, d3dContext, "Assets/Cabaña01/cabaña01.obj", L"Assets/Cabaña01/color_cabaña01.jpg", L"Assets/Cabaña01/specular_cabaña01.jpg", 75, 0);
		techoCabaña01 = new ModeloRR(d3dDevice, d3dContext, "Assets/Cabaña01/techoCabaña01.obj", L"Assets/Cabaña01/color_techoCabaña01.jpg", L"Assets/Cabaña01/specular_techoCabaña1.jpg", 75, 0);
		cabaña02 = new ModeloRR(d3dDevice, d3dContext, "Assets/Cabaña02/cabaña02.obj", L"Assets/Cabaña02/color_cabaña02.jpg", L"Assets/Cabaña02/specular_cabaña02.jpg", 50, 0);
		cabaña03 = new ModeloRR(d3dDevice, d3dContext, "Assets/Cabaña03/cabaña03.obj", L"Assets/Cabaña03/color_cabaña03.png", L"Assets/Cabaña03/specular_cabaña03.png", 25, 0);
		troncos01 = new ModeloRR(d3dDevice, d3dContext, "Assets/Tronco/Troncos.obj", L"Assets/Tronco/color_tronco.png", L"Assets/Tronco/specular_tronco.jpg", -25, 0);
		camioneta01 = new ModeloRR(d3dDevice, d3dContext, "Assets/Camioneta01/camioneta01.obj", L"Assets/Camioneta01/color_camioneta01.jpg", L"Assets/Camioneta01/specular_camioneta01.png", -5, 0);
		

		
	}

	~DXRR()
	{
		LiberaD3D();
		m_XACT3.Terminate();
	}
	
	bool IniciaD3D(HWND hWnd)
	{
		this->hInstance = hInstance;
		this->hWnd = hWnd;

		//obtiene el ancho y alto de la ventana donde se dibuja
		RECT dimensions;
		GetClientRect(hWnd, &dimensions);
		unsigned int width = dimensions.right - dimensions.left;
		unsigned int heigth = dimensions.bottom - dimensions.top;

		//Las formas en como la pc puede ejecutar el DX11, la mas rapida es D3D_DRIVER_TYPE_HARDWARE pero solo se puede usar cuando lo soporte el hardware
		//otra opcion es D3D_DRIVER_TYPE_WARP que emula el DX11 en los equipos que no lo soportan
		//la opcion menos recomendada es D3D_DRIVER_TYPE_SOFTWARE, es la mas lenta y solo es util cuando se libera una version de DX que no sea soportada por hardware
		D3D_DRIVER_TYPE driverTypes[]=
		{
			D3D_DRIVER_TYPE_HARDWARE, D3D_DRIVER_TYPE_WARP, D3D_DRIVER_TYPE_SOFTWARE
		};
		unsigned int totalDriverTypes = ARRAYSIZE(driverTypes);

		//La version de DX que utilizara, en este caso el DX11
		D3D_FEATURE_LEVEL featureLevels[]=
		{
			D3D_FEATURE_LEVEL_11_0, D3D_FEATURE_LEVEL_10_1, D3D_FEATURE_LEVEL_10_0
		};
		unsigned int totalFeaturesLevels = ARRAYSIZE(featureLevels);

		DXGI_SWAP_CHAIN_DESC swapChainDesc;
		ZeroMemory(&swapChainDesc, sizeof(swapChainDesc));
		swapChainDesc.BufferCount = 1;
		swapChainDesc.BufferDesc.Width = width;
		swapChainDesc.BufferDesc.Height = heigth;
		swapChainDesc.BufferDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM;
		swapChainDesc.BufferDesc.RefreshRate.Numerator = 60;
		swapChainDesc.BufferDesc.RefreshRate.Denominator = 1;
		swapChainDesc.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT;
		swapChainDesc.OutputWindow = hWnd;
		swapChainDesc.Windowed = true;
		swapChainDesc.SampleDesc.Count = 1;
		swapChainDesc.SampleDesc.Quality = 0;

		HRESULT result;
		unsigned int driver = 0, creationFlags = 0;
		for(driver = 0; driver<totalDriverTypes; driver++)
		{
			result = D3D11CreateDeviceAndSwapChain(0, driverTypes[driver], 0,
				creationFlags, featureLevels, totalFeaturesLevels, 
				D3D11_SDK_VERSION, &swapChainDesc, &swapChain,
				&d3dDevice, &featureLevel, &d3dContext);

			if(SUCCEEDED(result))
			{
				driverType = driverTypes[driver];
				break;
			}
		}

		if(FAILED(result))
		{

			//Error al crear el Direct3D device
			return false;
		}
		
		ID3D11Texture2D* backBufferTexture;
		result = swapChain->GetBuffer(0, __uuidof(ID3D11Texture2D), (LPVOID*)&backBufferTexture);
		if(FAILED(result))
		{
			//"Error al crear el swapChainBuffer
			return false;
		}

		result = d3dDevice->CreateRenderTargetView(backBufferTexture, 0, &backBufferTarget);
		if(backBufferTexture)
			backBufferTexture->Release();

		if(FAILED(result))
		{
			//Error al crear el renderTargetView
			return false;
		}


		D3D11_VIEWPORT viewport;
		viewport.Width = (FLOAT)width;
		viewport.Height = (FLOAT)heigth;
		viewport.MinDepth = 0.0f;
		viewport.MaxDepth = 1.0f;
		viewport.TopLeftX = 0.0f;
		viewport.TopLeftY = 0.0f;

		d3dContext->RSSetViewports(1, &viewport);

		D3D11_TEXTURE2D_DESC depthTexDesc;
		ZeroMemory(&depthTexDesc, sizeof(depthTexDesc));
		depthTexDesc.Width = width;
		depthTexDesc.Height = heigth;
		depthTexDesc.MipLevels = 1;
		depthTexDesc.ArraySize = 1;
		depthTexDesc.Format = DXGI_FORMAT_D24_UNORM_S8_UINT;
		depthTexDesc.SampleDesc.Count = 1;
		depthTexDesc.SampleDesc.Quality = 0;
		depthTexDesc.Usage = D3D11_USAGE_DEFAULT;
		depthTexDesc.BindFlags = D3D11_BIND_DEPTH_STENCIL;
		depthTexDesc.CPUAccessFlags = 0;
		depthTexDesc.MiscFlags = 0;
		
		result = d3dDevice->CreateTexture2D(&depthTexDesc, NULL, &depthTexture);
		if(FAILED(result))
		{
			MessageBox(0, L"Error", L"Error al crear la DepthTexture", MB_OK);
			return false;
		}

		D3D11_DEPTH_STENCIL_VIEW_DESC descDSV;
		ZeroMemory(&descDSV, sizeof(descDSV));
		descDSV.Format = depthTexDesc.Format;
		descDSV.ViewDimension = D3D11_DSV_DIMENSION_TEXTURE2D;
		descDSV.Texture2D.MipSlice = 0;

		result = d3dDevice->CreateDepthStencilView(depthTexture, &descDSV, &depthStencilView);
		if(FAILED(result))
		{
			MessageBox(0, L"Error", L"Error al crear el depth stencil target view", MB_OK);
			return false;
		}

		d3dContext->OMSetRenderTargets(1, &backBufferTarget, depthStencilView);

		return true;			
		
	}

	void LiberaD3D(void)
	{
		if(depthTexture)
			depthTexture->Release();
		if(depthStencilView)
			depthStencilView->Release();
		if(backBufferTarget)
			backBufferTarget->Release();
		if(swapChain)
			swapChain->Release();
		if(d3dContext)
			d3dContext->Release();
		if(d3dDevice)
			d3dDevice->Release();

		depthTexture = 0;
		depthStencilView = 0;
		d3dDevice = 0;
		d3dContext = 0;
		swapChain = 0;
		backBufferTarget = 0;
	}
	
	void Render(void)
	{
		static float velocidad = 0.0005;				//Velocidad de ciclo

		D3DXCOLOR colorDia = D3DXCOLOR(255, 255, 255, 1);
		D3DXCOLOR colorTarde = D3DXCOLOR(234, 189, 137, 1);
		D3DXCOLOR colorNoche = D3DXCOLOR(60, 138, 207, 1);

		D3DXCOLOR colorAmbiental;
		D3DXCOLOR colorDifuso = D3DXCOLOR(255 /255, 255 /255, 255 /255, 1);

		///////////////////////ROTACION DE SOL///////////////////////
		static float factorRotacion = 0.0;
		factorRotacion += velocidad;
		if (factorRotacion > 1.0) {
			factorRotacion = 0.0;
		}

		float anguloRotacion = 360 * factorRotacion;

		D3DXVECTOR4 luz(0, 10000, 0, 1);			//posicion inicial de luz
		//Crear matriz de rotacion para el sol
		D3DXMATRIX rotacionSol;
		D3DXMatrixRotationZ(&rotacionSol, anguloRotacion * 0.0174533);
		//Obtener vector de luz rotado
		D3DXVECTOR4 SOL;							//Guarda vector de sol rotado y trasladado
		D3DXVec4Transform(&SOL, &luz, &rotacionSol);	
		D3DXVECTOR3 solecito = D3DXVECTOR3(SOL);


		///////////////////////CALCULO DE LUCES///////////////////////

		float blend = 0;		//de 0 a 1 (cuando su maximo es 0.25)
		if (factorRotacion <= 0.25) {
			blend = factorRotacion * 4;	
			D3DXColorLerp(&colorAmbiental, &colorDia, &colorTarde, blend);
		}
		else if (factorRotacion <= 0.5 && factorRotacion > 0.25) {
			blend = (factorRotacion - 0.25) * 4;
			D3DXColorLerp(&colorAmbiental, &colorTarde, &colorNoche, blend);
		}
		else if (factorRotacion <= 0.75 && factorRotacion > 0.5) {
			blend = (factorRotacion - 0.5) * 4;
			D3DXColorLerp(&colorAmbiental, &colorNoche, &colorTarde, blend);
		}
		else if (factorRotacion > 0.75) {
			blend = (factorRotacion - 0.75) * 4;
			D3DXColorLerp(&colorAmbiental, &colorTarde, &colorDia, blend);
		}

		//Crear vectores de luz resultantes
		D3DXVECTOR4 AMBIENTAL = D3DXVECTOR4(D3DXVECTOR3(
			colorAmbiental.r / 255, 
			colorAmbiental.g / 255, 
			colorAmbiental.b / 255), 
			1
		);

		D3DXVECTOR4 DIFUSO = D3DXVECTOR4(D3DXVECTOR3(colorDifuso), 1);


		/////////////////////////ACTUALIZAR BLEND DE SKYDOME///////////////
		static bool dia = true;	//true: di a noche, false: noche a dia
		static float blendSky = 0.0;
		if (dia) {
			blendSky += velocidad * 2;
		}
		else {
			blendSky -= velocidad * 2;
		}

		if (factorRotacion >= 0.5) {
			dia = false;
		}
		else {
			dia = true;
		}

		float sphere[3] = { 0,0,0 };
		float prevPos[3] = { camara->posCam.x, camara->posCam.z, camara->posCam.z };
		static float angle = 0.0f;
		angle += 0.001;
		if (angle >= 360) angle = 0.0f;
		bool collide = false;
		if( d3dContext == 0 )
			return;

		float clearColor[4] = { 0, 0, 0, 1.0f };
		d3dContext->ClearRenderTargetView( backBufferTarget, clearColor );
		d3dContext->ClearDepthStencilView( depthStencilView, D3D11_CLEAR_DEPTH, 1.0f, 0 );
		camara->posCam.y = terreno->Superficie(camara->posCam.x, camara->posCam.z) + 5 ;
		camara->UpdateCam(vel2, vel, arriaba, izqder);
		skydome->Update(camara->vista, camara->proyeccion);

		float camPosXZ[2] = { camara->posCam.x, camara->posCam.z };

		TurnOffDepth();
		skydome->Render(camara->posCam, angle, AMBIENTAL, blendSky);
		TurnOnDepth();
		terreno->Draw(camara->vista, camara->proyeccion, AMBIENTAL, DIFUSO, SOL);
		//TurnOnAlphaBlending();
		/*billboard->Draw(camara->vista, camara->proyeccion, camara->posCam,
			-11, -78, 4, 5, uv1, uv2, uv3, uv4, frameBillboard);*/

		arbol01->DrawBill(camara->vista, camara->proyeccion, camara->posCam,
			-11, -78, terreno->Superficie(-11, -78), 5, AMBIENTAL, DIFUSO, SOL);

		arbol02->DrawBill(camara->vista, camara->proyeccion, camara->posCam,
			-22, -78, terreno->Superficie(-22, -78), 5, AMBIENTAL, DIFUSO, SOL);

		arbol03->DrawBill(camara->vista, camara->proyeccion, camara->posCam,
			-33, -78, terreno->Superficie(-33, -78), 5, AMBIENTAL, DIFUSO, SOL);

		arbol04->DrawBill(camara->vista, camara->proyeccion, camara->posCam,
			11, -78, terreno->Superficie(11, -78), 8, AMBIENTAL, DIFUSO, SOL);


		//TurnOffAlphaBlending();
		//model->Draw(camara->vista, camara->proyeccion, terreno->Superficie(100, 20), camara->posCam, 10.0f, 0, 'A', 1);

		//Nuevos modelos

		/*banca01->Draw(camara->vista, camara->proyeccion, terreno->Superficie(40, 20) , camara->posCam, 10.0f, 0, 'A', 1);
		cabaña01->Draw(camara->vista, camara->proyeccion, terreno->Superficie(75, 20) , camara->posCam, 10.0f, 0, 'A', 1);
		techoCabaña01->Draw(camara->vista, camara->proyeccion, terreno->Superficie(75, 20) , camara->posCam, 10.0f, 0, 'A', 1);
		cabaña02->Draw(camara->vista, camara->proyeccion, terreno->Superficie(50, 20) , camara->posCam, 10.0f, 0, 'A', 1);
		cabaña03->Draw(camara->vista, camara->proyeccion, terreno->Superficie(20, 0) , camara->posCam, 10.0f, 0, 'Y', 1);
	    troncos01->Draw(camara->vista, camara->proyeccion, terreno->Superficie(-25, 0), camara->posCam, 10.0f, 0, 'A', 1);
		camioneta01->Draw(camara->vista, camara->proyeccion, terreno->Superficie(40, 0), camara->posCam, 10.0f, 0, 'A', 1);*/

		swapChain->Present( 1, 0 );
	}

	bool isPointInsideSphere(float* point, float* sphere) {
		bool collition = false;

		float distance = sqrt((point[0] - sphere[0]) * (point[0] - sphere[0]) +
			(point[1] - sphere[1]) * (point[1] - sphere[1]));

		if (distance < sphere[2])
			collition = true;
		return collition;
	}

	//Activa el alpha blend para dibujar con transparencias
	void TurnOnAlphaBlending()
	{
		float blendFactor[4];
		blendFactor[0] = 0.0f;
		blendFactor[1] = 0.0f;
		blendFactor[2] = 0.0f;
		blendFactor[3] = 0.0f;
		HRESULT result;

		D3D11_BLEND_DESC descABSD;
		ZeroMemory(&descABSD, sizeof(D3D11_BLEND_DESC));
		descABSD.RenderTarget[0].BlendEnable = TRUE;
		descABSD.RenderTarget[0].SrcBlend = D3D11_BLEND_ONE;
		descABSD.RenderTarget[0].DestBlend = D3D11_BLEND_INV_SRC_ALPHA;
		descABSD.RenderTarget[0].BlendOp = D3D11_BLEND_OP_ADD;
		descABSD.RenderTarget[0].SrcBlendAlpha = D3D11_BLEND_ONE;
		descABSD.RenderTarget[0].DestBlendAlpha = D3D11_BLEND_ZERO;
		descABSD.RenderTarget[0].BlendOpAlpha = D3D11_BLEND_OP_ADD;
		descABSD.RenderTarget[0].RenderTargetWriteMask = 0x0f;

		result = d3dDevice->CreateBlendState(&descABSD, &alphaBlendState);
		if(FAILED(result))
		{
			MessageBox(0, L"Error", L"Error al crear el blend state", MB_OK);
			return;
		}

		d3dContext->OMSetBlendState(alphaBlendState, blendFactor, 0xffffffff);
	}

	//Regresa al blend normal(solido)
	void TurnOffAlphaBlending()
	{
		D3D11_BLEND_DESC descCBSD;
		ZeroMemory(&descCBSD, sizeof(D3D11_BLEND_DESC));
		descCBSD.RenderTarget[0].BlendEnable = FALSE;
		descCBSD.RenderTarget[0].SrcBlend = D3D11_BLEND_ONE;
		descCBSD.RenderTarget[0].DestBlend = D3D11_BLEND_INV_SRC_ALPHA;
		descCBSD.RenderTarget[0].BlendOp = D3D11_BLEND_OP_ADD;
		descCBSD.RenderTarget[0].SrcBlendAlpha = D3D11_BLEND_ONE;
		descCBSD.RenderTarget[0].DestBlendAlpha = D3D11_BLEND_ZERO;
		descCBSD.RenderTarget[0].BlendOpAlpha = D3D11_BLEND_OP_ADD;
		descCBSD.RenderTarget[0].RenderTargetWriteMask = 0x0f;
		HRESULT result;

		result = d3dDevice->CreateBlendState(&descCBSD, &commonBlendState);
		if(FAILED(result))
		{
			MessageBox(0, L"Error", L"Error al crear el blend state", MB_OK);
			return;
		}

		d3dContext->OMSetBlendState(commonBlendState, NULL, 0xffffffff);
	}

	void TurnOnDepth()
	{
		D3D11_DEPTH_STENCIL_DESC descDSD;
		ZeroMemory(&descDSD, sizeof(descDSD));
		descDSD.DepthEnable = true;
		descDSD.DepthWriteMask = D3D11_DEPTH_WRITE_MASK_ALL;
		descDSD.DepthFunc = D3D11_COMPARISON_LESS;
		descDSD.StencilEnable=true;
		descDSD.StencilReadMask = 0xFF;
		descDSD.StencilWriteMask = 0xFF;
		descDSD.FrontFace.StencilFailOp = D3D11_STENCIL_OP_KEEP;
		descDSD.FrontFace.StencilDepthFailOp = D3D11_STENCIL_OP_INCR;
		descDSD.FrontFace.StencilPassOp = D3D11_STENCIL_OP_KEEP;
		descDSD.FrontFace.StencilFunc = D3D11_COMPARISON_ALWAYS;
		descDSD.BackFace.StencilFailOp = D3D11_STENCIL_OP_KEEP;
		descDSD.BackFace.StencilDepthFailOp = D3D11_STENCIL_OP_DECR;
		descDSD.BackFace.StencilPassOp = D3D11_STENCIL_OP_KEEP;
		descDSD.BackFace.StencilFunc = D3D11_COMPARISON_ALWAYS;

		d3dDevice->CreateDepthStencilState(&descDSD, &depthStencilState);
		
		d3dContext->OMSetDepthStencilState(depthStencilState, 1);
	}

	void TurnOffDepth()
	{
		D3D11_DEPTH_STENCIL_DESC descDDSD;
		ZeroMemory(&descDDSD, sizeof(descDDSD));
		descDDSD.DepthEnable = false;
		descDDSD.DepthWriteMask = D3D11_DEPTH_WRITE_MASK_ALL;
		descDDSD.DepthFunc = D3D11_COMPARISON_LESS;
		descDDSD.StencilEnable=true;
		descDDSD.StencilReadMask = 0xFF;
		descDDSD.StencilWriteMask = 0xFF;
		descDDSD.FrontFace.StencilFailOp = D3D11_STENCIL_OP_KEEP;
		descDDSD.FrontFace.StencilDepthFailOp = D3D11_STENCIL_OP_INCR;
		descDDSD.FrontFace.StencilPassOp = D3D11_STENCIL_OP_KEEP;
		descDDSD.FrontFace.StencilFunc = D3D11_COMPARISON_ALWAYS;
		descDDSD.BackFace.StencilFailOp = D3D11_STENCIL_OP_KEEP;
		descDDSD.BackFace.StencilDepthFailOp = D3D11_STENCIL_OP_DECR;
		descDDSD.BackFace.StencilPassOp = D3D11_STENCIL_OP_KEEP;
		descDDSD.BackFace.StencilFunc = D3D11_COMPARISON_ALWAYS;

		d3dDevice->CreateDepthStencilState(&descDDSD, &depthStencilDisabledState);
		d3dContext->OMSetDepthStencilState(depthStencilDisabledState, 1);
	}

	void billCargaFuego()
	{
		uv1[0].u = .125;
		uv2[0].u = .125;
		uv3[0].u = 0;
		uv4[0].u = 0;

		uv1[0].v = .25;
		uv2[0].v = 0;
		uv3[0].v = 0;
		uv4[0].v = .25;


		for (int j = 0; j < 8; j++) {
			uv1[j].u = uv1[0].u + (j * .125);
			uv2[j].u = uv2[0].u + (j * .125);
			uv3[j].u = uv3[0].u + (j * .125);
			uv4[j].u = uv4[0].u + (j * .125);

			uv1[j].v = .25;
			uv2[j].v = 0;
			uv3[j].v = 0;
			uv4[j].v = .25;
		}
		for (int j = 0; j < 8; j++) {
			uv1[j + 8].u = uv1[0].u + (j * .125);
			uv2[j + 8].u = uv2[0].u + (j * .125);
			uv3[j + 8].u = uv3[0].u + (j * .125);
			uv4[j + 8].u = uv4[0].u + (j * .125);

			uv1[j + 8].v = .5;
			uv2[j + 8].v = .25;
			uv3[j + 8].v = .25;
			uv4[j + 8].v = .5;
		}

		for (int j = 0; j < 8; j++) {
			uv1[j + 16].u = uv1[0].u + (j * .125);
			uv2[j + 16].u = uv2[0].u + (j * .125);
			uv3[j + 16].u = uv3[0].u + (j * .125);
			uv4[j + 16].u = uv4[0].u + (j * .125);

			uv1[j + 16].v = .75;
			uv2[j + 16].v = .5;
			uv3[j + 16].v = .5;
			uv4[j + 16].v = .75;
		}

		for (int j = 0; j < 8; j++) {
			uv1[j + 24].u = uv1[0].u + (j * .125);
			uv2[j + 24].u = uv2[0].u + (j * .125);
			uv3[j + 24].u = uv3[0].u + (j * .125);
			uv4[j + 24].u = uv4[0].u + (j * .125);

			uv1[j + 24].v = 1;
			uv2[j + 24].v = .75;
			uv3[j + 24].v = .75;
			uv4[j + 24].v = 1;
		}
	}

};
#endif