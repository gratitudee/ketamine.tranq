local Workspace = game:GetService("Workspace")

local Camera = Workspace:FindFirstChildOfClass("Camera")

local Utility = {}

function Utility:WorldToScreen(WorldPosition)
	local Position, OnScreen = Camera:WorldToViewportPoint(WorldPosition)
	return Position, OnScreen
end

function Utility:Raycast(Part, Origin, Ignore, Distance)
	Ignore = Ignore or {}
	Distance = Distance or 2000

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = Ignore

	local direction = (Part.Position - Origin).Unit * Distance
	local result = Workspace:Raycast(Origin, direction, params)

	while
		result
		and result.Instance ~= Part
		and not result.Instance:IsDescendantOf(Part.Parent)
		and result.Instance.Transparency >= 1
		and not result.Instance.CanCollide
	do
		table.insert(params.FilterDescendantsInstances, result.Instance)
		result = Workspace:Raycast(Origin, direction, params)
	end

	return result and result.Instance:IsDescendantOf(Part.Parent), result and result.Instance
end

-- these two functions are only here so it doesn't make the error log cry.
function Utility:Load() end
function Utility:Unload() end

getgenv().Utility = Utility
return Utility
