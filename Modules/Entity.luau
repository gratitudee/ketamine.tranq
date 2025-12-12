local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local DefaultSkeletons = {
	["R6"] = {
		{ "Head", "Torso", "top" },
		{ "Torso", "Left Arm", "left_shoulder" },
		{ "Torso", "Right Arm", "right_shoulder" },
		{ "Torso", "Left Leg", "left_hip" },
		{ "Torso", "Right Leg", "right_hip" },
	},
	["R15"] = {
		{ "Head", "UpperTorso" },
		{ "UpperTorso", "LowerTorso" },
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

local math_min = math.min
local math_max = math.max
local math_huge = math.huge
local table_insert = table.insert
local table_remove = table.remove
local os_clock = os.clock

local function GetR6JointPosition(torso, jointType)
	local cf = torso.CFrame
	local size = torso.Size

	if jointType == "top" then
		-- neck
		return cf * Vector3.new(0, size.Y * 0.5, 0)
	elseif jointType == "left_shoulder" then
		-- l shoulder
		return cf * Vector3.new(-size.X * 0.5, size.Y * 0.3, 0)
	elseif jointType == "right_shoulder" then
		-- r shoulder
		return cf * Vector3.new(size.X * 0.5, size.Y * 0.3, 0)
	elseif jointType == "left_hip" then
		-- l hip
		return cf * Vector3.new(-size.X * 0.3, -size.Y * 0.5, 0)
	elseif jointType == "right_hip" then
		-- r hip
		return cf * Vector3.new(size.X * 0.3, -size.Y * 0.5, 0)
	end

	return cf.Position
end

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
	return DefaultSkeletons[RigType]
end

local R6Parts = { "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg" }
local R15Parts = {
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

local function GetBodyPartNames(character, RigType)
	if not character then
		return {}
	end
	if RigType == "R6" then
		return R6Parts
	elseif RigType == "R15" then
		return R15Parts
	end
	return character.BodyParts or {}
end

local function GetBones(character, bodyParts)
	local parts = {}
	for i = 1, #bodyParts do
		local name = bodyParts[i]
		parts[name] = character:FindFirstChild(name)
	end
	return parts
end

local function GetSkeletonBones(bonesTable, skeletonStruct)
	if not bonesTable or not skeletonStruct then
		return {}
	end

	local skeletonBones = {}
	local count = 0

	for i = 1, #skeletonStruct do
		local pair = skeletonStruct[i]
		local partA = bonesTable[pair[1]]
		local partB = bonesTable[pair[2]]
		if partA and partB then
			count = count + 1
			skeletonBones[count] = { partA, partB }
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
		RigType = {},
		Player = {},
		LastUpdate = {},
		DisplayName = {},
		Name = {},
	},
	Callbacks = { Added = {}, Removed = {} },
	EntityLookup = {},
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

function ECS:GetBonePositions(id, boneIndex)
	local C = self.Components
	local skeleton = C.Skeleton[id]
	local rigType = C.RigType[id]

	if not skeleton or not skeleton[boneIndex] then
		return nil, nil
	end

	local bone = skeleton[boneIndex]
	local partA = bone[1]
	local partB = bone[2]
	local jointType = bone[3]

	if not partA or not partB then
		return nil, nil
	end

	local posA, posB

	if rigType == "R6" and jointType then
		if partA.Name == "Torso" then
			posA = GetR6JointPosition(partA, jointType)
			posB = partB.Position
		elseif partB.Name == "Torso" then
			posA = partA.Position
			posB = GetR6JointPosition(partB, jointType)
		else
			posA = partA.Position
			posB = partB.Position
		end
	else
		posA = partA.Position
		posB = partB.Position
	end

	return posA, posB
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
	if not bones then
		return nil
	end

	local minX, minY = math_huge, math_huge
	local maxX, maxY = -math_huge, -math_huge
	local foundVisible = false

	for _, part in pairs(bones) do
		if part and part:IsA("BasePart") then
			local cf = part.CFrame
			local halfSize = part.Size * 0.5

			for i = 1, 4 do
				local corner = CubeCorners[i]
				local worldPos = cf:PointToWorldSpace(halfSize * corner)
				local screenPos, onScreen = Utility:WorldToScreen(worldPos)
				if onScreen then
					foundVisible = true
					local sx, sy = screenPos.X, screenPos.Y
					minX = math_min(minX, sx)
					maxX = math_max(maxX, sx)
					minY = math_min(minY, sy)
					maxY = math_max(maxY, sy)
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

	return {
		X = minX - padX,
		Y = minY - padY,
		W = width + padX * 2,
		H = height + padY * 2,
	}
end

local function SetupCharacterUpdate(self, id, char)
	local C = self.Components
	C.Character[id] = char
	C.PrimaryPart[id] = char.PrimaryPart or char:FindFirstChild("Head")
	C.Humanoid[id] = char:FindFirstChildOfClass("Humanoid")

	local rigType = GetRigType(char)
	C.RigType[id] = rigType
	C.BodyParts[id] = GetBodyPartNames(char, rigType)
	C.Bones[id] = GetBones(char, C.BodyParts[id])
	C.Skeleton[id] = GetSkeletonBones(C.Bones[id], GetSkeletonStruct(rigType), rigType)
	C.BoundingBox[id] = self:CalculateBoundingBox(id)

	C.Position[id] = Vector3.zero
	C.Velocity[id] = Vector3.zero
	C.LastUpdate[id] = 0
end

function ECS:Register(id, data)
	if not data.Player then
		if not data.Character or not data.PrimaryPart or not data.Name then
			return
		end
	end

	local rigType = GetRigType(data.Character)
	local C = self.Components

	C.Character[id] = data.Character
	C.PrimaryPart[id] = data.PrimaryPart or (data.Character and data.Character:FindFirstChild("Head"))
	C.Humanoid[id] = data.Humanoid or (data.Character and data.Character:FindFirstChildOfClass("Humanoid"))
	C.Team[id] = data.Team or (data.Player and data.Player.Team) or "Neutral"
	C.TeamColor[id] = data.TeamColor or (data.Player and data.Player.TeamColor and data.Player.TeamColor.Color)
	C.Player[id] = data.Player
	C.CustomUpdate[id] = data.CustomUpdate
	C.Name[id] = data.Name
	C.DisplayName[id] = data.DisplayName or data.Name
	C.Health[id] = 0
	C.Position[id] = Vector3.zero
	C.Velocity[id] = Vector3.zero
	C.LastUpdate[id] = 0
	C.RigType[id] = rigType
	C.BodyParts[id] = GetBodyPartNames(data.Character, rigType)
	C.Bones[id] = GetBones(data.Character, C.BodyParts[id])
	C.Skeleton[id] = GetSkeletonBones(C.Bones[id], GetSkeletonStruct(rigType))
	C.BoundingBox[id] = self:CalculateBoundingBox(id)
	C.IsAlive[id] = true
	C.IsEnemy[id] = false

	if data.Player then
		data.Player.CharacterAdded:Connect(function(char)
			task.delay(0.5, function()
				SetupCharacterUpdate(self, id, char)
			end)
		end)
	end

	table_insert(self.Entities, id)
	self.EntityLookup[id] = #self.Entities
	self:TriggerCallbacks(id, "Added")
end

function ECS:Unregister(id)
	self:TriggerCallbacks(id, "Removed")

	local C = self.Components
	for _, comp in pairs(C) do
		comp[id] = nil
	end

	local idx = self.EntityLookup[id]
	if idx then
		table_remove(self.Entities, idx)
		self.EntityLookup[id] = nil

		for i = idx, #self.Entities do
			self.EntityLookup[self.Entities[i]] = i
		end
	end
end

-- Callbacks
function ECS:OnEntityAdded(fn)
	table_insert(self.Callbacks.Added, fn)
end

function ECS:OnEntityRemoved(fn)
	table_insert(self.Callbacks.Removed, fn)
end

function ECS:TriggerCallbacks(id, state)
	local callbacks = self.Callbacks[state]
	if not callbacks or #callbacks == 0 then
		return
	end

	local view = self:GetEntityView(id)
	for i = 1, #callbacks do
		callbacks[i](view)
	end
end

function ECS:UpdateEntity(id)
	local C = self.Components
	local now = os_clock() * 1000
	local cacheTime = Globals.Flags.Settings.EntityCacheUpdate or 100

	if C.LastUpdate[id] and (now - C.LastUpdate[id]) < cacheTime then
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

	local player = C.Player[id]
	if player then
		local playerTeam = player.Team or "Neutral"
		C.Team[id] = playerTeam
		C.TeamColor[id] = player.TeamColor and player.TeamColor.Color or Color3.new(1, 1, 1)
		C.IsEnemy[id] = (playerTeam ~= C.Team[LocalPlayer.Name])
	end

	C.BoundingBox[id] = self:CalculateBoundingBox(id)

	local fn = C.CustomUpdate[id]
	if fn then
		SecureCall(fn, self:GetEntityView(id))
	end

	C.LastUpdate[id] = now
end

function ECS:UpdateAll()
	local entities = self.Entities
	for i = 1, #entities do
		self:UpdateEntity(entities[i])
	end
end

function ECS:GetLocalPlayer()
	return self:GetEntityView(LocalPlayer.Name)
end

function ECS:Load()
	local players = Players:GetPlayers()
	for i = 1, #players do
		local player = players[i]
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

	Cheat:Connect(Players.PlayerRemoving, function(a0)
		self:Unregister(a0.Name)
	end)

	Cheat:Connect(RunService.Heartbeat, function()
		self:UpdateAll()
	end)
end

function ECS:Unload()
	local entities = self.Entities
	for i = #entities, 1, -1 do
		self:Unregister(entities[i])
	end
	self.Callbacks.Added = {}
	self.Callbacks.Removed = {}
	self.EntityLookup = {}
end

getgenv().Entity = ECS
return ECS
