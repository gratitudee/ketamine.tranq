local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Entity = {
	Entities = {},
	Callbacks = {
		Added = {},
		Removed = {},
		Hit = {},
		Killed = {},
	},
	PlayerConnections = {},
	GlobalConnections = {},
}

-- Constants
local PART_CORNERS = {
	Vector3.new(0, -1, -1),
	Vector3.new(0, -1, 1),
	Vector3.new(0, 1, -1),
	Vector3.new(0, 1, 1),
}
local DEFAULT_STRUCT = {
	["R6"] = {
		["Head"] = "Head",
		["Torso"] = "Torso",
		["Arms"] = { "Left Arm", "Right Arm" },
		["Legs"] = { "Left Leg", "Right Leg " },
	},
	["R15"] = {
		["Head"] = "Head",
		["Torso"] = { "UpperTorso", "LowerTorso" },
		["Arms"] = { "LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand" },
		["Legs"] = { "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot" },
	},
}

-- helper funcs
local function GetRigType(Character)
	if Character:FindFirstChild("UpperTorso") then
		return "R15"
	elseif Character:FindFirstChild("Torso") then
		return "R6"
	else
		return "Custom"
	end
end

local function GetBodyStruct(EntityObject, RigType)
	if Ketamine.Support and Ketamine.Support.GetBodyStruct then
		local customStruct = Ketamine.Support:GetBodyStruct(EntityObject)
		if customStruct then
			return customStruct
		end
	end

	if RigType == "R6" or RigType == "R15" then
		return DEFAULT_STRUCT[RigType]
	end

	local fullBody = {}
	for _, part in ipairs(EntityObject.Character:GetChildren()) do
		if part:IsA("BasePart") then
			fullBody[part.Name] = part.Name
		end
	end
	return fullBody
end

local function ResolveBodyStruct(EntityObject)
	local Character = EntityObject.Character
	if not Character then
		return nil
	end

	local rig = GetRigType(Character)
	local struct = GetBodyStruct(EntityObject, rig)

	local GroupedBody = {}
	if struct and next(struct) then
		for group, names in pairs(struct) do
			GroupedBody[group] = {}
			if type(names) == "string" then
				local part = Character:FindFirstChild(names)
				if part then
					table.insert(GroupedBody[group], part)
				end
			elseif type(names) == "table" then
				for _, name in ipairs(names) do
					local part = Character:FindFirstChild(name)
					if part then
						table.insert(GroupedBody[group], part)
					end
				end
			end
		end
	end

	if not next(GroupedBody) then
		GroupedBody["All"] = {}
		for _, part in ipairs(Character:GetChildren()) do
			if part:IsA("BasePart") then
				table.insert(GroupedBody["All"], part)
			end
		end
	end

	return GroupedBody
end

local function UpdateBody(EntityObject)
	local Tmp = {}
	for _, child in ipairs(EntityObject.Character:GetChildren()) do
		if child:IsA("BasePart") then
			table.insert(Tmp, child)
		end
	end
	EntityObject.Bones = Tmp
	EntityObject.AimParts = ResolveBodyStruct(EntityObject)
end

local function FireCallback(Event, EntityObject, ...)
	if EntityObject == Entity:GetLocalPlayer() then
		return
	end

	for _, Callback in pairs(Entity.Callbacks[Event]) do
		task.spawn(Callback, EntityObject, ...)
	end
end

local function GetBoundingBox(EntityObject)
	local MinX, MinY = math.huge, math.huge
	local MaxX, MaxY = -math.huge, -math.huge
	local Visible = false

	for _, Part in ipairs(EntityObject.Bones) do
		if not Part.Parent then
			continue
		end

		local CF = Part.CFrame
		local HS = Part.Size * 0.5

		for _, Corner in ipairs(PART_CORNERS) do
			local World = CF:PointToWorldSpace(HS * Corner)
			local Screen, OnScreen = Cheat:WorldToScreen(World)

			if OnScreen then
				Visible = true
				MinX = math.min(MinX, Screen.X)
				MinY = math.min(MinY, Screen.Y)
				MaxX = math.max(MaxX, Screen.X)
				MaxY = math.max(MaxY, Screen.Y)
			end
		end
	end

	if not Visible then
		return nil
	end

	local Width = MaxX - MinX
	local Height = MaxY - MinY
	local PadX = Width * 0.23
	local PadY = Height * 0.17

	return {
		x = MinX - PadX,
		y = MinY - PadY,
		w = Width + PadX * 2,
		h = Height + PadY * 2,
	}
end

local function GetTeam(EntityObject)
	if Ketamine.Support and Ketamine.Support.GetTeam then
		return Ketamine.Support:GetTeam(EntityObject)
	end

	if EntityObject.Player and EntityObject.Player.Team then
		return EntityObject.Player.Team.Name
	end

	return EntityObject.Team or "Neutral"
end

local function GetTeamColor(EntityObject)
	if EntityObject.Player and EntityObject.Player.TeamColor then
		return EntityObject.Player.TeamColor.Color
	end
	return Color3.fromRGB(255, 255, 255)
end

local function GetWeapon(EntityObject)
	if Ketamine.Support and Ketamine.Support.GetWeapon then
		return Ketamine.Support:GetWeapon(EntityObject)
	end

	local Tool = EntityObject.Character and EntityObject.Character:FindFirstChildOfClass("Tool")
	return Tool and Tool.Name or nil
end

local function GetHealth(EntityObject)
	if Ketamine.Support and Ketamine.Support.GetHealth then
		return Ketamine.Support:GetHealth(EntityObject)
	end

	if EntityObject.Humanoid then
		return EntityObject.Humanoid.Health, EntityObject.Humanoid.MaxHealth
	end

	if EntityObject.HealthInstance then
		local Value = EntityObject.HealthInstance.Value
		if type(Value) == "number" then
			return Value, EntityObject.MaxHealthValue or 100
		end
	end

	return EntityObject.StaticHealth or 100, EntityObject.MaxHealthValue or 100
end

-- entity methods
local EntityMethods = {}
EntityMethods.__index = EntityMethods

function EntityMethods:GetBonePosition(BoneName)
	local Bone = self:GetBoneInstance(BoneName)
	return Bone and Bone.Position or nil
end

function EntityMethods:GetBoneInstance(BoneName)
	return self.Character and self.Character:FindFirstChild(BoneName)
end

function EntityMethods:GetBoneSize(BoneName)
	local Bone = self:GetBoneInstance(BoneName)
	return Bone and Bone.Size or nil
end

function EntityMethods:GetBoneRotation(BoneName)
	local Bone = self:GetBoneInstance(BoneName)
	if not Bone then
		return nil
	end

	local CF = Bone.CFrame
	return {
		CF.RightVector.X,
		CF.RightVector.Y,
		CF.RightVector.Z,
		CF.UpVector.X,
		CF.UpVector.Y,
		CF.UpVector.Z,
		-CF.LookVector.X,
		-CF.LookVector.Y,
		-CF.LookVector.Z,
	}
end

function EntityMethods:Update()
	if not self.Character or not self.Character.Parent or not self.PrimaryPart or not self.PrimaryPart.Parent then
		Entity:RemoveModel(self.Key)
		return
	end

	self.Position = self.PrimaryPart.Position
	self.Velocity = self.PrimaryPart.AssemblyLinearVelocity

	local OldHealth = self.Health
	self.Health, self.MaxHealth = GetHealth(self)

	if OldHealth and self.Health < OldHealth then
		local Damage = OldHealth - self.Health
		if self.IsAimbotTarget then
			FireCallback("Hit", self, Damage)
		end
	end

	self.Weapon = GetWeapon(self)

	self.Team = GetTeam(self)
	self.TeamColor = GetTeamColor(self)
	self.IsAlive = self.Health > 0

	local LocalPlayer = Entity:GetLocalPlayer()
	self.IsEnemy = Flags.Settings.FreeForAll == true
		or self.Team == "Neutral"
		or (LocalPlayer and self.Team ~= LocalPlayer.Team)

	-- self.IsVisible = CheckVisibility(self)
	self.BoundingBox = GetBoundingBox(self)
end

function EntityMethods:Destroy()
	for _, Connection in ipairs(self.Connections) do
		Connection:Disconnect()
	end
	table.clear(self.Connections)
	table.clear(self.Bones)
end

-- entity management
function Entity:AddModel(Key, Data)
	if not Key or type(Data) ~= "table" then
		return false
	end
	if not Data.Character or not Data.PrimaryPart or not Data.Name then
		return false
	end

	if self.Entities[Key] then
		self:RemoveModel(Key)
	end

	local EntityObject = setmetatable({
		Key = Key,
		Character = Data.Character,
		PrimaryPart = Data.PrimaryPart,
		Player = Data.Player,
		Humanoid = Data.Humanoid,
		HealthInstance = Data.HealthInstance,
		StaticHealth = Data.Health,
		MaxHealthValue = Data.MaxHealth,
		IsAimbotTarget = false,
		Bones = {}, -- bbox
		AimParts = {},
		Connections = {},

		Name = Data.Name,
		DisplayName = Data.DisplayName or Data.Name,
		UserId = Data.Player and Data.Player.UserId or nil,
		Position = Vector3.zero,
		Velocity = Vector3.zero,
		Health = Data.Health or 100,
		MaxHealth = Data.MaxHealth or 100,
		Team = Data.Team,
		TeamColor = Data.TeamColor,
		Weapon = Data.Weapon,
		IsAlive = true,
		IsEnemy = false,
		IsVisible = false,
		IsWhitelisted = false,
		BoundingBox = nil,
	}, EntityMethods)

	UpdateBody(EntityObject)
	if EntityObject.Humanoid then
		table.insert(
			EntityObject.Connections,
			EntityObject.Humanoid.Died:Connect(function(...)
				FireCallback("Killed", EntityObject)
			end)
		)
	end
	table.insert(
		EntityObject.Connections,
		EntityObject.Character.ChildAdded:Connect(function(child)
			if child:IsA("BasePart") then
				table.insert(EntityObject.Bones, child)
				UpdateBody(EntityObject)
			end
		end)
	)

	table.insert(
		EntityObject.Connections,
		EntityObject.Character.ChildRemoved:Connect(function(child)
			if child:IsA("BasePart") then
				local idx = table.find(EntityObject.Bones, child)
				if idx then
					table.remove(EntityObject.Bones, idx)
					UpdateBody(EntityObject)
				end
			end
		end)
	)

	table.insert(
		EntityObject.Connections,
		EntityObject.Character.AncestryChanged:Connect(function(_, Parent)
			if not Parent then
				self:RemoveModel(Key)
			end
		end)
	)

	self.Entities[Key] = EntityObject
	FireCallback("Added", EntityObject)

	return true
end

function Entity:RemoveModel(Key)
	local EntityObject = self.Entities[Key]
	if not EntityObject then
		return false
	end

	FireCallback("Removed", EntityObject)
	EntityObject:Destroy()
	self.Entities[Key] = nil

	return true
end

function Entity:ClearModels()
	for Key in pairs(self.Entities) do
		if not self.Entities[Key].Player then
			self:RemoveModel(Key)
		end
	end
	return true
end

function Entity:EditModel(Key, Data)
	local EntityObject = self.Entities[Key]
	if not EntityObject then
		return false
	end

	if Data.Health then
		EntityObject.StaticHealth = Data.Health
	end
	if Data.MaxHealth then
		EntityObject.MaxHealthValue = Data.MaxHealth
	end
	if Data.Team then
		EntityObject.Team = Data.Team
	end
	if Data.TeamColor then
		EntityObject.TeamColor = Data.TeamColor
	end
	if Data.Weapon then
		EntityObject.Weapon = Data.Weapon
	end

	return true
end

-- query funcs
function Entity:GetLocalPlayer()
	return self.Entities[Players.LocalPlayer.Name]
end

function Entity:GetPlayers(OnlyEnemies)
	local Result = {}
	for _, EntityObject in pairs(self.Entities) do
		if EntityObject == Entity:GetLocalPlayer() then
			continue
		end

		if not OnlyEnemies or EntityObject.IsEnemy then
			table.insert(Result, EntityObject)
		end
	end
	return Result
end

-- callbacks
function Entity:OnEntityAdded(Callback)
	table.insert(self.Callbacks.Added, Callback)
end

function Entity:OnEntityRemoved(Callback)
	table.insert(self.Callbacks.Removed, Callback)
end

function Entity:OnEntityHit(Callback)
	table.insert(self.Callbacks.Hit, Callback)
end

function Entity:OnEntityKilled(Callback)
	table.insert(self.Callbacks.Killed, Callback)
end

-- player setup
local function SetupPlayer(Player)
	local function OnCharacterAdded(Character)
		local PrimaryPart = Character.PrimaryPart
			or Character:WaitForChild("HumanoidRootPart", 3)
			or Character:FindFirstChild("Head")

		local Humanoid = Character:FindFirstChildOfClass("Humanoid")

		if not PrimaryPart then
			return
		end

		Entity:AddModel(Player.Name, {
			Name = Player.Name,
			DisplayName = Player.DisplayName,
			Character = Character,
			PrimaryPart = PrimaryPart,
			Player = Player,
			Humanoid = Humanoid,
		})
	end

	local function OnCharacterRemoving()
		Entity:RemoveModel(Player.Name)
	end

	Entity.PlayerConnections[Player] = {
		Player.CharacterAdded:Connect(OnCharacterAdded),
		Player.CharacterRemoving:Connect(OnCharacterRemoving),
	}

	if Player.Character then
		OnCharacterAdded(Player.Character)
	end
end

-- runtime
function Entity:Load()
	--[[
	if Ketamine.Support and Ketamine.Support.GetEntities then
		local Entities = Ketamine.Support:GetEntities()
		if type(Entities) == "table" then
			for Key, Data in pairs(Entities) do
				self:AddModel(Key, Data)
			end
		end
	end]]
	--

	for _, Player in ipairs(Players:GetPlayers()) do
		SetupPlayer(Player)
	end

	table.insert(self.GlobalConnections, Players.PlayerAdded:Connect(SetupPlayer))
	table.insert(
		self.GlobalConnections,
		Players.PlayerRemoving:Connect(function(Player)
			self:RemoveModel(Player.Name)

			if self.PlayerConnections[Player] then
				for _, Conn in ipairs(self.PlayerConnections[Player]) do
					Conn:Disconnect()
				end
				self.PlayerConnections[Player] = nil
			end
		end)
	)

	table.insert(
		self.GlobalConnections,
		RunService.Heartbeat:Connect(function()
			for _, EntityObject in pairs(self.Entities) do
				EntityObject:Update()
			end
		end)
	)
end

function Entity:Unload()
	for _, Connection in ipairs(self.GlobalConnections) do
		Connection:Disconnect()
	end
	table.clear(self.GlobalConnections)

	for Player, Connections in pairs(self.PlayerConnections) do
		for _, Conn in ipairs(Connections) do
			Conn:Disconnect()
		end
	end
	table.clear(self.PlayerConnections)

	for Key in pairs(self.Entities) do
		self:RemoveModel(Key)
	end

	for _, Tbl in pairs(self.Callbacks) do
		table.clear(Tbl)
	end
end

return Entity
