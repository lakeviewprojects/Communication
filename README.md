## API Documentation

This is a really simple client server communication manager implementation. 

Generic API: 

- Create a callback handler
Handle:New(Name : String, Callback : Function? Event?)


Server API: 

Call an event locally (on server)
Handle:Run(EventName? FunctionName?, arg1, arg2, arg3, arg..., argn)

- Send an event to a player 
Handle:Set(PlayerInstance, EventName, arg1, arg2, arg3, arg..., argn)

- Send and receive a request to a player
Result = Handle:Get(PlayerInstance, FunctionName, arg1, arg2, arg3, arg..., argn)


Client API: 

Call an event locally (on cient)
Handle:Run(EventName? FunctionName?, arg1, arg2, arg3, arg..., argn)

- Send an event to the server
Handle:Set(EventName, arg1, arg2, arg3, arg..., argn)

- Send and receive a request to the server
Result = Handle:Get(FunctionName, arg1, arg2, arg3, arg..., argn)


## Usage Examples

### Ping
Server: 

```lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Communication = require(ReplicatedStorage:FindFirstChild("Communication"))

Communication:New("Ping", function(Player, TimeOnClient)
    local ping = tick()-TimeOnClient
    print("Ping for", Player,"is ",ping,"ms")
    --
    return ping --- This way it can also be used as a RemoteEvent response but doesnt need to be
end)

```

Client:

```lua 
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Communication = require(ReplicatedStorage:WaitForChild("Communication"))

Communication:Set("Ping", tick())

-- OR 

local result = Communication:Get("Ping", tick())
print("Got",result,"ms")

```

### Rojo file

```json
"ReplicatedStorage": {
    "$ignoreUnknownInstances": true,

    "Communication": {
        "$ignoreUnknownInstances": true,
        "$path":"Communication/ReplicatedStorage/"
    },

    "$path": {
        "$ignoreUnknownInstances": true,
        "$path":"src/ReplicatedStorage/"
    }
}
