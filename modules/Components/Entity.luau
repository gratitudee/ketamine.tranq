local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Component = {
	EventCallbacks = {
		Added = {},
		Removed = {},
		Hit = {},
		Killed = {},
	},
	Entities = {},
	Connections = {},
}

local CubeCorners = {
	Vector3.new(0, -1, -1),
	Vector3.new(0, -1, 1),
	Vector3.new(0, 1, -1),
	Vector3.new(0, 1, 1),
}

-- Private Functions
-- Event Callback Fire(r)
local function FireEntityEvent(Event: "Added" | "Removed" | "Hit" | "Killed", Entity)
	local EventCallbacks = Component.EventCallbacks[Event]
	if not EventCallbacks then
		return
	end

	for _, Callback in pairs(EventCallbacks) do
		Callback(Event, Entity)
	end
end

-- Get Team Function
local function GetBoundingBox(Entity)
	local minX, minY = math.huge, math.huge
	local maxX, maxY = -math.huge, -math.huge
	local visible = false

	local Bones = Entity.Bones
	for i = 1, #Bones do
		local part = Bones[i]
		if part:IsA("BasePart") then
			local cf = part.CFrame
			local hs = part.Size * 0.5

			for j = 1, 4 do
				local world = cf:PointToWorldSpace(hs * CubeCorners[j])
				local screen, onScreen = Cheat:WorldToScreen(world)

				if onScreen then
					visible = true
					local x, y = screen.X, screen.Y
					if x < minX then
						minX = x
					end
					if y < minY then
						minY = y
					end
					if x > maxX then
						maxX = x
					end
					if y > maxY then
						maxY = y
					end
				end
			end
		end
	end

	if not visible then
		return nil
	end

	local Width = maxX - minX
	local Height = maxY - minY
	local PadX = Width * 0.23
	local PadY = Height * 0.17

	return {
		X = minX - PadX,
		Y = minY - PadY,
		W = Width + PadX * 2,
		H = Height + PadY * 2,
	}
end

local function GetVisibility(Entity)
	return true
end

local function GetWeapon(Entity)
	if Ketamine.Support and Ketamine.Support.GetWeapon then
		return Ketamine.Support:GetWeapon(Entity)
	end

	local Tool = Entity.Character and Entity.Character:FindFirstChildOfClass("Tool")
	return Tool and Tool.Name or nil
end

local function GetTeamColor(Entity)
	if Entity.Player and Entity.Player.TeamColor then
		return Entity.Player.TeamColor.Color
	end

	return Color3.fromRGB(255, 255, 255)
end

local function GetTeam(Entity)
	if Ketamine.Support and Ketamine.Support.GetTeam then
		return Ketamine.Support:GetTeam(Entity)
	end

	if Entity.Player and Entity.Player.Team then
		return Entity.Player.Team.Name
	end

	return Entity.Team or "Neutral" -- ffa mode if cant find team
end

local function GetAlive(Entity)
	if Ketamine.Support and Ketamine.Support.GetHealth then
		return Ketamine.Support:GetHealth(Entity)
	end

	if Entity.Humanoid then
		return Entity.Humanoid.Health > 0
	end

	if Entity.HealthInstance then
		local Value = Entity.HealthInstance.Value
		return (type(Value) == "number" and Value > 0) or Value == true
	end

	return true -- default to be alive so it still fuckin works.
end

local function GetHealth(Entity)
	if Ketamine.Support and Ketamine.Support.GetHealth then
		return Ketamine.Support:GetHealth(Entity)
	end

	if Entity.Humanoid then
		return Entity.Humanoid.Health
	end

	if Entity.HealthInstance then
		local Value = Entity.HealthInstance.Value
		return (type(Value) == "number" and Value > 0) or 100
	end

	return 100
end

local function UpdateEntity(Entity)
	if
		not Entity.Character
		or not Entity.Character.Parent
		or not Entity.PrimaryPart
		or not Entity.PrimaryPart.Parent
	then
		Component:RemoveModel(Entity._Key)
		return
	end

	Entity.Position = Entity.PrimaryPart and Entity.PrimaryPart.Position or Vector3.zero
	Entity.Velocity = Entity.PrimaryPart and Entity.PrimaryPart.AssemblyLinearVelocity or Vector3.zero
	Entity.LastHealth = Entity.Health
	Entity.Health = GetHealth(Entity)
	Entity.Weapon = GetWeapon(Entity)
	--
	Entity.Team = GetTeam(Entity)
	Entity.TeamColor = GetTeamColor(Entity)
	--
	Entity.IsAlive = GetAlive(Entity)

	Entity.IsEnemy = Flags.Settings.FreeForAll == true
		or Entity.Team == "Neutral"
		or Entity.Team ~= Component:GetLocalPlayer().Team
	local NewVisibilityState = GetVisibility(Entity)
	if NewVisibilityState ~= nil then
		Entity.IsVisible = NewVisibilityState
	end
	--
	Entity.BoundingBox = GetBoundingBox(Entity)
end

local function SetupPlayer(Player: Player)
	local function OnCharacterAdded(Character: Model)
		local PrimaryPart = Character.PrimaryPart
			or Character:WaitForChild("HumanoidRootPart", 3)
			or Character:FindFirstChild("Head")
		local Humanoid = Character:FindFirstChildOfClass("Humanoid")

		if not PrimaryPart then
			return
		end

		Component:AddModel(Player.Name, {
			Name = Player.Name,
			Character = Character,
			PrimaryPart = PrimaryPart,

			Player = Player,
			DisplayName = Player.DisplayName,
			Humanoid = Humanoid,
			HealthInstance = nil,
		})
	end

	local function OnCharacterRemoving()
		Component:RemoveModel(Player.Name)
	end

	Component.Connections[Player] = {
		Player.CharacterAdded:Connect(OnCharacterAdded),
		Player.CharacterRemoving:Connect(OnCharacterRemoving),
	}

	if Player.Character then
		OnCharacterAdded(Player.Character)
	end
end

-- Public Functions
-- Get Functions
function Component:GetLocalPlayer()
	return self.Entities[Players.LocalPlayer.Name]
end

function Component:GetPlayers(EnemiesOnly: boolean)
	local ToReturn = {}
	for _, Entity in pairs(Component.Entities) do
		if EnemiesOnly and not Entity.IsEnemy then
			continue
		end

		table.insert(ToReturn, Entity)
	end
	return ToReturn
end

-- Event Callbacks Adders
function Component:OnEntityRemoved(IDX, Function) end
function Component:OnEntityAdded(IDX, Function) end
function Component:OnEntityHit(IDX, Function) end
function Component:OnEntityKilled(IDX, Function) end

--[[
	@param Key string        A unique key to identify the model
	@param Data table        A table containing model information with the following structure:
		{
			Name: string,                   -- Name of the entity
			Character: Model,               -- The model representing the entity
			PrimaryPart: BasePart,          -- The primary part of the model

			-- Optional fields
			Player: Player?,                -- Associated player (if applicable)
			DisplayName: string?,           -- Display name for the entity
			Humanoid: Humanoid?,            -- Humanoid instance (if applicable)
			HealthInstance: Instance?       -- Health value instance
		}
	@return Success boolean 	If AddModel successfully added the model or not.
]]
function Component:AddModel(Key, Data)
	if not Key or not Data or typeof(Data) ~= "table" then
		return false
	end

	if not Data.Character then
		return false
	end

	if not Data.Name then
		return false
	end

	if not Data.PrimaryPart then
		return false
	end

	if not Data.Name and Data.Player then
		Data.Name = Data.Player.Name
	end

	if self.Entities[Key] then
		self:RemoveModel(Key)
	end

	local Entity = {
		_Key = Key,
		Player = Data.Player,
		Character = Data.Character,
		PrimaryPart = Data.PrimaryPart,
		Name = Data.Name,
		DisplayName = Data.DisplayName or Data.Name,
		Humanoid = Data.Humanoid,
		HealthInstance = Data.HealthInstance,
		Health = 100,
		LastHealth = nil,
		Weapon = nil,
		--
		Team = Data.Team or nil,
		TeamColor = Data.TeamColor or nil,
		--
		Position = Vector3.zero,
		Velocity = Vector3.zero,
		--
		IsAlive = true,
		IsEnemy = false,
		IsVisible = false,
		IsWhitelisted = false,
		--
		BoundingBox = nil,
		Bones = {},
		--
		Connections = {},
	}

	for _, Basepart: BasePart? in pairs(Entity.Character:GetChildren()) do
		if Basepart and Basepart:IsA("BasePart") then
			table.insert(Entity.Bones, Basepart)
		end
	end

	Entity.Connections[#Entity.Connections + 1] = Entity.Character.ChildAdded:Connect(function(a0: Instance)
		if a0 and a0:IsA("BasePart") then
			table.insert(Entity.Bones, a0)
		end
	end)

	Entity.Connections[#Entity.Connections + 1] = Entity.Character.ChildRemoved:Connect(function(a0: Instance)
		if a0 and a0:IsA("BasePart") then
			table.remove(Entity.Bones, table.find(Entity.Bones, a0))
		end
	end)

	Entity.Connections[#Entity.Connections + 1] = Entity.Character.AncestryChanged:Connect(function(_, parent)
		if not parent then
			self:RemoveModel(Entity._Key)
		end
	end)

	self.Entities[Key] = Entity
	FireEntityEvent("Added", self.Entities[Key])
	return true
end

function Component:RemoveModel(Key)
	local Entity = self.Entities[Key]
	if not Entity then
		return
	end

	FireEntityEvent("Removed", Entity)
	for _, Connection in pairs(Entity.Connections) do
		if typeof(Connection) == "RBXScriptConnection" and Connection.Connected then
			Connection:Disconnect()
		end
	end
	table.clear(Entity.Connections)
	self.Entities[Key] = nil
end

-- Runtime Functions
function Component:Load()
	local function ProcessEntityPath(Path)
		if typeof(Path) == "table" then
		elseif typeof(Path) == "Instance" then
		end
	end

	if Ketamine.Support and Ketamine.Support.GetEntities then
		local EntityResult = Ketamine.Support:GetEntities()
		ProcessEntityPath(EntityResult)
	end

	for _, Player in pairs(Players:GetPlayers()) do
		Ketamine:SecureSpawn(function()
			local Character = Player.Character
			local PrimaryPart, Humanoid =
				Character and (Character.PrimaryPart or Character:FindFirstChild("Head")) or nil,
				Character and Character:FindFirstChild("Humanoid") or nil
			self:AddModel(Player.Name, {
				Name = Player.Name,
				Character = Player.Character,
				PrimaryPart = PrimaryPart,

				Player = Player,
				DisplayName = Player.DisplayName,
				Humanoid = Humanoid,
				HealthInstance = nil,
			})
		end)
	end

	Cheat:Connect(Players.PlayerAdded, function(Player: Player)
		local Character = Player.Character
		local PrimaryPart, Humanoid =
			Character and (Character.PrimaryPart or Character:FindFirstChild("Head")) or nil,
			Character and Character:FindFirstChild("Humanoid") or nil

		Ketamine:SecureSpawn(function()
			self:AddModel(Player.Name, {
				Name = Player.Name,
				Character = Player.Character,
				PrimaryPart = PrimaryPart,

				Player = Player,
				DisplayName = Player.DisplayName,
				Humanoid = Humanoid,
				HealthInstance = nil,
			})
		end)
	end)

	Cheat:Connect(Players.PlayerRemoving, function(Player: Player)
		self:RemoveModel(Player.Name)
	end)

	Cheat:Connect(RunService.Heartbeat, function()
		for _, Entity in pairs(self.Entities) do
			UpdateEntity(Entity)
		end
	end)
end

function Component:Unload()
	table.clear(self.EventCallbacks)
	for Key, Entity in pairs(self.Entities) do
		self:RemoveModel(Key)
	end
end

return Component
