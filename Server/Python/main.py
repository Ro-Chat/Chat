import asyncio
import websockets
import json
from hashlib import sha256

CLIENTS = set()

start_queue = []
client_data = {}

channels = {
    "General": {
        "Name": "General",
        "Id": 0,
        "Description": "This is the default channel.",
        "Messages": [],
    },
    "Default": {
        "Name": "Default",
        "Id": -1,
        "Description": "Roblox's native chat.",
        "Messages": []
    },
    "Admin": {
        "Name": "Admin",
        "Id": 1,
        "Description": "This is the admin chat.",
        "Ranks": ["Admin"],
        "Messages": []
    }
}

message_logs = []


def getMetadata():
    with open("metadata.json", "r") as f:
        return json.loads(f.read())


def setMetadata(metadata):
    with open("metadata.json", "w") as f:
        f.write(json.dumps(metadata))


def removeRank(fingerprint, Rank):
    metadata = getMetadata()

    counter = 0
    for rank in metadata["Ranks"]:
        if rank["Name"] == Rank:
            fingerprint = sha256(bytes(fingerprint.encode())).hexdigest()
            if not fingerprint in metadata["Ranks"][counter]["Fingerprints"]:
                continue
            metadata["Ranks"][counter]["Fingerprints"].remove(fingerprint)
        counter += 1

    setMetadata(metadata)


def setRank(fingerprint, Rank):
    metadata = getMetadata()

    counter = 0
    for rank in metadata["Ranks"]:
        if rank["Name"] == Rank:
            fingerprint = sha256(bytes(fingerprint.encode())).hexdigest()
            if fingerprint in metadata["Ranks"][counter]["Fingerprints"]:
                continue
            metadata["Ranks"][counter]["Fingerprints"].append(
                sha256(bytes(fingerprint.encode())).hexdigest())
        counter += 1

    setMetadata(metadata)


def checkPrivilege(fingerprint, level):
    metadata = getMetadata()
    fingerprint = sha256(bytes(fingerprint.encode())).hexdigest()

    if metadata["Owner"] == fingerprint:
        return True

    for rank in metadata["Ranks"]:
        if fingerprint in rank["Fingerprints"] and rank["Privilege"] >= level:
            return True


def checkRank(fingerprint, rank):
    metadata = getMetadata()
    fingerprint = sha256(bytes(fingerprint.encode())).hexdigest()
    
    if "Owner" in metadata and metadata["Owner"] == fingerprint:
        return True

    for rank in metadata["Ranks"]:
        if fingerprint in rank["Fingerprints"]:
            return True

def getChannels(fingerprint):
    Channels = {}
    for Channel in channels:
        if "Ranks" in channels[Channel]:
          for Rank in channels[Channel]:
            if checkRank(fingerprint, Rank):
              Channels[Channel] = channels[Channel]
        else:
          Channels[Channel] = channels[Channel]

    return Channels


def getData(id):
    for Client in client_data:
        if client_data[Client]["Id"] == id:
            return Client


def newId():
    ret = 0
    for Client in client_data:
        if client_data[Client]["Id"] >= ret:
            ret = client_data[Client]["Id"]

    return ret


def getMessage(channel, id):
    for Message in channels[channel]["Messages"]:
        if Message["Id"] == id:
            return Message


if not ("Owner" in getMetadata()):
    owner_key = input("Set owner key: ")
    print(
        "after executing the script type /redeem KEY to get ownership of the server."
    )


async def handler(websocket):
    global owner_key
    CLIENTS.add(websocket)
    try:
        async for data in websocket:
            data = json.loads(data)
            if not "Type" in data:
                return
            if data["Type"] == "Rank":
                if data["SubType"] == "Set":
                    if checkPrivilege(client_data[websocket]["Fingerprint"],
                                      10):
                        fingerprint = client_data[getData(
                            data["Id"])]["Fingerprint"]
                        setRank(fingerprint, data["Rank"])
                        data["Fingerprint"] = sha256(
                            bytes(fingerprint.encode())).hexdigest()
                        await broadcast(
                            json.dumps({
                                "Type": "Rank",
                                "SubType": "Set",
                                "Fingerprint": data["Fingerprint"],
                                "Rank": data["Rank"]
                            }))
                if data["SubType"] == "Remove":
                    if checkPrivilege(client_data[websocket]["Fingerprint"],
                                      10):
                        fingerprint = client_data[getData(
                            data["Id"])]["Fingerprint"]
                        removeRank(fingerprint, data["Rank"])
                        data["Fingerprint"] = sha256(
                            bytes(fingerprint.encode())).hexdigest()
                        await broadcast(
                            json.dumps({
                                "Type": "Rank",
                                "SubType": "Remove",
                                "Fingerprint": data["Fingerprint"],
                                "Rank": data["Rank"]
                            }))
                if data["SubType"] == "RedeemOwner" and owner_key:
                    metadata = getMetadata()

                    if not ("Owner" in metadata) and owner_key == data["Key"]:
                        metadata["Owner"] = sha256(
                            bytes(client_data[websocket]
                                  ["Fingerprint"].encode())).hexdigest()
                        setMetadata(metadata)

                    owner_key = None

            if data["Type"] == "File":
                if data["Name"] == "PROFILE_IMG":
                    if websocket in client_data:
                        client_data[websocket]["Image"] = data["Bin"]
            if data["Type"] == "Connection":
                if data["SubType"] == "Join":
                    for client in client_data:
                        if client_data[client]["Fingerprint"] == data[
                                "Fingerprint"]:
                            await websocket.send(
                                "{\"Error\": \"This fingerprint is already in use.\"}"
                            )
                            return
                    client_data[websocket] = {
                        "Name":
                        data["Name"],
                        "Color":
                        data["Color"] or data["Colour"],
                        "Socket":
                        websocket,
                        "Fingerprint":
                        data["Fingerprint"],
                        "Key":
                        websocket.request_headers.get_all(
                            "Sec-WebSocket-Accept"),
                        "Interactions": [],
                        "Id":
                        newId()
                    }
                    metadata = getMetadata()
                    await websocket.send(
                        json.dumps({
                            "Type":
                            "Connection",
                            "SubType":
                            "Info",
                            "Id":
                            client_data[websocket]["Id"],
                            "Metadata":
                            metadata,
                            # "MessageLogs": message_logs,
                            "Key":
                            websocket.request_headers.get_all(
                                "Sec-WebSocket-Accept"),
                            "Channels":
                            getChannels(client_data[websocket]["Fingerprint"])
                        }))
                    
                    data["Fingerprint"] = sha256(
                        bytes(data["Fingerprint"].encode())).hexdigest()
                    data["Id"] = client_data[websocket]["Id"]
                    # await broadcast(json.dumps(data))
                    # Keep for debugging
                    await broadcast(json.dumps(data))
            if data["Type"] == "UI":
                if data["SubType"] == "Destroy":
                    try:
                        User = client_data[websocket]
                        Message = getMessage(data["Channel"], data["Id"])
                        if User["Id"] == Message["From"] or checkPrivilege(
                                User["Fingerprint"], 10):
                            await broadcast(
                                json.dumps({
                                    "Type": "UI",
                                    "SubType": "Destroy",
                                    "Id": data["Id"],
                                    "From": User["Id"],
                                    "Channel": data["Channel"]
                                }))
                            del Message
                    except Exception:
                        pass
                if data["SubType"] == "Edit":
                    try:
                        User = client_data[websocket]
                        Message = getMessage(data["Channel"], data["Id"])
                        if User["Id"] == Message["From"]:
                            Message["Message"] = data["Message"]
                            await broadcast(
                                json.dumps({
                                    "Type": "UI",
                                    "SubType": "Edit",
                                    "Message": data["Message"],
                                    "Id": data["Id"],
                                    "Channel": data["Channel"]
                                }))
                    except Exception:
                        pass
                if data["SubType"] == "React":
                    try:
                        User = client_data[websocket]
                        Message = getMessage(data["Channel"], data["Id"])
                        if not data["Reaction"] in Message["Reactions"]:
                            Message["Reactions"][data["Reaction"]] = 1
                        else:
                            Message["Reactions"][data["Reaction"]] += 1
                        await broadcast(
                            json.dumps({
                                "Type": "UI",
                                "SubType": "React",
                                "FromId": User["Id"],
                                "MessageId": data["Id"],
                                "Reaction": data["Reaction"],
                                "Channel": data["Channel"]
                            }))
                    except Exception:
                        pass

                if data["SubType"] == "RevokeReact":
                    try:
                        User = client_data[websocket]
                        Message = getMessage(data["Channel"], data["Id"])

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
                                "Reaction": data["Reaction"],
                                "Channel": data["Channel"]
                            }))
                    except Exception:
                        pass
                if data["SubType"] == "Chat":
                    Channel = channels[data["Channel"]]
                    User = client_data[websocket]

                    data["Id"] = User["Id"]
                    data["Name"] = User["Name"]
                    data["Color"] = User["Color"]
                    data["MessageId"] = len(
                        Channel["Messages"]) == 0 and 1 or Channel["Messages"][
                            len(Channel["Messages"]) - 1]["Id"] + 1

                    isPrivate = "To" in data

                    Channel["Messages"].append({
                        "From":
                        User["Id"],
                        "Message":
                        not isPrivate and data["Message"] or "REDACTED",
                        "Id":
                        data["MessageId"],
                        "Channel":
                        data["Channel"],
                        "Reactions": {}
                    })
                    if not isPrivate:
                        if not ("Ranks" in Channel):
                            await broadcast(json.dumps(data))
                        else:
                            for Rank in Channel["Ranks"]:
                                await broadcast(json.dumps(data), rank=Rank)
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
    # except Exception as e:
    #     print(e)
    #     Id = client_data[websocket]["Id"]
    #     await broadcast(
    #         json.dumps({
    #             "Type": "Connection",
    #             "SubType": "Leave",
    #             "Id": Id
    #         }))
    #     Idx = 0
    #     for Json in message_logs:
    #         if Json["From"] == Id:
    #             message_logs.pop(Idx)
    #         Idx += 1
    #     del client_data[websocket]
    #     CLIENTS.remove(websocket)
    finally:
        # try:
        Id = client_data[websocket]["Id"]
        await broadcast(json.dumps({
            "Type": "Connection",
            "SubType": "Leave",
            "Id": Id
        }),
                        from_client=websocket)
        for Channel in channels:
            Idx = 0
            for Message in channels[Channel]["Messages"]:
                if Message["From"] == Id:
                    channels[Channel]["Messages"].pop(Idx)
            Idx += 1
        del client_data[websocket]
        # except Exception:
        # pass
        # finally:
        # try:
        CLIENTS.remove(websocket)
        # except Exception:
        #     pass


async def broadcast(message, from_client=None, rank=None):
    for websocket in CLIENTS.copy():
        try:
            if type(message) == dict:
              message = json.dumps(dict)
            if rank and not checkRank(client_data[websocket]["Fingerprint"], rank):
              continue
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
