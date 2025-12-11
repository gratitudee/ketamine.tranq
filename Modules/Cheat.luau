local Cheat = {}

function Cheat:Connect(ConnectionType, Callback)
	local Connection = ConnectionType:Connect(Callback)
	Globals.Connections[#Globals.Connections + 1] = Connection
	return Connection
end

function Cheat:Load() end
function Cheat:Unload() end

getgenv().Cheat = Cheat
return Cheat
