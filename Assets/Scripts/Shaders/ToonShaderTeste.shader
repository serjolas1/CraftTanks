﻿Shader "Unlit/ToonShaderTeste"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Brightness ("Brightness", Range(0, 1)) = 0.3
        _Strength ("Strength", Range(0, 1)) = 0.5
        _Color ("Color", COLOR) = (1, 1, 1, 1)
        _Detail ("Detail", Range(0, 1)) = 0.3
        _OutlineWidth ("Outline Width", Range(0, 10)) = 2
        _OutlineColor ("Outline Color", COLOR) = (0, 0, 0, 1)
    }
    SubShader
    {
        Pass
        {
            Cull Front
            ZWrite ON
            ZTest ON
            Stencil
            {
                Ref 4
                Comp notequal
                Fail keep
                Pass replace
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _OutlineWidth;
            float4 _OutlineColor;

            v2f vert (appdata v)
            {
                v2f o;
                float4 newPos = v.vertex;

                float3 normal = normalize(v.normal);
                newPos += float4(normal, 0.0) * _OutlineWidth;

                o.vertex = UnityObjectToClipPos(newPos);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return _OutlineColor;
            }
            ENDCG
        }

        Tags { "RenderType"="Opaque" }
        LOD 100
        Pass
        {
            Stencil
            {
                Ref 4
                Comp always
                Pass replace
                ZFail keep
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldNormal : NORMAL;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Brightness;
            float _Strength;
            float4 _Color;
            float _Detail;

            float Toon(float3 normal, float3 lightDir) {
                float NdotL = max(0.0, dot(normalize(normal), normalize(lightDir)));

                return floor(NdotL / _Detail);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                col *= Toon(i.worldNormal, _WorldSpaceLightPos0.xyz) * _Strength * _Color + _Brightness;
                return col;
            }
            ENDCG
        }
    }
}
