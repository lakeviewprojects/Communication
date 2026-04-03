# Communication

Client–server communication manager and client-side cross-module bridge. Contains two modules:

| Module | Roblox Path | Purpose |
|--------|------------|---------|
| **Communication** | `ReplicatedStorage.Communication` | Client ↔ Server RemoteEvent / RemoteFunction wrapper |
| **ClientBridge** | `ReplicatedStorage.Communication.ClientBridge` | Client-only cross-module named callback registry |

## File Structure

```
Communication/
├── README.md
└── ReplicatedStorage/
    ├── init.luau                  # Communication module (RemoteEvent/RemoteFunction)
    └── ClientBridge/
        └── init.luau              # ClientBridge module (client-only callbacks)
```

## Rojo Setup

```json
"ReplicatedStorage": {
    "$ignoreUnknownInstances": true,

    "Communication": {
        "$path": "submodules/Communication/ReplicatedStorage/"
    }
}
```

Both modules live under one Rojo entry. Consumers require them as:

```lua
-- Communication (client ↔ server)
local Communication = require(ReplicatedStorage:WaitForChild("Communication"))

-- ClientBridge (client-only)
local ClientBridge = require(ReplicatedStorage:WaitForChild("Communication"):WaitForChild("ClientBridge"))
```

---

## Communication API

Simple client–server communication wrapper around a single `RemoteEvent` and a single `RemoteFunction`.

### Generic

```lua
-- Register a named callback (server or client)
Communication:New(Name: string, Callback: function)
```

### Server

```lua
-- Call a handler locally on the server
Communication:Run(Player, Name, ...)

-- Fire an event to a specific client
Communication:Set(Player, EventName, ...)

-- Invoke a client and wait for its return value
Result = Communication:Get(Player, FunctionName, ...)
```

### Client

```lua
-- Call a handler locally on the client
Communication:Run(Name, ...)

-- Fire an event to the server
Communication:Set(EventName, ...)

-- Invoke the server and wait for its return value
Result = Communication:Get(FunctionName, ...)
```

### Example — Ping

**Server:**
```lua
local Communication = require(ReplicatedStorage:WaitForChild("Communication"))

Communication:New("Ping", function(Player, TimeOnClient)
    local ping = tick() - TimeOnClient
    print("Ping for", Player, "is", ping, "ms")
    return ping
end)
```

**Client:**
```lua
local Communication = require(ReplicatedStorage:WaitForChild("Communication"))

Communication:Set("Ping", tick())

-- OR with return value:
local result = Communication:Get("Ping", tick())
print("Got", result, "ms")
```

---

## ClientBridge API

Client-side cross-module communication singleton. Allows different client scripts (ScreenGuis, apps) to register and invoke named handlers without direct require dependencies.

### `ClientBridge:Register(name, callback)`
Register a named handler. Warns if overwriting an existing handler.

### `ClientBridge:Invoke(name, ...) -> any`
Call a registered handler and return its result. Warns if no handler is registered.

### `ClientBridge:Fire(name, ...)`
Call a registered handler without waiting for a return value.

### `ClientBridge:IsRegistered(name) -> boolean`
Check if a handler exists for the given name.

### Example

**Registering (in Monetization2):**
```lua
local ClientBridge = require(ReplicatedStorage:WaitForChild("Communication"):WaitForChild("ClientBridge"))

ClientBridge:Register("LikeAndJoinAPI", function()
    return LikeAndJoinAPI
end)
```

**Consuming (in Rewards2):**
```lua
local ClientBridge = require(ReplicatedStorage:WaitForChild("Communication"):WaitForChild("ClientBridge"))

if ClientBridge:IsRegistered("LikeAndJoinAPI") then
    local api = ClientBridge:Invoke("LikeAndJoinAPI")
    api:Open()
end
```

### Known Handlers

| Handler | Registered by | Consumed by | Description |
|---------|--------------|-------------|-------------|
| `LikeAndJoinAPI` | Monetization2 | Rewards2, Monetization2 | Returns the Like & Join prompt API |
| `InspectorOpen` | Inspector | Inspector (prompts) | Opens the Inspector panel for a target player |
| `DetentionOpen` | Detention | Inspector | Opens the Detention UI for a target player |
