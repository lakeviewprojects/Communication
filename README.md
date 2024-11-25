## API Documentation

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
    