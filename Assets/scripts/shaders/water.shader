Shader "Unlit/water"
{
    Properties
    {
        _Tex ("Texture", 2D) = "white" {}//the main texture-- used as the height map
        _UnderWater ("under water texture", 2D) = "white" {}
        _AboveWater ("above water texture", 2D) = "white" {}
        _NoiseMap ("noise map", 2D) = "white" {}

        _BaseColor("base-color", Vector) = (0.99,0.0,0.3,0.0)

        _Seperation("_Seperation", float) = 0.0
        _TotalSize("_TotalSize", float) = 0.0
        _MaxHeight("max height", float) = 0.0
        _Count("count", float) = 0.0

        _NoiseFrequency("noise frequency", float) = 100.0
        _NoiseScrollDive("noise scroll dive", float) = 1000.0
        _NoiseAmplitude("noise amplitude", float) = 2.0


        [HDR]
        _AmbientColor("Ambient Color", Color) = (0.0,0.0,0.0,1.0)
        _SpecularColor("Specular Color", Color) = (0.1,0.1,0.1,1)
        _Glossiness("Glossiness", Range(0, 100)) = 14

        _RimColor("Rim Color", Color) = (1,1,1,1)
        _RimAmount("Rim Amount", Range(0, 1)) = 1.0

        _LightExp("light distance exponential", range(0, 5)) = 0.5
        _LightMult("light distance multiplier", range(0, 20)) = 8
    }
    SubShader
    {

        Blend One One
        Tags {"RenderType"="Opaque"}
        Lighting On
        LOD 200
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask RGB
        Pass
        {
            Tags {"LightMode"="ForwardAdd"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "waterDistortion.cginc"
            #include "cellShading.cginc"

            #pragma multi_compile_fwdadd_fullshadows
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };


            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 wpos : TEXCOORD1;
                float4 screenPos : TEXCOORD2;
                float3 worldNormal : NORMAL;
                float3 viewDir : TEXCOORD3;
                float4 pos : TEXCOORD4;
            };

            sampler2D _Tex;
            float4 _Tex_ST;

            sampler2D _UnderWater;
            float4 _UnderWater_ST;

            sampler2D _AboveWater;
            float4 _AboveWater_ST;

            sampler2D _NoiseMap;
            float _NoiseMap_ST;

            uniform float _Seperation;
            uniform float _TotalSize;
            uniform float _MaxHeight;
            uniform float4 _BaseColor;

            uniform float _Glossiness;
            uniform float4 _SpecularColor;
            uniform float4 _RimColor;
            uniform float _RimAmount;
            uniform float4 _AmbientColor;
            uniform float _LightExp;
            uniform float _LightMult;
            uniform float _Count;

            uniform float _NoiseFrequency;
            uniform float _NoiseScrollSpeedDiv;
            uniform float _NoiseAmplitude;

            v2f vert (appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _Tex);

                //get world position from object position
                float4 worldPos = mul (unity_ObjectToWorld, v.vertex);
                o.wpos = worldPos;

                waterOutput w = GetWaterDistortion(_Tex, _NoiseMap, v.vertex, worldPos, v.uv, _NoiseAmplitude, _Count, _Seperation, _TotalSize, _MaxHeight);
                v.vertex = w.vertex;
                o.worldNormal = w.worldNorm;

                worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.wpos = worldPos;

                o.pos = v.vertex;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _Tex);
				o.screenPos = ComputeScreenPos(o.vertex);
                o.viewDir = WorldSpaceViewDir(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_Tex, i.uv);

                fixed4 noise = tex2D(_NoiseMap, float2(i.wpos.x/100.0 + _Count/1000.0,i.wpos.z/100.0));

                //get the noise value
                //fixed4 col = tex2D(_NoiseMap, i.uv);
                //check to see if we should render this fragment (if its inside the pot)
                float4 shading = GetShading(i.wpos, i.vertex, _WorldSpaceLightPos0, i.worldNormal, i.viewDir, _BaseColor, _BaseColor, _SpecularColor, _RimAmount, _Glossiness);
                //render the render texure relative to screen position
                fixed4 underWaterTex = tex2D(_UnderWater, float2(i.screenPos.x, i.screenPos.y)/i.screenPos.w);
                fixed4 aboveWaterTex = tex2D(_AboveWater, float2(i.screenPos.x + noise.r/2.0, i.screenPos.y + noise.r/5.0 + shading.r/10.0-0.5)/i.screenPos.w);

                float dist = clamp(( (pow(length(i.wpos - _WorldSpaceLightPos0), _LightExp)) * _LightMult),1.0,10.0);\

                col = _BaseColor * shading *shading;
                col.a = 1.0;

                float4 bias = clamp(((col*2 + aboveWaterTex/4.0 - underWaterTex/2.0)/1.0)/dist,0.0,0.5);
                //col.rb *= dist;
                bias.a = 1.0;
                return bias;
            }
            ENDCG
        }

        Pass {
			Tags {
				"LightMode" = "ShadowCaster"
			}

			CGPROGRAM

			#pragma target 3.0

			#pragma multi_compile_shadowcaster

			#pragma vertex MyShadowVertexProgram
			#pragma fragment MyShadowFragmentProgram

            #if !defined(MY_SHADOWS_INCLUDED)
            #define MY_SHADOWS_INCLUDED

            #include "UnityCG.cginc"

            struct VertexData {
                float4 position : POSITION;
                float3 normal : NORMAL;
                float3 uv : TEXCOORD0;
            };

            sampler2D _Tex;
            float4 _Tex_ST;

            float _MaxHeight;

            #if defined(SHADOWS_CUBE)
                struct Interpolators {
                    float4 position : SV_POSITION;
                    float3 lightVec : TEXCOORD0;
                };

                Interpolators MyShadowVertexProgram (VertexData v) {
                    Interpolators i;
                    i.position = UnityObjectToClipPos(v.position);
                    //i.uv = TRANSFORM_TEX(v.uv, _Tex);
                    #if !defined(SHADER_API_OPENGL)
                        float4 height = tex2Dlod (_Tex, float4(float2(v.uv.x,v.uv.y),0,0));
                        i.position.y += height.r - _MaxHeight;
                    #endif
                    i.lightVec = mul(unity_ObjectToWorld, i.position).xyz - _LightPositionRange.xyz;
                    return i;
                }

                float4 MyShadowFragmentProgram (Interpolators i) : SV_TARGET {
                    float depth = length(i.lightVec) + unity_LightShadowBias.x;
                    depth *= _LightPositionRange.w;
                    return UnityEncodeCubeShadowDepth(depth);
                }
            #else
                float4 MyShadowVertexProgram (VertexData v) : SV_POSITION {
                    float4 position =
                        UnityClipSpaceShadowCasterPos(v.position.xyz, v.normal);
                    return UnityApplyLinearShadowBias(position);
                }

                half4 MyShadowFragmentProgram () : SV_TARGET {
                    return 0;
                }
            #endif

            #endif

			ENDCG
		}


    }
}
