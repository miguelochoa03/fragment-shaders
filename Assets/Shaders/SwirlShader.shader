Shader "Unlit/SwirlShader"
{
    Properties
    {
        _MainTex ("Base Image", 2D) = "" {}
        _SecondTex ("Second Image", 2D) = "" {}
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
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _SecondTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }
            float2 SwirlUV(float2 uv, float strength, float time)
            {
                float2 centered = uv - 0.5;

                // distance from center
                float dist = length(centered);

                // rotation angle distance increases
                float angle = strength * dist * sin(time);

                // rotation matrix
                float s = sin(angle);
                float c = cos(angle);

                float2 rotated;
                rotated.x = centered.x * c - centered.y * s;
                rotated.y = centered.x * s + centered.y * c;

                // rotate back
                return rotated + 0.5;
            }
            fixed4 frag (v2f i) : SV_Target
            {
                // swirl
                float2 swirlUV = SwirlUV(i.uv, 10.0, _Time.y);

                // both images
                fixed4 colA = tex2D(_MainTex, swirlUV);
                fixed4 colB = tex2D(_SecondTex, swirlUV);

                // fade
                float fade = (sin(_Time.y * 0.7) * 0.5) + 0.5;
                fixed4 col = lerp(colA, colB, fade);

                return col;
            }
            ENDCG
        }
    }
}
