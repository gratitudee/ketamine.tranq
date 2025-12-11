local Players = game:GetService("Players")
local Entity = {
	Entities = {},
}

function Entity:Load()
	Cheat:Connect(Players.PlayerAdded, function(Player: Player)
		print(`Registered {Player.Name}`)
	end)

	Cheat:Connect(Players.PlayerRemoving, function(Player: Player, a1: Enum.PlayerExitReason)
		print(`Unregistered {Player.Name}`)
	end)
end

function Entity:Unload() end

return Entity
