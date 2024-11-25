--[[
    Events:
    Client Server communication manager. 

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
    
--]]

local RunService = game:GetService("RunService")
local RemoteEvent, RemoteFunction 

--[[ API Definitions ]]
local Handle = {
    _handles = {}
}

--[[ Handle Constructor
function Handle:Construct()
    local o = {}
    setmetatable(o, {__index = self})
    --
    o._handles = {}

    return o 
end
--]]

function Handle:New(Name : String, New : Callback)
    if self:Callback(Name) ~= nil then 
        warn(Name,"callback was overridden!")
    end
    self._handles[Name] = New 
end

function Handle:Callback(Name : String) : Callback 
    return self._handles[Name]
end

if RunService:IsServer() == true then 
    --[[ Server ]]

    function Handle:Run(Player : PlayerInstance, Name : String, ... : Args) : Any
        local _callback = self:Callback(Name)
        if _callback ~= nil then 
            return _callback(Player, ...)
        else 
            warn("[Server] No callback for",Name,"called by",Player,"with arguments",...)
        end
        --
        return nil -- Default
    end
    
    -- Remote Events 
    RemoteEvent = script:FindFirstChild("RemoteEvent") or Instance.new("RemoteEvent", script)
    
    -- Send events to clients
    function Handle:Set(Player : PlayerInstance, EventName : String, ... : Args)
        RemoteEvent:FireClient(Player, EventName, ...)        
    end
    
    -- Handle events from clients
    RemoteEvent.OnServerEvent:Connect(function(Player : PlayerInstance, Name : String, ... : Args)
        Handle:Run(Player, Name, ...)
    end)

    -- Remote Functions (Events with return parameters)
    RemoteFunction = script:FindFirstChild("RemoteFunction") or Instance.new("RemoteFunction", script)
    
    -- Get information from clients
    function Handle:Get(Player : PlayerInstance, FunctionName : String, ... : Args) : Any 
        return RemoteFunction:InvokeClient(Player, FunctionName, ...)
    end

    -- Handle requests from clients
    RemoteFunction.OnServerInvoke = function(Player : PlayerInstance, Name : String, ... : Args) : Any
        local result = Handle:Run(Player, Name, ...)
        if result == nil then 
            warn("[Server] Function",Name,"did not return any result (nil). If this is intentional, please ignore this message. Called by ",Player)
        end
        --
        return result 
    end

else 
    --[[ Client ]]

    function Handle:Run(Name : String, ... : Args) : Any
        local _callback = self:Callback(Name)
        if _callback ~= nil then 
            return _callback(...)
        else 
            warn("[Client] No callback for",Name,"with arguments",...)
        end
        --
        return nil -- Default
    end

    RemoteEvent = script:WaitForChild("RemoteEvent", 1)
    
    -- Send events to the server
    function Handle:Set(EventName : String, ... : Args)
        RemoteEvent:FireServer(EventName, ...)
    end

    -- Handle events from the server
    RemoteEvent.OnClientEvent:Connect(function(Name : String, ... : Args)
        Handle:Run(Name, ...)
    end)

    RemoteFunction = script:WaitForChild("RemoteFunction", 1)

    -- Send requests to the server
    function Handle:Get(FunctionName : String, ... : Args) : Any 
        return RemoteFunction:InvokeServer(FunctionName, ...)
    end
    
    -- Handle requests from the server
    RemoteFunction.OnClientInvoke = function(Name : String, ... : Args) : Any 
        local result = Handle:Run(Name, ...)
        if result == nil then 
            warn("[Client] Function",Name,"did not return any result (nil). If this is intentional, please ignore this message.")
        end
        --
        return result 
    end
end 

return Handle