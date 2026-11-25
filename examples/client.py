"""Call your private API with the official OpenAI Python client.

pip install openai
python client.py
"""
from openai import OpenAI

client = OpenAI(
    base_url="http://YOUR_INSTANCE_IP:YOUR_PORT/v1",  # from the Vast instance page
    api_key="YOUR_API_KEY",                            # from /workspace/api_key.txt
)

response = client.chat.completions.create(
    model="Qwen/Qwen3-8B",  # must match MODEL on the server
    messages=[{"role": "user", "content": "Write a haiku about GPUs."}],
)
print(response.choices[0].message.content)
