# Your own private OpenAI-compatible API in 5 minutes

Run any open model (Qwen, Llama, Mistral, Gemma, DeepSeek…) as a **private API** on a rented GPU, powered by [vLLM](https://github.com/vllm-project/vllm).

- **Drop-in OpenAI replacement**: works with the OpenAI SDKs, LangChain, LlamaIndex, Open WebUI, n8n, Continue, Cursor-style tools… just change the base URL.
- **Your data stays on your server**: nothing goes to a third-party API.
- **Flat hourly cost**: no per-token billing, which makes heavy or batch workloads much cheaper.

## ▶️ Launch

**[Launch on Vast.ai](https://cloud.vast.ai/?ref_id=879548&creator_id=879548&name=Private%20LLM%20API%20-%20One%20Click)**: opens a pre-configured GPU instance; vLLM installs and starts your API on boot.

No account yet? [Create one on Vast.ai](https://cloud.vast.ai/?ref_id=879548).

## Choose your model and GPU

Set the `MODEL` environment variable before launching (on Vast: *Edit* the template config on the launch page). Default: `Qwen/Qwen3-8B`.

| Model size | Example `MODEL` | GPU | VRAM |
| --- | --- | --- | --- |
| 7–8B | `Qwen/Qwen3-8B` | RTX 3090 / 4090 | 24 GB |
| 14B | `Qwen/Qwen3-14B` | RTX 5090 / A6000 | 32–48 GB |
| 32B (quantized) | `Qwen/Qwen3-32B-AWQ` | A6000 / L40S | 48 GB |
| 70B (quantized) | an AWQ/GPTQ 70B build | A100 / H100 | 80 GB |

Bigger models in full precision need several GPUs: rent a multi-GPU machine and set `EXTRA_ARGS="--tensor-parallel-size 2"` (or 4, 8). Use **On-Demand** instances (not Interruptible) and hosts with a high reliability score if the API must stay up. Set **Disk Space to at least 60 GB** (more for large models).

## Settings

| Variable | Default | What it does |
| --- | --- | --- |
| `MODEL` | `Qwen/Qwen3-8B` | Any Hugging Face model supported by vLLM |
| `API_KEY` | generated | Key clients must send; saved in `/workspace/api_key.txt` |
| `MAX_MODEL_LEN` | `8192` | Max context length (higher = more VRAM) |
| `HF_TOKEN` | – | Only for gated models (e.g. Llama) |
| `EXTRA_ARGS` | – | Extra vLLM flags, e.g. `--tensor-parallel-size 2` |

## Connect to your API

1. On the Vast instance page, open **IP & Port info** and find the public address mapped to port **8000** (e.g. `http://1.2.3.4:40123`).
2. Get your key: open Jupyter or the terminal and read `/workspace/api_key.txt`.
3. Test it:

```bash
curl http://1.2.3.4:40123/v1/chat/completions \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model": "Qwen/Qwen3-8B", "messages": [{"role": "user", "content": "Hello!"}]}'
```

Python (official OpenAI client):

```python
from openai import OpenAI
client = OpenAI(base_url="http://1.2.3.4:40123/v1", api_key="YOUR_API_KEY")
r = client.chat.completions.create(model="Qwen/Qwen3-8B",
                                   messages=[{"role": "user", "content": "Hello!"}])
print(r.choices[0].message.content)
```

More in [`examples/`](examples/).

The first boot downloads the model, so the API can take several minutes to answer. Follow progress with `tail -f /workspace/api.log`.

## Running it on any other GPU server

```bash
curl -fsSL https://raw.githubusercontent.com/giovannajasmin/private-llm-api/main/setup.sh | MODEL=Qwen/Qwen3-8B bash
```

## Security notes

- Keep your API key private; anyone with the URL and key can use your GPU.
- Traffic is plain HTTP by default. For production, put it behind HTTPS (e.g. Caddy or a Cloudflare tunnel).
- **Destroy the instance when you are done** to stop paying.

## Credits

Built on [vLLM](https://github.com/vllm-project/vllm). This repo only provides a ready-to-run launcher for cloud GPUs.

*The Vast.ai links in this README are affiliate links.*
