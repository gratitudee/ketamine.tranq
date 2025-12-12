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

local CubeCorners = {
	Vector3.new(0, -1, -1),
	Vector3.new(0, -1, 1),
	Vector3.new(0, 1, -1),
	Vector3.new(0, 1, 1),
}

-- Utilities
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

local function GetBodyPartNames(character, RigType)
	if not character then
		return {}
	end
	if RigType == "R6" then
		return { "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg" }
	elseif RigType == "R15" then
		return {
			"Head",
			"UpperTorso",
			"LowerTorso",
			"HumanoidRootPart",
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
	else
		return character.BodyParts or {}
	end
end

local function GetBones(character, bodyParts)
	local parts = {}
	for _, name in ipairs(bodyParts) do
		parts[name] = character:FindFirstChild(name)
	end
	return parts
end

local function GetSkeletonBones(bonesTable, skeletonStruct)
	local skeletonBones = {}
	if not bonesTable or not skeletonStruct then
		return {}
	end
	for _, pair in ipairs(skeletonStruct) do
		local partA = bonesTable[pair[1]]
		local partB = bonesTable[pair[2]]
		if partA and partB then
			table.insert(skeletonBones, { partA, partB })
		end
	end
	return skeletonBones
end

local ECS = {
	Entities = {},
	Components = {
		Character = {},
		PrimaryPart = {},
		Humanoid = {},
		Health = {},
		Position = {},
		Velocity = {},
		Team = {},
		TeamColor = {},
		BodyParts = {},
		Bones = {},
		Skeleton = {},
		BoundingBox = {},
		IsAlive = {},
		IsEnemy = {},
		CustomUpdate = {},
		Player = {},
		LastUpdate = {},
		DisplayName = {},
		Name = {},
	},
	Callbacks = { Added = {}, Removed = {} },
}

function ECS:GetEntityView(id)
	return setmetatable({ id = id, ECS = self }, {
		__index = function(t, key)
			local comp = t.ECS.Components[key]
			if comp then
				return comp[id]
			end
			return nil
		end,
		__newindex = function(t, key, value)
			local comp = t.ECS.Components[key]
			if comp then
				comp[id] = value
			else
				rawset(t, key, value)
			end
		end,
	})
end

function ECS:CalculateBoundingBox(id)
	local C = self.Components
	local primary = C.PrimaryPart[id]
	if not primary then
		return nil
	end

	local _, onScreen1 = Utility:WorldToScreen(primary.Position)
	if not onScreen1 then
		return nil
	end

	local bones = C.Bones[id]
	if not bones or not next(bones) then
		return nil
	end

	local minX, minY = math.huge, math.huge
	local maxX, maxY = -math.huge, -math.huge
	local foundVisible = false

	for _, part in pairs(bones) do
		if part and part:IsA("BasePart") then
			local cf = part.CFrame
			local halfSize = part.Size * 0.5

			for _, corner in ipairs(CubeCorners) do
				local worldPos = cf:PointToWorldSpace(halfSize * corner)
				local screenPos, onScreen = Utility:WorldToScreen(worldPos)
				if onScreen then
					foundVisible = true
					minX = math.min(minX, screenPos.X)
					maxX = math.max(maxX, screenPos.X)
					minY = math.min(minY, screenPos.Y)
					maxY = math.max(maxY, screenPos.Y)
				end
			end
		end
	end

	if not foundVisible then
		return nil
	end

	local width = maxX - minX
	local height = maxY - minY
	local padX = width * 0.15
	local padY = height * 0.1

	local box = {
		X = minX - padX,
		Y = minY - padY,
		W = width + padX * 2,
		H = height + padY * 2,
	}

	return box
end

function ECS:Register(id, data)
	if not data.Player then
		if not data.Character or not data.PrimaryPart or not data.Name then
			return
		end
	end

	local rigType = GetRigType(data.Character)
	local C = self.Components
	C.Character[id] = data.Character or nil
	C.PrimaryPart[id] = data.PrimaryPart or (data.Character and data.Character:FindFirstChild("Head"))
	C.Humanoid[id] = data.Humanoid or (data.Character and data.Character:FindFirstChildOfClass("Humanoid"))
	C.Team[id] = data.Team or (data.Player and data.Player.Team) or "Neutral"
	C.TeamColor[id] = data.TeamColor or (data.Player and data.Player.TeamColor)
	C.Player[id] = data.Player or nil
	C.CustomUpdate[id] = data.CustomUpdate or nil
	C.Name[id] = data.Name
	C.DisplayName[id] = data.DisplayName or data.Name
	C.Health[id] = 0
	C.Position[id] = Vector3.new(0, 0, 0)
	C.Velocity[id] = Vector3.new(0, 0, 0)
	C.LastUpdate[id] = 0
	C.BodyParts[id] = GetBodyPartNames(data.Character, rigType)
	C.Bones[id] = GetBones(data.Character, C.BodyParts[id])
	C.Skeleton[id] = GetSkeletonBones(C.Bones[id], GetSkeletonStruct(rigType))
	C.BoundingBox[id] = ECS:CalculateBoundingBox(id)
	C.IsAlive[id] = true
	C.IsEnemy[id] = false

	if data.Player then
		data.Player.CharacterAdded:Connect(function(char)
			task.delay(0.5, function()
				C.Character[id] = char
				C.PrimaryPart[id] = char.PrimaryPart or char:FindFirstChild("Head")
				C.Humanoid[id] = char:FindFirstChildOfClass("Humanoid")

				local rigType = GetRigType(char)
				C.BodyParts[id] = GetBodyPartNames(char, rigType)
				C.Bones[id] = GetBones(char, C.BodyParts[id])
				C.Skeleton[id] = GetSkeletonBones(C.Bones[id], GetSkeletonStruct(rigType))
				C.BoundingBox[id] = ECS:CalculateBoundingBox(id)

				C.Position[id] = Vector3.new(0, 0, 0)
				C.Velocity[id] = Vector3.new(0, 0, 0)
				C.LastUpdate[id] = 0
			end)
		end)
	end

	table.insert(self.Entities, id)
	self:TriggerCallbacks(id, "Added")
end

function ECS:Unregister(id)
	self:TriggerCallbacks(id, "Removed")
	local C = self.Components
	for _, comp in pairs(C) do
		comp[id] = nil
	end
	for i, eid in ipairs(self.Entities) do
		if eid == id then
			table.remove(self.Entities, i)
			break
		end
	end
end

-- Callbacks
function ECS:OnEntityAdded(fn)
	table.insert(self.Callbacks.Added, fn)
end
function ECS:OnEntityRemoved(fn)
	table.insert(self.Callbacks.Removed, fn)
end
function ECS:TriggerCallbacks(id, state)
	local view = self:GetEntityView(id)
	if state == "Added" then
		for _, fn in pairs(self.Callbacks.Added) do
			fn(view)
		end
	elseif state == "Removed" then
		for _, fn in pairs(self.Callbacks.Removed) do
			fn(view)
		end
	end
end

function ECS:UpdateEntity(id)
	local C = self.Components
	local now = tick() * 1000
	if C.LastUpdate[id] and (now - C.LastUpdate[id]) < (Globals.Flags.Settings.EntityCacheUpdate or 100) then
		return
	end

	local primary = C.PrimaryPart[id]
	if primary then
		C.Position[id] = primary.Position
		C.Velocity[id] = primary.AssemblyLinearVelocity
	end

	local humanoid = C.Humanoid[id]
	if humanoid then
		C.Health[id] = humanoid.Health
	elseif C.Health[id] == nil then
		C.Health[id] = 0
	end

	C.IsAlive[id] = (C.Health[id] > 0)

	local playerTeam = C.Player[id] and C.Player[id].Team or "Neutral"
	C.Team[id] = playerTeam
	C.TeamColor[id] = C.Player[id] and C.Player[id].TeamColor or nil
	C.IsEnemy[id] = (playerTeam ~= self.Components.Team[LocalPlayer.Name])
	C.BoundingBox[id] = self:CalculateBoundingBox(id)

	local fn = C.CustomUpdate[id]
	if fn then
		SecureCall(fn, self:GetEntityView(id))
	end

	C.LastUpdate[id] = now
end

function ECS:UpdateAll()
	for _, id in ipairs(self.Entities) do
		self:UpdateEntity(id)
	end
end

function ECS:GetLocalPlayer()
	return self:GetEntityView(LocalPlayer.Name)
end

function ECS:Load()
	for _, player in ipairs(Players:GetPlayers()) do
		self:Register(player.Name, {
			Player = player,
			Character = player.Character,
			Humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid"),
			PrimaryPart = player.Character
				and (player.Character.PrimaryPart or player.Character:FindFirstChild("Head")),
			Name = player.Name,
			DisplayName = player.DisplayName,
		})
	end

	Cheat:Connect(Players.PlayerAdded, function(player)
		self:Register(player.Name, {
			Player = player,
			Character = player.Character,
			Humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid"),
			PrimaryPart = player.Character
				and (player.Character.PrimaryPart or player.Character:FindFirstChild("Head")),
			Name = player.Name,
			DisplayName = player.DisplayName,
		})
	end)

	Cheat:Connect(Players.PlayerRemoving, function(a0: Player, a1: Enum.PlayerExitReason)
		self:Unregister(a0.Name)
	end)

	Cheat:Connect(RunService.Heartbeat, function(a0: number)
		self:UpdateAll()
	end)
end

function ECS:Unload()
	for _, id in ipairs(self.Entities) do
		self:Unregister(id)
	end
	self.Callbacks.Added = {}
	self.Callbacks.Removed = {}
end

getgenv().Entity = ECS
return ECS
