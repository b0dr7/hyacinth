import asyncio
import threading
import os
from hyacinth.discord import discord_bot
from hyacinth.metrics import flush_buffer as flush_metrics_buffer
from keepalive import run_keepalive   # <-- this line

def run_discord_bot() -> None:
    port = int(os.environ.get("PORT", 8000))
    threading.Thread(target=run_keepalive, args=(port,), daemon=True).start()
    print(f"✅ Keep-alive server started on port {port}")
    try:
        asyncio.run(discord_bot.start())
    except KeyboardInterrupt:
        pass
    finally:
        flush_metrics_buffer()
