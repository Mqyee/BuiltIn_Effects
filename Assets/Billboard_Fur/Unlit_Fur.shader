﻿// Unlit shader. Simplest possible textured shader.
// - no lighting
// - no lightmap support
// - no per-material color

Shader "Unlit/Fur" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_NoiseTex("Noise", 2D) = "white" {}
		_UVoffset("UV偏移：XY=UV偏移;ZW=UV扰动", Vector) = (0, 0, 0.2, 0.2)

		_FurLength("Fur Length", Range(.0002, 1)) = .25
		_Cutoff("Alpha Cutoff", Range(0,1)) = 0.5 // how "thick"
		_CutoffEnd("Alpha Cutoff end", Range(0,1)) = 0.5 // how thick they are at the end
		_EdgeFade("Edge Fade", Range(0,1)) = 0.4

		_Gravity("Gravity Direction", Vector) = (0,-1,0,0)
		_GravityStrength("Gravity Strength", Range(0,1)) = 0.25
		_AOColor("AOCol",Color) = (0.5,0.5,0.5,1.0)
		_BaseColor("_BaseColor",Color) = (1,1,1,1.0)
		_EdgeColor("_EdgeColor",Color) = (1,1,1,1.0)
		_AOIntensity("_AOIntensity", Range(0,1)) = 0.4
	}

	SubShader {
			Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
			//Tags { "RenderType"="Opaque" "Queue" = "AlphaTest " }

		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite On 
		CGINCLUDE
		#include "UnityCG.cginc"

		struct appdata_t {
			float4 vertex : POSITION;
			float2 texcoord : TEXCOORD0;
			half3 normal	: NORMAL;
			fixed4 color : COLOR;
		};

		struct v2f {
			float4 vertex : SV_POSITION;
			fixed4 color : COLOR;
			half2 texcoord : TEXCOORD0;
			UNITY_FOG_COORDS(1)
			half4 posWorld : TEXCOORD2;
			half3 normalDir : TEXCOORD3;
		};

		sampler2D _MainTex;
		float4 _MainTex_ST;

		sampler2D _NoiseTex;
		float4 _NoiseTex_ST;

		half4 _UVoffset;
		half _FurLength;
		half _Cutoff;
		half _CutoffEnd;
		half _EdgeFade;

		half3 _Gravity;
		half _GravityStrength;
		float4 _AOColor;
		float4 _BaseColor;
		float4 _EdgeColor;
		float _AOIntensity;

		float random01(float2 uv)
		{
			return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453123);
		}

		v2f vert_internal(appdata_t v, half FUR_OFFSET)
		{
			v2f o;

			half3 direction = lerp(v.normal, _Gravity * _GravityStrength + v.normal * (1 - _GravityStrength), FUR_OFFSET);
			v.vertex.xyz += direction * _FurLength * FUR_OFFSET * v.color.a;

			o.vertex = UnityObjectToClipPos(v.vertex);

			o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);

			o.posWorld = mul(unity_ObjectToWorld, v.vertex);
			o.normalDir = mul(unity_ObjectToWorld, half4(v.normal, 0)).xyz;

			UNITY_TRANSFER_FOG(o,o.vertex);
			return o;
		}

		fixed4 frag_internal(v2f i, half FUR_OFFSET)
		{
			half3 normalDirection = normalize(i.normalDir);
			half3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);

			fixed4 basecol = tex2D(_MainTex, i.texcoord.xy) * _BaseColor;

			fixed alpha = tex2D(_NoiseTex, TRANSFORM_TEX(i.texcoord.xy, _NoiseTex)).r;

			fixed ao = max(FUR_OFFSET * FUR_OFFSET, _AOIntensity) ;
			float ndv = saturate(dot(viewDirection, normalDirection));
			float3 lightDir = normalize(UnityWorldSpaceLightDir(i.posWorld));
			float ndl = saturate(dot(normalDirection, lightDir));

			float FurMask = 1.0;
			float FurAlpha = 1.0;
			float SHoffset = 0.3;
			float SHadd = 0.5;
			float sharp = _EdgeFade * FUR_OFFSET;// *(1 + clamp(0, 1, random01(i.texcoord.xy)));
			float updn = dot(float3(0, 1, 0), normalDirection) * 0.6 + 0.4;
			float fresnel =(1.0 - ndv) *(1 - updn);

			fixed4 color = 1.0;
			color.rgb = lerp( _AOColor.rgb, basecol.rgb, ao);
			color.rgb = lerp(   color.rgb, _EdgeColor.rgb , fresnel) ;
			color.rgb += pow(updn ,3)* SHadd;

			color.rgb *= ndl  * 0.5 + 0.3;
			color.a = saturate(alpha * 2.0 - (pow(sharp, 2.0) + sharp * FurMask * 5)) * FurAlpha;
			color.a = max(0, color.a);
			clip(color.a - _Cutoff);

			return color;
		}
		

		v2f vert0(appdata_t v)
		{
			return vert_internal(v, 0);
		}

		
		v2f vert1(appdata_t v)
		{
			return vert_internal(v, 0.05);
		}
		
		v2f vert2(appdata_t v)
		{
			return vert_internal(v, 0.1);
		}
		
		v2f vert3(appdata_t v)
		{
			return vert_internal(v, 0.15);
		}
		
		v2f vert4(appdata_t v)
		{
			return vert_internal(v, 0.2);
		}		

		v2f vert5(appdata_t v)
		{
			return vert_internal(v, 0.25);
		}	
		
		v2f vert6(appdata_t v)
		{
			return vert_internal(v, 0.3);
		}		

		v2f vert7(appdata_t v)
		{
			return vert_internal(v, 0.35);
		}	
		
		v2f vert8(appdata_t v)
		{
			return vert_internal(v, 0.4);
		}	
		
		v2f vert9(appdata_t v)
		{
			return vert_internal(v, 0.45);
		}			

		v2f vert10(appdata_t v)
		{
			return vert_internal(v, 0.5);
		}	
		
		v2f vert11(appdata_t v)
		{
			return vert_internal(v, 0.55);
		}
		
		v2f vert12(appdata_t v)
		{
			return vert_internal(v, 0.6);
		}
		
		v2f vert13(appdata_t v)
		{
			return vert_internal(v, 0.65);
		}
		
		v2f vert14(appdata_t v)
		{
			return vert_internal(v, 0.7);
		}		

		v2f vert15(appdata_t v)
		{
			return vert_internal(v, 0.75);
		}	
		
		v2f vert16(appdata_t v)
		{
			return vert_internal(v, 0.8);
		}		

		v2f vert17(appdata_t v)
		{
			return vert_internal(v, 0.85);
		}

		v2f vert18(appdata_t v)
		{
			return vert_internal(v, 0.9);
		}	
		
		v2f vert19(appdata_t v)
		{
			return vert_internal(v, 0.95);
		}			

		v2f vert20(appdata_t v)
		{
			return vert_internal(v, 1);
		}	

		fixed4 frag0(v2f i) : SV_Target
		{
			return fixed4(_AOColor.rgb, 1);
		}

		fixed4 frag1(v2f i) : SV_Target
		{
			return frag_internal(i, 0.05);
		}

		fixed4 frag2(v2f i) : SV_Target
		{
			return frag_internal(i, 0.1);
		}

		fixed4 frag3(v2f i) : SV_Target
		{
			return frag_internal(i, 0.15);
		}

		fixed4 frag4(v2f i) : SV_Target
		{
			return frag_internal(i, 0.2);
		}

		fixed4 frag5(v2f i) : SV_Target
		{
			return frag_internal(i, 0.25);
		}

		fixed4 frag6(v2f i) : SV_Target
		{
			return frag_internal(i, 0.3);
		}
		
		fixed4 frag7(v2f i) : SV_Target
		{
			return frag_internal(i, 0.35);
		}

		fixed4 frag8(v2f i) : SV_Target
		{
			return frag_internal(i, 0.4);
		}

		fixed4 frag9(v2f i) : SV_Target
		{
			return frag_internal(i, 0.45);
		}

		fixed4 frag10(v2f i) : SV_Target
		{
			return frag_internal(i, 0.5);
		}

		fixed4 frag11(v2f i) : SV_Target
		{
			return frag_internal(i, 0.55);
		}

		fixed4 frag12(v2f i) : SV_Target
		{
			return frag_internal(i, 0.6);
		}

		fixed4 frag13(v2f i) : SV_Target
		{
			return frag_internal(i, 0.65);
		}

		fixed4 frag14(v2f i) : SV_Target
		{
			return frag_internal(i, 0.7);
		}

		fixed4 frag15(v2f i) : SV_Target
		{
			return frag_internal(i, 0.75);
		}

		fixed4 frag16(v2f i) : SV_Target
		{
			return frag_internal(i, 0.8);
		}
		
		fixed4 frag17(v2f i) : SV_Target
		{
			return frag_internal(i, 0.85);
		}

		fixed4 frag18(v2f i) : SV_Target
		{
			return frag_internal(i, 0.9);
		}

		fixed4 frag19(v2f i) : SV_Target
		{
			return frag_internal(i, 0.95);
		}

		fixed4 frag20(v2f i) : SV_Target
		{
			return frag_internal(i, 1);
		}
		ENDCG

		Pass { 
	
			CGPROGRAM
		
			#pragma vertex vert0
			#pragma fragment frag0
		
			ENDCG
		 
		}

		Pass { 
	
			CGPROGRAM
		
			#pragma vertex vert1
			#pragma fragment frag1
		
			ENDCG
		 
		}

		Pass { 
	
			CGPROGRAM
		
			#pragma vertex vert2
			#pragma fragment frag2
		
			ENDCG
		 
		}

		Pass { 
	
			CGPROGRAM
		
			#pragma vertex vert3
			#pragma fragment frag3
		
			ENDCG
		 
		}
		
		Pass { 
	
			CGPROGRAM
		
			#pragma vertex vert4
			#pragma fragment frag4
		
			ENDCG
		 
		}

		Pass { 
	
			CGPROGRAM
		
			#pragma vertex vert5
			#pragma fragment frag5
		
			ENDCG
		 
		}	

		Pass { 
	
			CGPROGRAM
		
			#pragma vertex vert6
			#pragma fragment frag6
		
			ENDCG
		 
		}

		Pass { 
	
			CGPROGRAM
		
			#pragma vertex vert7
			#pragma fragment frag7
		
			ENDCG
		 
		}

		Pass { 
	
			CGPROGRAM
		
			#pragma vertex vert8
			#pragma fragment frag8
		
			ENDCG
		 
		}

		Pass { 
	
			CGPROGRAM
		
			#pragma vertex vert9
			#pragma fragment frag9
		
			ENDCG
		 
		}

		Pass { 
	
			CGPROGRAM
		
			#pragma vertex vert10
			#pragma fragment frag10
		
			ENDCG
		 
		}

		Pass { 
	
			CGPROGRAM
		
			#pragma vertex vert11
			#pragma fragment frag11
		
			ENDCG
		 
		}

		Pass { 
	
			CGPROGRAM
		
			#pragma vertex vert12
			#pragma fragment frag12
		
			ENDCG
		 
		}

		Pass { 
	
			CGPROGRAM
		
			#pragma vertex vert13
			#pragma fragment frag13
		
			ENDCG
		 
		}
		
		Pass { 
	
			CGPROGRAM
		
			#pragma vertex vert14
			#pragma fragment frag14
		
			ENDCG
		 
		}

		Pass { 
	
			CGPROGRAM
		
			#pragma vertex vert15
			#pragma fragment frag15
		
			ENDCG
		 
		}	

		Pass { 
	
			CGPROGRAM
		
			#pragma vertex vert16
			#pragma fragment frag16 
		
			ENDCG
		 
		}

		Pass { 
	
			CGPROGRAM
		
			#pragma vertex vert17
			#pragma fragment frag17
		
			ENDCG
		 
		}

		Pass { 
	
			CGPROGRAM
		
			#pragma vertex vert18
			#pragma fragment frag18
		
			ENDCG
		 
		}

		Pass { 
	
			CGPROGRAM
		
			#pragma vertex vert19
			#pragma fragment frag19
		
			ENDCG
		 
		}

		Pass { 
	
			CGPROGRAM
		
			#pragma vertex vert20
			#pragma fragment frag20
		
			ENDCG
		 
		}	
	}
}
