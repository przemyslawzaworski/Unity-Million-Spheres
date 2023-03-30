using UnityEngine;

public class MillionSpheres : MonoBehaviour
{
	[SerializeField] Shader _Shader;
	[SerializeField] int _Count = 1000000;
	[SerializeField] [Range(50f, 200f)] float _Spread = 100.0f;
	ComputeBuffer _ComputeBuffer;
	Material _Material;

	void Start()
	{
		_Material = new Material(_Shader);
		_ComputeBuffer = new ComputeBuffer(_Count, 6 * sizeof(float), ComputeBufferType.Default);
		float[] data = new float[_Count * 6];
		for (int i = 0; i < _Count; i++)
		{
			for (int j = 0; j < 6; j++) 
			{
				data[i * 6 + j] = (j < 3) ? Random.Range(-1f, 1f) : Random.Range(0f, 1f);
			}
		}
		_ComputeBuffer.SetData(data);
	}

	void OnRenderObject()
	{
		_Material.SetFloat("_Spread", _Spread);
		_Material.SetBuffer("_ComputeBuffer", _ComputeBuffer);
		_Material.SetPass(0);
		Graphics.DrawProceduralNow(MeshTopology.Triangles, 36 * _Count, 1);
	}

	void OnDestroy()
	{
		if (_Material != null) Destroy(_Material);
		if (_ComputeBuffer != null) _ComputeBuffer.Release();
	}
}