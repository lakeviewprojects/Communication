--[[
    Events:
    Client Server communication manager. 

--]]

local RunService = game:GetService("RunService")

local RemoteEvent, RemoteFunction 

--[[ API Definitions ]]
local Handle = {}

function Handle:Construct()
    local o = {}
    setmetatable(o, {__index = self})
    --
    o._handles = {}

    return o 
end

function Handle:New(Name : String, New : Callback)
    self._handles[Name] = New 
end

function Handle:Get(Name : String) : Callback 
    return self._handles[Name]
end

if RunService:IsServer() == true then 
    --[[ Server ]]

    function Handle:Run(Player : PlayerInstance, Name : String, ... : Args) : Any
        local _callback = self:Get(Name)
        if _callback ~= nil then 
            return _callback(Player, ...)
        else 
            warn("[Server] No callback for",Name,"Called by",Player,"with arguments",...)
        end
        --
        return nil -- Default
    end
    --
    local Event,Function = Handle:Construct(), Handle:Construct()

    -- Remote Events 
    RemoteEvent = script:FindFirstChild("RemoteEvent") or Instance.new("RemoteEvent", script)
    
    -- Send events to clients
    function Handle:Set(Player : PlayerInstance, EventName : String, ... : Args)
        RemoteEvent:FireClient(Player, EventName, ...)        
    end
    
    -- Handle events from clients
    RemoteEvent.OnServerEvent:Connect(function(Player : PlayerInstance, Event : String, ... : Args)
        Event:Run(Player, Event, ...)
    end)

    -- Remote Functions (Events with return parameters)
    RemoteFunction = script:FindFirstChild("RemoteFunction") or Instance.new("RemoteFunction", script)
    
    -- Get information from clients
    function Handle:Get(Player : PlayerInstance, FunctionName : String, ... : Args) : Any 
        return RemoteFunction:InvokeClient(Player, FunctionName, ...)
    end

    -- Handle requests from clients
    RemoteFunction.OnServerInvoke = function(Player : PlayerInstance, Function : String, ... : Args) : Any
        local result = Function:Run(Player, Function, ...)
        if result == nil then 
            warn("[Server] Function",Function,"did not return any result (nil). If this is intentional, please ignore this message. Called by ",Player)
        end
        --
        return result 
    end

else 
    --[[ Client ]]

    function Handle:Run(Name : String, ... : Args) : Any
        local _callback = self:Get(Name)
        if _callback ~= nil then 
            return _callback(...)
        else 
            warn("[Client] No callback for",Name,"with arguments",...)
        end
        --
        return nil -- Default
    end

    --
    local Event,Function = Handle:Construct(), Handle:Construct()

    RemoteEvent = script:WaitForChild("RemoteEvent", 1)
    
    -- Send events to the server
    function Handle:Set(EventName : String, ... : Args)
        RemoteEvent:FireServer(EventName, ...)
    end

    -- Handle events from the server
    RemoteEvent.OnClientEvent:Connect(function(Event : String, ... : Args)
        Event:Run(Event, ...)
    end)

    RemoteFunction = script:WaitForChild("RemoteFunction", 1)

    -- Send requests to the server
    function Handle:Get(FunctionName : String, ... : Args) : Any 
        return RemoteFunction:InvokeServer(FunctionName, ...)
    end
    
    -- Handle requests from the server
    RemoteFunction.OnClientInvoke = function(Function : String, ... : Args) : Any 
        local result = Function:Run(Function, ...)
        if result == nil then 
            warn("[Client] Function",Function,"did not return any result (nil). If this is intentional, please ignore this message. Called by ",Player)
        end
        --
        return result 
    end
end 

return Handle