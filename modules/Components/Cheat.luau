local Workspace: Workspace = game:GetService("Workspace")
local Camera = Workspace:FindFirstChildOfClass("Camera")

local Component = {
	UnloadCallbacks = {},
	Connections = {},
}

--[[
	World to screen 
	returns screenpos, onscreen
]]
function Component:WorldToScreen(WorldPosition: Vector3)
	local ScreenPos, OnScreen = Camera:WorldToViewportPoint(WorldPosition)
	return ScreenPos, OnScreen
end

--[[ 
    adds a connection to the cheat, allowing for later cleanup if the cheat is unloaded.
    returns an index for runtime cleanup.
]]
function Component:Connect(ConnectionType, Function)
	if typeof(ConnectionType) ~= "RBXScriptSignal" then
		Ketamine:Notify({
			Title = "!",
			Description = "Cheat:Connect(...) Called With Invalid Arguments",
		})
		return
	end

	if typeof(Function) ~= "function" then
		return
	end

	local Connection, Index = ConnectionType:Connect(Function), #self.Connections + 1
	self.Connections[Index] = Connection
	return Index
end

-- disconnects a connection using an idx returned from Cheat:Connect(...)
function Component:Disconnect(ConnectionIndex)
	local Connection = self.Connections[ConnectionIndex]
	if Connection and typeof(Connection) == "RBXScriptConnection" and Connection.Connected then
		Connection:Disconnect()
		self.Connections[ConnectionIndex] = nil
	end
end

-- adds a function to run when Cheat:Unload() is ran.
function Component:OnUnload(Callback)
	table.insert(self.UnloadCallbacks, Callback)
end

-- this is just here to be here..
function Component:Load() end

--[[ 
    fully cleans up the cheat, cleaning up all connections made by Cheat:Connect(...) 
    and running the unload callbacks
]]
function Component:Unload()
	for _, UnloadCallback in pairs(self.UnloadCallbacks) do
		UnloadCallback()
	end
	table.clear(self.UnloadCallbacks)

	for Index, _ in pairs(self.Connections) do
		self:Disconnect(Index)
	end
	table.clear(self.Connections)
end

return Component
