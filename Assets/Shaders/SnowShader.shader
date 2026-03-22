Shader "Unlit/SnowShader"
{
    Properties
    {
        _MainTex ("Base Image", 2D) = "" {}
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv     : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv      : TEXCOORD0;
                float4 vertex  : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            float noise(float2 seed) 
            {
                return frac(sin(dot(seed, float2(12.9898, 78.233))) * 43758.5453);
            }
            fixed4 frag (v2f i) : SV_Target
            {
                // image scroll
                float2 scrollUV = i.uv;
                scrollUV.y = frac(scrollUV.y + _Time.y * -1);

                // image
                fixed4 col = tex2D(_MainTex, scrollUV);

                // uv
                float2 uv = i.uv;

                // scroll downwards
                float speed = 0.2;
                uv.y = frac(uv.y + _Time.y * speed);

                // noise
                float n = noise(uv * 50.0);

                // flakes
                float flake = step(0.20, n);

                // snow color
                float3 snowColor = float3(1.0, 1.0, 1.0);

                // snow on image
                float intensity = 0.7;
                float3 snowImage = col.rgb + snowColor * flake * intensity;

                return float4(snowImage, col.a); 
            }
            ENDCG
        }
    }
}
