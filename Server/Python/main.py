import asyncio
import websockets
import json

CLIENTS = set()

client_data = {}
message_logs = []

def getData(id):
    for Client in client_data:
        if client_data[Client]["Id"] == id:
            return Client


def getMessage(id):
    for Message in message_logs:
        if Message["Id"] == id:
            return Message


async def handler(websocket):
    CLIENTS.add(websocket)
    try:
        async for data in websocket:
            data = json.loads(data)
            if not "Type" in data:
                return
              
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

                    await websocket.send(
                        json.dumps({
                            "Type": "Connection",
                            "SubType": "Info",
                            "Id": len(client_data),
                            "MessageLogs": message_logs
                        }))

                    await broadcast(json.dumps(data))
            if data["Type"] == "UI":
                if data["SubType"] == "Destroy":
                    try:
                        User = client_data[websocket]
                        Message = getMessage(data["Id"])
                        if User["Id"] == Message["From"]:
                            await broadcast(
                                json.dumps({
                                    "Type": "UI",
                                    "SubType": "Destroy",
                                    "Id": data["Id"],
                                    "From": User["Id"]
                                }))
                            del Message
                    except Exception:
                        pass
                 
                if data["SubType"] == "Edit":
                    try:
                        User = client_data[websocket]
                        Message = getMessage(data["Id"])
                        if User["Id"] == Message["From"]:
                            Message["Message"] = data["Message"]
                            await broadcast(
                                json.dumps({
                                    "Type": "UI",
                                    "SubType": "Edit",
                                    "Message": data["Message"],
                                    "Id": data["Id"]
                                }))
                    except Exception:
                        pass
                
                if data["SubType"] == "React":
                    try:
                        User = client_data[websocket]
                        Message = getMessage(data["Id"])
                        if not data["Reaction"] in Message["Reactions"]:
                            Message["Reactions"][data["Reaction"]] = 1
                        else:
                            Message["Reactions"][data["Reactions"]] += 1
                        await broadcast(
                            json.dumps({
                                "Type": "UI",
                                "SubType": "React",
                                "FromId": User["Id"],
                                "MessageId": data["Id"],
                                "Reaction": data["Reaction"]
                            }))
                    except Exception:
                        pass

                if data["SubType"] == "RevokeReact":
                    try:
                        User = client_data[websocket]
                        Message = getMessage(data["Id"])

                        if Message["Reactions"][data["Reaction"]] == 1:
                            del Message["Reactions"][data["Reaction"]]
                        else:
                            Message["Reactions"][data["Reaction"]] -= 1

                        await broadcast(
                            json.dumps({
                                "Type": "UI",
                                "SubType": "RevokeReact",
                                "FromId": User["Id"],
                                "MessageId": data["Id"],
                                "Reaction": data["Reaction"]
                            }))
                    except Exception:
                        pass

                if data["SubType"] == "Chat":
                    User = client_data[websocket]

                    data["Id"] = User["Id"]
                    data["Name"] = User["Name"]
                    data["Color"] = User["Color"]
                    data["MessageId"] = len(
                        message_logs) == 0 and 1 or message_logs[
                            len(message_logs) - 1]["Id"] + 1

                    isPrivate = "To" in data

                    message_logs.append({
                        "From":
                        User["Id"],
                        "Message":
                        not isPrivate and data["Message"] or "REDACTED",
                        "Id":
                        data["MessageId"],
                        "Reactions": {}
                    })
                    if not isPrivate:
                        await broadcast(json.dumps(data))
                    else:
                        toClient = getData(data["To"])
                        await toClient.send(json.dumps(data))

                if data["SubType"] == "CreateInteraction":
                    try:
                        client_data[websocket]["Interactions"].append(
                            data["Id"])
                    except Exception:
                        pass
                if data["SubType"] == "Interact":
                    try:
                        for client in client_data:
                            for interaction in client_data[client][
                                    "Interactions"]:
                                if interaction == data["Id"]:
                                    await client.send(json.dumps(data))
                    except Exception:
                        pass
            pass
    finally:
        try:
            Id = client_data[websocket]["Id"]
            await broadcast(
                json.dumps({
                    "Type": "Connection",
                    "SubType": "Leave",
                    "Id": Id
                }))
            Idx = 0
            for Json in message_logs:
                if Json["From"] == Id:
                    message_logs.pop(Idx)
            Idx += 1
            del client_data[websocket]
        except Exception:
            pass
        finally:
            try:
                CLIENTS.remove(websocket)
            except Exception:
                pass


async def broadcast(message, from_client=None):
    for websocket in CLIENTS.copy():
        if from_client == websocket:
            pass
        try:
            if type(message) == dict:
                message = json.dumps(dict)
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
