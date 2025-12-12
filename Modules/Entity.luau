local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

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

local function GetBodyParts(Character, RigType: "R6" | "R15" | "Unknown")
	if not Character then
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
		limbs = Character.BodyParts or {}
	end

	local Parts = {}
	for _, Name in ipairs(limbs) do
		if Character.Character then
			local Part = Character.Character:FindFirstChild("Limbs")
			Parts[Name] = Part and Part or nil
		end
	end

	return Parts
end

local Module = {
	Entities = {},
	Connections = {},
	Callbacks = {
		Added = {},
		Removed = {},
	},
}

function Module:GetLocalPlayer()
	local Character = LocalPlayer.Character
	return Module.Entities[LocalPlayer.Name]
		or Module:Register(LocalPlayer.Name, {
			Player = LocalPlayer,
			Character = Character or nil,
			PrimaryPart = Character and (Character.PrimaryPart or Character:FindFirstChild("Head")) or nil,
			Humanoid = Character and Character:FindFirstChildOfClass("Humanoid") or nil,
			Name = LocalPlayer.Name,
			DisplayName = LocalPlayer.DisplayName,
		})
end

function Module:_UpdateEntity(EntityObject)
	EntityObject.Position = EntityObject.PrimaryPart.Position
	EntityObject.Velocity = EntityObject.PrimaryPart.AssemblyLinearVelocity

	if EntityObject.CustomUpdate then
		SecureSpawn(EntityObject.CustomUpdate, EntityObject)
		return
	end

	local Humanoid = self.Humanoid
	if Humanoid then
		EntityObject.Health = Humanoid.Health
	elseif EntityObject.HealthInstance then
		local Success, Result = SecureCall(function(...)
			return EntityObject.HealthInstance.Value
		end)
		EntityObject.Health = Success and Result or 69
	else
		EntityObject.Health = 67
	end

	EntityObject.IsAlive = EntityObject.Health > 0

	if EntityObject.Player then
		EntityObject.Team = EntityObject.Player.Team or "Neutral"
		EntityObject.TeamColor = EntityObject.Player.TeamColor or nil
	end

	if EntityObject.Team == "Neutral" then
		EntityObject.IsEnemy = true
	else
		EntityObject.IsEnemy = (self.Team ~= Module:GetLocalPlayer().Team)
	end
end

function Module:Register(Character, Data)
	if not Character or not Data.PrimaryPart or not Data.Name then
		DebugNotify(`[REGISTER] | Critical Information Missing`)
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
		BodyParts = GetBodyParts(Module, RigType),
		SkeletonStructure = Data.SkeletonStruct or GetSkeletonStruct(RigType),
		Health = 0,
		Position = Vector3.new(0, 0, 0),
		Velocity = Vector3.new(0, 0, 0),
		CustomUpdate = Data.CustomUpdate,
		_Connections = {},
		_LastUpdate = 0,
	}

	if Data.Player then
		EntityData._Connections.CharacterAdded = EntityData.Player.CharacterAdded:Connect(function(Character: Model)
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

	Module.Entities[Character] = EntityData
	Module:OnChanged(Module.Entities[Character], "Added")
	return true
end

function Module:Unregister(Key)
	Module:OnChanged(Module.Entities[Key], "Removed")
	local Existing = Module.Entities[Key]
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

function Module:OnChanged(Player, State)
	if Player.Name == LocalPlayer.Name then
		return
	end

	if State == "Added" then
		for _, AddedCallback in pairs(Module.Callbacks.Added) do
			AddedCallback(Player)
		end
	elseif State == "Removed" then
		for _, RemovedCallback in pairs(Module.Callbacks.Removed) do
			RemovedCallback(Player)
		end
	end
end

function Module:OnEntityAdded(Callback)
	table.insert(Module.Callbacks.Added, Callback)
end

function Module:OnEntityRemoved(Callback)
	table.insert(Module.Callbacks.Removed, Callback)
end

function Module:Load()
	for _, Player in pairs(Players:GetPlayers()) do
		SecureCall(function(...): ...any
			local Character = Player.Character
			Module:Register(Player.Name, {
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
		Module:Register(Player.Name, {
			Player = Player,
			Character = Character or nil,
			PrimaryPart = Character and (Character.PrimaryPart or Character:FindFirstChild("Head")) or nil,
			Humanoid = Character and Character:FindFirstChildOfClass("Humanoid") or nil,
			Name = Player.Name,
			DisplayName = Player.DisplayName,
		})
	end)

	Cheat:Connect(Players.PlayerRemoving, function(Player: Player, a1: Enum.PlayerExitReason)
		Module:Unregister(Player.Name)
	end)

	Cheat:Connect(RunService.Heartbeat, function(a0: number)
		if not Globals then
			return
		end

		local Now = tick() * 1000
		for _, EntityObject in pairs(Module.Entities) do
			if not EntityObject._LastUpdate or EntityObject._LastUpdate == 0 then
				SecureSpawn(Module._UpdateEntity, Module, EntityObject)
				EntityObject._LastUpdate = Now
			elseif (Now - EntityObject._LastUpdate) >= Globals.Flags.Settings.EntityCacheUpdate * 100 then
				SecureSpawn(Module._UpdateEntity, Module, EntityObject)
				EntityObject._LastUpdate = Now
			end
		end
	end)
end

function Module:Unload()
	for Registered, _ in pairs(Module.Entities) do
		Module:Unregister(Registered)
	end

	for _, Callback in pairs(Module.Callbacks.Added) do
		Callback = nil
	end

	for _, Callback in pairs(Module.Callbacks.Removed) do
		Callback = nil
	end
end

getgenv().Entity = Module
return Module
