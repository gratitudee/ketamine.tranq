local Component = {
	EventCallbacks = {
		Added = {},
		Removed = {},
		Hit = {},
		Killed = {},
	},
	Entities = {},
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

-- Public Functions
-- Event Callbacks Adders
function Component:OnEntityRemoved(IDX, Function) end
function Component:OnEntityAdded(IDX, Function) end
function Component:OnEntityHit(IDX, Function) end
function Component:OnEntityKilled(IDX, Function) end

-- Runtime Functions
function Component:Load() end
function Component:Unload() end

return Component
