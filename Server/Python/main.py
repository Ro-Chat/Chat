import asyncio
import websockets
import json

ServerName = "RoChat"

CLIENTS = set()

client_data = {}
message_logs = []

def getData(id):
  for Client in client_data:
    if client_data[Client]["Id"] == id:
      return Client

async def handler(websocket):
    CLIENTS.add(websocket)
    try:
        async for data in websocket:
          data = json.loads(data)
          if not "Type" in data:
            pass
          if data["Type"] == "File":
            if data["Name"] == "PROFILE_IMG":
              if websocket in client_data:
                client_data[websocket]["Image"] = data["Bin"]
          if data["Type"] == "Connection":
            if data["SubType"] == "Join":
              client_data[websocket] = {
                "Name": data["Name"],
                "Color": data["Color"] or data["Colour"],
                "Socket": websocket,
                "Interactions": []
              }

              client_data[websocket]["Id"] = len(client_data)
              
              await websocket.send(json.dumps({
                "Id": len(client_data),
                "MessageLogs": message_logs
              }))
              
              await broadcast(json.dumps(data))
              # Keep for debugging
              # await broadcast(data, from_client = websocket)
          if data["Type"] == "UI":
            if data["SubType"] == "Chat":
              User = client_data[websocket]

              data["Id"] = User["Id"]
              data["Name"] = User["Name"]
              data["Color"] = User["Color"]
              
              if not "To" in data:
                message_logs.append({
                    "From": User["Id"],
                    "Message": data["Message"],
                    "Name": ServerName
                })
                await broadcast(json.dumps(data))
              else:
                toClient = getData(data["To"])
                await toClient.send(json.dumps(data))
              
            if data["SubType"] == "CreateInteraction":
              client_data[websocket]["Interactions"].append(data["Id"])
            if data["SubType"] == "Interact":
              for client in client_data:
                for interaction in client_data[client]["Interactions"]:
                  if interaction == data["Id"]:
                    await client.send(json.dumps(data))
          pass
    except Exception:
      Id = client_data[websocket]["Id"]
      await broadcast({
        "Type": "Connection",
        "SubType": "Leave",
        "Id": Id
      })
      Idx = 0
      for Json in message_logs:
        if Json["From"] == Id:
          message_logs.pop(Idx)
        Idx += 1
      del client_data[websocket]
      CLIENTS.remove(websocket)
    finally:
        await broadcast({
          "Type": "Connection",
          "SubType": "Leave",
          "Id": client_data[websocket]["Id"]
        })
        del client_data[websocket]
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
