local RunService = game:GetService("RunService")
local Component = {}

function Component:Load()
	Cheat:Connect(RunService.Heartbeat, function() end)
end
function Component:Unload() end

return Component
