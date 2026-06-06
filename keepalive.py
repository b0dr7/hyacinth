import asyncio
from aiohttp import web

async def handle(request):
    return web.Response(text="I'm alive!")

async def start_web_server(port):
    app = web.Application()
    app.router.add_get('/', handle)
    runner = web.AppRunner(app)
    await runner.setup()
    site = web.TCPSite(runner, '0.0.0.0', port)
    await site.start()
    print(f"Keep-alive server running on port {port}")

def run_keepalive(port):
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    loop.run_until_complete(start_web_server(port))
    loop.run_forever()
