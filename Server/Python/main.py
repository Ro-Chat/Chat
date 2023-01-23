import asyncio
import websockets
import json
import requests
import base64

CLIENTS = set()

client_data = {}


async def handler(websocket):
    CLIENTS.add(websocket)
    try:
        async for data in websocket:
          data = json.loads(data)
          if not "Type" in data:
            pass
          if data["Type"] == "Connection":
            if data["SubType"] == "Join":
              client_data[websocket] = {
                "Name": data["Name"],
                "Color": data["Color"] or data["Colour"],
                "Socket": websocket,
                "Interactions": []
              }
              # Keep for debugging
              await broadcast(json.dumps(data))
              # await broadcast(data, from_client = websocket)
          if data["Type"] == "UI":
            if data["SubType"] == "Chat":
              await broadcast(json.dumps(data))
            if data["SubType"] == "CreateInteraction":
              client_data[websocket]["Interactions"].append(data["Id"])
            if data["SubType"] == "Interact":
              for client in client_data:
                for interaction in client_data[client]["Interactions"]:
                  if interaction == data["Id"]:
                    await client.send(json.dumps(data))
          pass
    finally:
        CLIENTS.remove(websocket)


async def broadcast(message, from_client=None):
    for websocket in CLIENTS.copy():
        if from_client == websocket:
            pass
        try:
            await websocket.send(message)
        except websockets.ConnectionClosed:
            pass


messages = []


async def broadcast_messages():
    while True:
        await asyncio.sleep(0.5)
        if len(messages) == 0:
            pass
        for message in messages:
            await broadcast(message)
            messages.remove(message)


async def main():
    async with websockets.serve(handler, "0.0.0.0", 443):
        await broadcast_messages()


if __name__ == "__main__":
    asyncio.run(main())
