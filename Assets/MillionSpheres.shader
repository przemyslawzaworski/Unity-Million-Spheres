Shader "Hidden/MillionSpheres"
{
	Subshader
	{	
		Pass
		{
			CGPROGRAM
			#pragma vertex VSMain
			#pragma fragment PSMain
			#pragma target 5.0

			static const float3 _Vertices[36] = // vertices of single cube, in local space
			{
				{ 0.5, -0.5,  0.5}, { 0.5,  0.5,  0.5}, {-0.5,  0.5,  0.5},
				{ 0.5, -0.5,  0.5}, {-0.5,  0.5,  0.5}, {-0.5, -0.5,  0.5},
				{ 0.5,  0.5,  0.5}, { 0.5,  0.5, -0.5}, {-0.5,  0.5, -0.5},
				{ 0.5,  0.5,  0.5}, {-0.5,  0.5, -0.5}, {-0.5,  0.5,  0.5},
				{ 0.5,  0.5, -0.5}, { 0.5, -0.5, -0.5}, {-0.5, -0.5, -0.5},
				{ 0.5,  0.5, -0.5}, {-0.5, -0.5, -0.5}, {-0.5,  0.5, -0.5},
				{ 0.5, -0.5, -0.5}, { 0.5, -0.5,  0.5}, {-0.5, -0.5,  0.5},
				{ 0.5, -0.5, -0.5}, {-0.5, -0.5,  0.5}, {-0.5, -0.5, -0.5},
				{-0.5, -0.5,  0.5}, {-0.5,  0.5,  0.5}, {-0.5,  0.5, -0.5},
				{-0.5, -0.5,  0.5}, {-0.5,  0.5, -0.5}, {-0.5, -0.5, -0.5},
				{ 0.5, -0.5, -0.5}, { 0.5,  0.5, -0.5}, { 0.5,  0.5,  0.5},
				{ 0.5, -0.5, -0.5}, { 0.5,  0.5,  0.5}, { 0.5, -0.5,  0.5},
			};

			StructuredBuffer<float3> _ComputeBuffer;
			float _Spread;

			float Modulo (float x, float y)
			{
				return x - y * floor(x / y);
			}

			// ro = ray origin; rd = ray direction; c = sphere center; r = sphere radius; returns the distance to the closest intersection;
			float Sphere (float3 ro, float3 rd, float3 c, float r)
			{
				float3 oc = ro - c;
				float b = dot(oc, rd);
				float h = b * b - (dot(oc, oc) - r * r);
				if(h < 0.0) return -1.0; 
				return -b - sqrt(h);
			}

			float4 VSMain (uint id : SV_VertexID, out float3 worldPos : WORLDPOS, out float3 center : CENTER, out float3 albedo : ALBEDO) : SV_POSITION
			{
				uint instance = floor(id / 36.0);
				center = _ComputeBuffer[instance * 2 + 0] * _Spread;
				albedo = _ComputeBuffer[instance * 2 + 1];
				center += sin(_Time.g * 3.0 + instance);
				uint index = uint(Modulo(id, 36.0));
				worldPos = _Vertices[index] + center;
				return mul(UNITY_MATRIX_VP, float4(worldPos, 1.0));
			}

			float4 PSMain (float4 vertex : SV_POSITION, float3 worldPos : WORLDPOS, float3 center : CENTER, float3 albedo : ALBEDO, out float depth : SV_Depth) : SV_Target
			{
				float3 viewDir = normalize(worldPos - _WorldSpaceCameraPos.xyz);
				float intersection = Sphere(worldPos, viewDir, center, 0.4999);
				if (intersection <= 0.0) discard;
				float3 surfaceHit = worldPos + intersection * viewDir;
				float3 color = max(dot(normalize(_WorldSpaceLightPos0.xyz), normalize(surfaceHit - center)), 0.05).xxx * albedo;
				float4 clipPos = mul(UNITY_MATRIX_VP, float4(surfaceHit, 1.0));
				depth = clipPos.z / clipPos.w;
				return float4(color, 1.0);
			}
			ENDCG
		}
	}
}