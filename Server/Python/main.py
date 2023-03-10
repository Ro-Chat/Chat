import asyncio
import websockets
import json
import requests
import bs4
import base64

from hashlib import sha256

CLIENTS = set()

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

def getExtras(message):
    ret = {
      "Extras" : {},
      "Images": {}
    }
    if "http" in message:
        for link in message.split("http"):
            link = "http" + link.split(" ")[0]

            if not ("://" in link):
                continue

            response = requests.get(link, stream = True)
            response.raw.decode_content = True

            with response.raw as res:
              buffer = res.read()
              if buffer[:1] != b"<" and buffer[:1] != b"\r" and buffer[:1] != b"\n":
                ret["Images"][link] = base64.encodebytes(buffer).decode("utf-8")
                continue

            ret["Extras"][link] = {}
            
            soup = bs4.BeautifulSoup(buffer.decode("utf-8"), "lxml")

            for meta in soup.find_all("meta"):
                name = "name" in meta.attrs and meta.attrs[
                    "name"] or "property" in meta.attrs and meta.attrs[
                        "property"]
                content = "content" in meta.attrs and meta.attrs["content"]
                if name == "og:image":
                  with requests.get(content, stream = True).raw as request:
                    image = base64.encodebytes(request.read()).decode("utf-8")
                    
                    if len(image) > 4000000:
                      image = "Exceeds 4MB size"
                      
                    ret["Extras"][link][name] = image
                  continue
                
                ret["Extras"][link][name] = content

    return ret


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
        if "Fingerprints" in channels[Channel]:
            for Fingerprint in channels[Channel]["Fingerprints"]:
                if fingerprint == Fingerprint:
                    Channels[Channel] = Channels[Channel]
        if "Ranks" in channels[Channel]:
            for Rank in channels[Channel]["Ranks"]:
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
            ret = client_data[Client]["Id"] + 1

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
                    if len(data["Bin"]) < 2000000:
                        if websocket in client_data:
                            client_data[websocket]["Image"] = data["Bin"]
                    else:
                        await websocket.send(
                            "{\"Error\": \"Profile image exceeds maximimum size of 2MB.\"}"
                        )

            # if data["Type"] == "Group":
            # if data["SubType"] == "Create":
            # if data["SubType"] == "Add":
            # if data["SubType"] == "Remove":
            # if data["SubType"] == "Kick":
            if data["Type"] == "Connection":
                if data["SubType"] == "Leave":
                    return
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
                        newId(),
                    }
                    metadata = getMetadata()
                    temp = [
                        {
                            "Name":
                            client_data[client]["Name"],
                            "Color":
                            client_data[client]["Color"],
                            "Fingerprint":
                            sha256(client_data[client]
                                   ["Fingerprint"].encode()).hexdigest(),
                            "Id":
                            client_data[client]["Id"]
                        } for client in client_data
                    ]
                    send = {
                        "Type":
                        "Connection",
                        "SubType":
                        "Info",
                        "Id":
                        client_data[websocket]["Id"],
                        "Players":
                        temp,
                        "Metadata":
                        metadata,
                        "Key":
                        websocket.request_headers.get_all(
                            "Sec-WebSocket-Accept"),
                        "Channels":
                        getChannels(client_data[websocket]["Fingerprint"])
                    }
                    await websocket.send(json.dumps(send))
                    data["Fingerprint"] = sha256(
                        bytes(data["Fingerprint"].encode())).hexdigest()
                    data["Id"] = client_data[websocket]["Id"]
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
                    send = {}

                    send["Type"] = "UI"
                    send["SubType"] = "Chat"
                    send["Id"] = User["Id"]
                    send["Name"] = User["Name"]
                    send["Color"] = User["Color"]
                    send["Image"] = User["Image"]
                    send["Message"] = data["Message"]
                    send["Channel"] = data["Channel"]

                    send["MessageId"] = len(
                        Channel["Messages"]) == 0 and 1 or Channel["Messages"][
                            len(Channel["Messages"]) - 1]["Id"] + 1

                    Channel["Messages"].append({
                        "From": User["Id"],
                        "Name": send["Name"],
                        "Image": send["Image"],
                        "Color": send["Color"],
                        "Message": send["Message"],
                        "Id": send["MessageId"],
                        "MessageId": send["MessageId"],
                        "Channel": send["Channel"],
                        "Reactions": {}
                    })
                    if not ("Ranks" in Channel) and not ("Fingerprints"
                                                         in Channel):
                        await broadcast(json.dumps(send))
                        extras = getExtras(data["Message"])
                        extras["Type"] = "UI"
                        extras["SubType"] = "ChatExtra"
                        extras["MessageId"] =  send["MessageId"]
                        extras["Channel"] = send["Channel"]
                  
                        await broadcast(json.dumps(extras))
                    else:
                        if "Ranks" in Channel:
                            extras = {
                              "Extras": getExtras(data["Message"]),
                              "Type": "UI",
                              "SubType": "ChatExtra",
                              "MessageId": send["MessageId"],
                              "Channel": send["Channel"]
                            }
                            for Rank in Channel["Ranks"]:
                                await broadcast(json.dumps(send), rank=Rank)
                                await broadcast(json.dumps(extras), rank=Rank)
                        else:
                            await broadcast(
                                json.dumps(send),
                                fingerprints=Channel["Fingerprints"])
                            extras = {
                              "Extras": getExtras(data["Message"]),
                              "Type": "UI",
                              "SubType": "ChatExtra",
                              "MessageId": send["MessageId"],
                              "Channel": send["Channel"]
                            }
                            await broadcast(
                                json.dumps(extras),
                                fingerprints=Channel["Fingerprints"])
            pass
    finally:
        if websocket in client_data:
            Id = client_data[websocket]["Id"]
            for Channel in channels:
                for Idx in range(
                        len(channels[Channel]["Messages"]) - 1, -1, -1):
                    if channels[Channel]["Messages"][Idx]["From"] == Id:
                        channels[Channel]["Messages"].pop(Idx)
            await broadcast(json.dumps({
                "Type": "Connection",
                "SubType": "Leave",
                "Id": Id
            }), from_client=websocket)
            del client_data[websocket]
        CLIENTS.remove(websocket)


async def broadcast(message, from_client=None, rank=None):
    for websocket in CLIENTS.copy():
        try:
            if type(message) == dict:
                message = json.dumps(dict)
            try:
                if rank and not checkRank(
                        client_data[websocket]["Fingerprint"], rank):
                    continue
            except Exception:
                pass
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
