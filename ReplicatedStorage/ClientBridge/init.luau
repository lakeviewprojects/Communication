--[[
    ClientBridge — Client-side cross-module communication singleton.

    Mirrors the Communication module pattern but for client-only calls.
    Modules register named callbacks; callers invoke by name.

    API:
        ClientBridge:Register(name, callback)   — Register a named handler
        ClientBridge:Invoke(name, ...) -> any    — Call a handler and return its result
        ClientBridge:Fire(name, ...)             — Call a handler, ignore return value
        ClientBridge:IsRegistered(name) -> bool  — Check if a handler exists
]]

local ClientBridge = {
    _handlers = {}
}

function ClientBridge:Register(Name: string, Callback: (...any) -> ...any)
    if self._handlers[Name] ~= nil then
        warn("[ClientBridge]", Name, "handler was overridden!")
    end
    self._handlers[Name] = Callback
end

function ClientBridge:Invoke(Name: string, ...: any): ...any
    local handler = self._handlers[Name]
    if handler ~= nil then
        return handler(...)
    else
        warn("[ClientBridge] No handler registered for", Name)
    end
    return nil
end

function ClientBridge:Fire(Name: string, ...: any)
    local handler = self._handlers[Name]
    if handler ~= nil then
        handler(...)
    else
        warn("[ClientBridge] No handler registered for", Name)
    end
end

function ClientBridge:IsRegistered(Name: string): boolean
    return self._handlers[Name] ~= nil
end

return ClientBridge
