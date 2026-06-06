import asyncio
import threading
import os
from hyacinth.discord import discord_bot
from hyacinth.metrics import flush_buffer as flush_metrics_buffer
# [!] Add this line to import your keepalive script
from keepalive import run_keepalive

def run_discord_bot() -> None:
    # [!] Add these lines to start the keepalive server in a background thread
    port = int(os.environ.get("PORT", 8000))
    threading.Thread(target=run_keepalive, args=(port,), daemon=True).start()
    print(f"✅ Keep-alive server started on port {port}")

    # Original bot startup code
    try:
        asyncio.run(discord_bot.start())
    except KeyboardInterrupt:
        pass
    finally:
        flush_metrics_buffer()
