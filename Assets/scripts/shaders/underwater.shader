Shader "Unlit/underwater"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _HeightMap("heightmap", 2D) = "white" {}
        _NoiseMap("noise map", 2D) = "white" {}
        _Caustics("caustics", 2D) = "white" {}


        _NoiseScrollSpeedDiv("noise scroll speed divider",float) = 30000.0
        _NoiseScrollFrequency("noise frequency",float) = 40.0

        _CausticsSpeedDiv("caustic speed divider",float) = 40000.0
        _CausticsFrequency("caustic frequency",float) = 40.0
        _CausticsNoiseDiv("caustic noise divider",float) = 500.0
        _CausticStrength("caustic strength",float) = 0.006

        _MaxHeight("max height", float) = 0.0
        _WaterSize("water size", float) = 0.0
        _Count("counter", float) = 0.0
        _WaterOpaqueness("water opaqueness", float) = 0.0
        _WaterLevel("water level", float) = 0.0
        _CullAboveWater("cull above water", int) = 0
        _Center("center", Vector) = (0.0,0.0,0.0,0.0)

        [HDR]
        _AmbientColor("Ambient Color", Color) = (0.0,0.0,0.0,1.0)
        _SpecularColor("Specular Color", Color) = (0.0,0.0,0.0,1)
        _Glossiness("Glossiness", Range(0, 100)) = 14

        _RimColor("Rim Color", Color) = (1,1,1,1)
        _RimAmount("Rim Amount", Range(0, 1)) = 1.0


        _LightExp("light distance exponential", range(0, 5)) = 1
        _LightMult("light distance multiplierr", range(0, 20)) = 10.0

    }
    SubShader
    {
        Tags {"Queue" = "Transparent" "RenderType"="Transparent" "LightMode" = "ForwardAdd"}
        LOD 200
        ColorMask RGBA
        Blend SrcAlpha OneMinusSrcAlpha
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "cellShading.cginc"
            #pragma multi_compile_fwdadd

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 normal: NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 wpos : TEXCOORD1;
                float3 worldNormal : NORMAL;
                float3 viewDir : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _HeightMap;
            float4 _HeightMap_ST;

            sampler2D _NoiseMap;
            float4 _NoiseMap_ST;

            sampler2D _Caustics;
            float4 _Caustics_ST;

            uniform float _Count;

            uniform float _NoiseScrollSpeedDiv;
            uniform float _NoiseScrollFrequency;

            uniform float _CausticsSpeedDiv;
            uniform float _CausticsFrequency;
            uniform float _CausticsNoiseDiv;
            uniform float _CausticStrength;

            uniform float _WaterSize;
            uniform float _MaxHeight;
            uniform float _WaterOpaqueness;
            uniform float _WaterLevel;

            uniform float4 _Center;


            uniform float _Glossiness;
            uniform float4 _SpecularColor;
            uniform float4 _RimColor;
            uniform float _RimAmount;
            uniform float4 _AmbientColor;
            uniform float _LightExp;
            uniform float _LightMult;

            uniform int _CullAboveWater;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = v.normal;
                o.wpos = mul(unity_ObjectToWorld, v.vertex);
                o.viewDir = WorldSpaceViewDir(v.vertex);
                return o;
            }

            float2 getWaterUV(v2f i){
                return ((i.wpos.xz - _Center.xz + _WaterSize/2.0)/_WaterSize);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 noise = tex2D(_NoiseMap, float2(i.uv.x - _Count/_NoiseScrollSpeedDiv, i.uv.y - _Count/_NoiseScrollSpeedDiv)*_NoiseScrollFrequency);
                fixed4 caustics = tex2D(_Caustics, float2(i.uv.x + noise.r/_CausticsNoiseDiv, i.uv.y + _Count/_CausticsSpeedDiv + noise.r/_CausticsNoiseDiv)*_CausticsFrequency);

                float dist = (1.0 / pow(length(i.wpos - _WorldSpaceCameraPos), _LightExp) * _LightMult);

                fixed4 col = tex2D(_MainTex, i.uv*50.0);

                float2 waterUV = getWaterUV(i);
                float waterHeight = tex2D(_HeightMap, waterUV);

                float waterLevel = _WaterLevel - _MaxHeight+0.47;


                if (i.wpos.y < waterLevel+0.8){
                    col.a = (2.0 - pow(abs(i.wpos.y - _WaterLevel),0.5) * _WaterOpaqueness);
                }else if (_CullAboveWater == 0){
                    col.a = (2.0 - pow(abs(i.wpos.y - _WaterLevel),0.5) * _WaterOpaqueness);
                }else{
                    col.rgb *= 0.5;
                }

                return (col - caustics.r * _CausticStrength) * dist;;
            }
            ENDCG
        }
    }
}
