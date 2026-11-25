#!/bin/bash
# Private OpenAI-compatible API on a rented GPU, powered by vLLM.
# Settings come from environment variables (set them in the Vast template or before running):
#   MODEL           Hugging Face model id            (default: Qwen/Qwen3-8B)
#   API_KEY         key clients must send            (default: generated and saved)
#   MAX_MODEL_LEN   max context length in tokens     (default: 8192)
#   API_PORT        port the API listens on          (default: 8000)
#   HF_TOKEN        needed only for gated models (e.g. Llama)
#   EXTRA_ARGS      any extra vLLM flags, e.g. "--tensor-parallel-size 2"
set -e

WORKDIR="${WORKDIR:-/workspace}"
MODEL="${MODEL:-Qwen/Qwen3-8B}"
MAX_MODEL_LEN="${MAX_MODEL_LEN:-8192}"
API_PORT="${API_PORT:-8000}"
KEY_FILE="$WORKDIR/api_key.txt"
mkdir -p "$WORKDIR" && cd "$WORKDIR"

# Keep the same key across restarts
if [ -z "$API_KEY" ]; then
  if [ -f "$KEY_FILE" ]; then
    API_KEY="$(cat "$KEY_FILE")"
  else
    API_KEY="sk-$(head -c 24 /dev/urandom | od -An -tx1 | tr -d ' \n')"
  fi
fi
echo "$API_KEY" > "$KEY_FILE"
chmod 600 "$KEY_FILE"

echo "==> Installing vLLM (first boot only, a few minutes)"
if ! python3 -c "import vllm" 2>/dev/null; then
  python3 -m pip install --upgrade pip
  python3 -m pip install vllm
fi

echo "==> Starting the API with $MODEL on port $API_PORT"
export HF_HOME="$WORKDIR/hf-cache"
nohup python3 -m vllm.entrypoints.openai.api_server \
  --model "$MODEL" \
  --served-model-name "$MODEL" \
  --host 0.0.0.0 \
  --port "$API_PORT" \
  --api-key "$API_KEY" \
  --max-model-len "$MAX_MODEL_LEN" \
  --gpu-memory-utilization 0.90 \
  $EXTRA_ARGS \
  > "$WORKDIR/api.log" 2>&1 &

echo ""
echo "API is starting (the model downloads on first boot, this can take a while)."
echo "Your API key is saved in $KEY_FILE"
echo "Logs: tail -f $WORKDIR/api.log"
