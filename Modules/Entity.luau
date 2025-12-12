local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Cheat = require("./Cheat")

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

local function GetBodyParts(character, RigType)
	if not character then
		return nil
	end

	local limbs
	if RigType == "R6" then
		limbs = { "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg" }
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
	else
		limbs = character.BodyParts or {}
	end

	local parts = {}
	for _, name in ipairs(limbs) do
		local part = character:FindFirstChild(name)
		parts[name] = part
	end
	return parts
end

-- ECS Module
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
		Skeleton = {},
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

-- Proxy entity view
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

function ECS:Register(id, data)
	if not data.Player then
		if not data.Character or not data.PrimaryPart or not data.Name then
			return
		end
	end

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
	C.BodyParts[id] = GetBodyParts(data.Character, GetRigType(data.Character))
	C.Skeleton[id] = GetSkeletonStruct(GetRigType(data.Character))
	C.IsAlive[id] = true
	C.IsEnemy[id] = false

	if data.Player then
		data.Player.CharacterAdded:Connect(function(char)
			task.delay(0.5, function()
				C.Character[id] = char
				C.PrimaryPart[id] = char.PrimaryPart or char:FindFirstChild("Head")
				C.Humanoid[id] = char:FindFirstChildOfClass("Humanoid")
				C.BodyParts[id] = GetBodyParts(char, GetRigType(char))
				C.Skeleton[id] = GetSkeletonStruct(GetRigType(char))
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

	local fn = C.CustomUpdate[id]
	if fn then
		task.spawn(fn, self:GetEntityView(id))
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
