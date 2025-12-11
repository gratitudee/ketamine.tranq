local Players = game:GetService("Players")
local DefaultSkeletons = {
	["R6"] = {
		{ "Head", "Torso" },
		{ "Torso", "Left Arm" },
		{ "Torso", "Right Arm" },
		{ "Torso", "Left Leg" },
		{ "Torso", "Right Leg" },
	},
	["R15"] = {
		{ "Head", "UpperTorso" },
		{ "UpperTorso", "LowerTorso" },
		{ "LowerTorso", "HumanoidRootPart" },
		{ "UpperTorso", "LeftUpperArm" },
		{ "LeftUpperArm", "LeftLowerArm" },
		{ "LeftLowerArm", "LeftHand" },
		{ "UpperTorso", "RightUpperArm" },
		{ "RightUpperArm", "RightLowerArm" },
		{ "RightLowerArm", "RightHand" },
		{ "LowerTorso", "LeftUpperLeg" },
		{ "LeftUpperLeg", "LeftLowerLeg" },
		{ "LeftLowerLeg", "LeftFoot" },
		{ "LowerTorso", "RightUpperLeg" },
		{ "RightUpperLeg", "RightLowerLeg" },
		{ "RightLowerLeg", "RightFoot" },
	},
}

local function GetRigType(character)
	if character:FindFirstChild("UpperTorso") then
		return "R15"
	elseif character:FindFirstChild("Torso") then
		return "R6"
	end
	return "Unknown"
end

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
