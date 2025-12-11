local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Cheat = require("./Cheat")
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
	if not character then
		return "Unknown"
	end

	if character:FindFirstChild("UpperTorso") then
		return "R15"
	elseif character:FindFirstChild("Torso") then
		return "R6"
	end
	return "Unknown"
end

local function GetSkeletonStruct(RigType)
	return DefaultSkeletons[RigType] or nil
end

local function GetBodyParts(Entity, RigType: "R6" | "R15" | "Unknown")
	if not Entity then
		return nil
	end

	local limbs = nil
	if RigType == "R6" then
		limbs = {
			"Head",
			"Torso",
			"Left Arm",
			"Right Arm",
			"Left Leg",
			"Right Leg",
		}
	elseif RigType == "R15" then
		limbs = {
			"Head",
			"UpperTorso",
			"LowerTorso",
			"LeftUpperArm",
			"LeftLowerArm",
			"LeftHand",
			"RightUpperArm",
			"RightLowerArm",
			"RightHand",
			"LeftUpperLeg",
			"LeftLowerLeg",
			"LeftFoot",
			"RightUpperLeg",
			"RightLowerLeg",
			"RightFoot",
		}
	elseif RigType == "Unknown" then
		limbs = Entity.BodyParts or {}
	end

	local Parts = {}
	for _, Name in ipairs(limbs) do
		if Entity.Character then
			local Part = Entity.Character:FindFirstChild("Limbs")
			Parts[Name] = Part and Part or nil
		end
	end

	return Parts
end

local Entity = {
	Entities = {},
	Connections = {},
}

function Entity:_UpdateEntity(EntityObject)
	EntityObject._LastUpdate = tick()
	EntityObject.Position = EntityObject.PrimaryPart.Position
	EntityObject.Velocity = EntityObject.PrimaryPart.AssemblyLinearVelocity

	if not EntityObject.CustomUpdate then
		local Humanoid = self.Humanoid
		if Humanoid then
			EntityObject.Health = Humanoid.Health
		elseif EntityObject.HealthInstance then
			local Success, R = pcall(function(...)
				return EntityObject.HealthInstance.Value
			end)
			EntityObject.Health = Success and R or 69
		else
			EntityObject.Health = 67
		end

		EntityObject.IsAlive = EntityObject.Health > 0

		if EntityObject.Player then
			EntityObject.Team = EntityObject.Player.Team or "Neutral"
			EntityObject.TeamColor = EntityObject.Player.TeamColor or nil
		end
	end

	SecureSpawn(EntityObject.CustomUpdate, EntityObject)
end

function Entity:Register(Character, Data)
	if not Character or not Data.PrimaryPart or not Data.Name then
		return false
	end

	local RigType = GetRigType(Data.Character)
	local EntityData = {
		Character = Data.Character,
		PrimaryPart = Data.PrimaryPart,
		Team = Data.Team or (Data.Player and Data.Player.Team) or "Neutral",
		TeamColor = Data.TeamColor or (Data.Player and Data.Player.Team) or nil,
		Player = Data.Player,
		Name = Data.Name,
		DisplayName = Data.DisplayName or Data.Name,
		BodyParts = GetBodyParts(Entity, RigType),
		SkeletonStructure = Data.SkeletonStruct or GetSkeletonStruct(RigType),
		Health = 0,
		Position = Vector3.new(0, 0, 0),
		Velocity = Vector3.new(0, 0, 0),
		CustomUpdate = Data.CustomUpdate,
		_Connections = {},
		_LastUpdate = 0,
	}

	if Data.Player then
		EntityData._Connections = EntityData.Player.CharacterAdded:Connect(function(Character: Model)
			task.delay(0.5, function()
				local NewRigType = GetRigType(Character)
				EntityData.Character = Character
				EntityData.PrimaryPart = Character.PrimaryPart or Character:FindFirstChild("Head")
				EntityData.BodyParts = GetBodyParts(EntityData, NewRigType)
				EntityData.SkeletonStructure = GetSkeletonStruct(NewRigType)
				EntityData.Position = Vector3.new(0, 0, 0)
				EntityData.Velocity = Vector3.new(0, 0, 0)
				EntityData._LastUpdate = 0
			end)
		end)
	end

	Entity.Entities[Character] = EntityData
	return true
end

function Entity:Unregister(Key)
	local Existing = Entity.Entities[Key]
	if not Existing then
		return
	end

	for _, Connection in pairs(Existing._Connections) do
		pcall(function(...)
			Connection:Disconnect()
			Connection = nil
		end)
	end
end

function Entity:Load()
	for _, Player in pairs(Players:GetPlayers()) do
		SecureCall(function(...): ...any
			local Character = Player.Character
			Entity:Register(Player.Name, {
				Player = Player,
				Character = Character or nil,
				PrimaryPart = Character and (Character.PrimaryPart or Character:FindFirstChild("Head")) or nil,
				Humanoid = Character and Character:FindFirstChildOfClass("Humanoid") or nil,
				Name = Player.Name,
				DisplayName = Player.DisplayName,
			})
		end)
	end

	Cheat:Connect(Players.PlayerAdded, function(Player: Player)
		local Character = Player.Character
		Entity:Register(Player.Name, {
			Player = Player,
			Character = Character or nil,
			PrimaryPart = Character and (Character.PrimaryPart or Character:FindFirstChild("Head")) or nil,
			Humanoid = Character and Character:FindFirstChildOfClass("Humanoid") or nil,
			Name = Player.Name,
			DisplayName = Player.DisplayName,
		})
	end)

	Cheat:Connect(Players.PlayerRemoving, function(Player: Player, a1: Enum.PlayerExitReason)
		Entity:Unregister(Player.Name)
	end)

	Cheat:Connect(RunService.Heartbeat, function(a0: number)
		local Now = tick() * 1000
		for _, EntityObject in pairs(Entity.Entities) do
			if (Now - EntityObject._LastUpdate * 1000) >= Globals.Flags.EntityCacheUpdate * 1000 then
				SecureSpawn(Entity._UpdateEntity, EntityObject)
				EntityObject._LastUpdate = Now
			end
		end
	end)
end

function Entity:Unload() end

return Entity
