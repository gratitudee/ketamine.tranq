local Players = game:GetService("Players")
local Entity = {
	Entities = {},
}

function Entity:Load()
	for _, Player in pairs(Players:GetPlayers()) do
		SecureCall(function(...): ...any
			print(`Registered existing player {Player.Name}`)
		end)
	end

	Cheat:Connect(Players.PlayerAdded, function(Player: Player)
		print(`Registered {Player.Name}`)
	end)

	Cheat:Connect(Players.PlayerRemoving, function(Player: Player, a1: Enum.PlayerExitReason)
		print(`Unregistered {Player.Name}`)
	end)
end

function Entity:Unload() end

return Entity
