local RunService = game:GetService("RunService")
local Options, Toggles = Ketamine.Library.Options, Ketamine.Library.Toggles
local Component = {}

local function BuildMenu()
	local function BindToggle(id, tbl, key)
		if tbl[key] == nil then
			print(`UI ERROR | Failed to bind {key}, key not found.`)
			return
		end

		Toggles[id]:OnChanged(function(v)
			tbl[key] = v
		end)
	end

	local function BindOption(id, tbl, key)
		if tbl[key] == nil then
			print(`UI ERROR | Failed to bind {key}, key not found.`)
			return
		end
		Options[id]:OnChanged(function(v)
			tbl[key] = v
		end)
	end

	local function BindMultiselect(id, tbl)
		Options[id]:OnChanged(function()
			local values = Options[id].Value
			for k in pairs(tbl) do
				tbl[k] = values[k] == true
			end
		end)
	end

	local function BindColorPicker(id, setter)
		Options[id]:OnChanged(function()
			setter(Options[id].Value, Options[id].Transparency)
		end)
	end

	local function BindKeybind(id, callback)
		if not callback then
			return
		end
		local key = Options[id]
		key:OnClick(function()
			callback(key:GetState())
		end)
	end

	local Tab = Ketamine.Window:AddTab("Aimbot")
	local AimbotMain = Tab:AddLeftGroupbox("Assist")

	-- Aimbot Main
	AimbotMain:AddToggle("AimEnabled", {
		Text = "Enabled",
		Default = Flags.Aimbot.AimEnabled,
	}):AddKeyPicker("AimKeybind", {
		Mode = "Hold",
		Text = "Aimbot",
		Default = "MB1",
	})
	BindToggle("AimEnabled", Flags.Aimbot, "AimEnabled")
	BindKeybind("AimKeybind", function(State)
		Flags.Aimbot.AimKeybindActive = State
	end)
	task.spawn(function()
		while true do
			if not Ketamine or not Ketamine.Library or Ketamine.Library.Unloaded then
				break
			end
			Flags.Aimbot.AimKeybindActive = Options.AimKeybind:GetState()
			task.wait()
		end
	end)

	AimbotMain:AddToggle("AimStickyEnabled", {
		Text = "Sticky Aim",
		Default = Flags.Aimbot.StickyAim.Enabled,
	})
	BindToggle("AimStickyEnabled", Flags.Aimbot.StickyAim, "Enabled")
	local StickyAimDependencyBox = AimbotMain:AddDependencyBox()
	StickyAimDependencyBox:AddDropdown("StickyAimMethod", {
		Values = { "Weak", "Strong" },
		Default = Flags.Aimbot.StickyAim.Method,
		Text = "Sticky Aim Method",
	})
	BindOption("StickyAimMethod", Flags.Aimbot.StickyAim, "Method")
	StickyAimDependencyBox:SetupDependencies({ { Toggles.AimStickyEnabled, true } })

	AimbotMain:AddDivider()

	AimbotMain:AddDropdown("AimMethod", {
		Values = { "Mouse", "Camera" },
		Default = Flags.Aimbot.AimMethod,
		Text = "Aim Method",
	})
	BindOption("AimMethod", Flags.Aimbot, "AimMethod")

	AimbotMain:AddDropdown("AimStyle", {
		Values = { "Linear", "Exponential", "Spring" },
		Default = Flags.Aimbot.AimStyle,
		Text = "Aim Easing",
	})
	BindOption("AimStyle", Flags.Aimbot, "AimStyle")

	AimbotMain:AddDropdown("AimPriority", {
		Values = { "Closest To Crosshair", "Closest To Player", "Lowest HP", "Highest HP" },
		Default = Flags.Aimbot.AimTargetting,
		Text = "Aim Priority",
	})
	BindOption("AimPriority", Flags.Aimbot, "AimTargetting")

	AimbotMain:AddDropdown("AimChecks", {
		Values = { "Forcefield", "Local Dead", "Invisible", "Visible", "Team" },
		AllowNull = true,
		Multi = true,
		Default = Flags.Aimbot.AimChecks,
		Text = "Aim Checks",
	})
	BindMultiselect("AimChecks", Flags.Aimbot.AimChecks)

	AimbotMain:AddDropdown("AimHitboxes", {
		Values = { "Head", "Torso", "Arms", "Legs" },
		AllowNull = true,
		Multi = true,
		Default = Flags.Aimbot.AimHitboxes,
		Text = "Aim Hitboxes",
	})
	BindMultiselect("AimHitboxes", Flags.Aimbot.AimHitboxes)

	AimbotMain:AddDivider()

	AimbotMain:AddToggle("SmoothnessEnabled", {
		Text = "Smoothness",
		Default = Flags.Aimbot.Smoothness.Enabled,
	})
	BindToggle("SmoothnessEnabled", Flags.Aimbot.Smoothness, "Enabled")

	local SmoothnessDependency = AimbotMain:AddDependencyBox()
	SmoothnessDependency:AddSlider("AimSmoothnessX", {
		Text = "Smoothness (X)",
		Default = Flags.Aimbot.Smoothness.SmoothnessX,
		Min = 0,
		Max = 100,
		Rounding = 1,
		Compact = false,
	})
	SmoothnessDependency:AddSlider("AimSmoothnessY", {
		Text = "Smoothness (Y)",
		Default = Flags.Aimbot.Smoothness.SmoothnessY,
		Min = 0,
		Max = 100,
		Rounding = 1,
		Compact = false,
	})
	BindOption("AimSmoothnessX", Flags.Aimbot.Smoothness, "SmoothnessX")
	BindOption("AimSmoothnessY", Flags.Aimbot.Smoothness, "SmoothnessY")

	SmoothnessDependency:SetupDependencies({ { Toggles.SmoothnessEnabled, true } })

	AimbotMain:AddToggle("PredictionEnabled", {
		Text = "Prediction",
		Default = Flags.Aimbot.Prediction.Enabled,
	})
	BindToggle("PredictionEnabled", Flags.Aimbot.Prediction, "Enabled")

	local PredictionDependency = AimbotMain:AddDependencyBox()
	PredictionDependency:AddDropdown("PredictionMode", {
		Text = "Prediction Mode",
		Values = { "Manual", "Automatic" },
		Default = Flags.Aimbot.Prediction.Mode,
	})
	BindOption("PredictionMode", Flags.Aimbot.Prediction, "Mode")

	PredictionDependency:SetupDependencies({ { Toggles.PredictionEnabled, true } })

	local SubPredictionDependency = PredictionDependency:AddDependencyBox()
	SubPredictionDependency:AddSlider("ManualPredictionX", {
		Text = "Predict (X)",
		Default = Flags.Aimbot.Prediction.PredictionX,
		Min = 0,
		Max = 10,
		Rounding = 1,
		Compact = false,
	})

	SubPredictionDependency:AddSlider("ManualPredictionY", {
		Text = "Predict (Y)",
		Default = Flags.Aimbot.Prediction.PredictionY,
		Min = 0,
		Max = 10,
		Rounding = 1,
		Compact = false,
	})
	BindOption("ManualPredictionX", Flags.Aimbot.Prediction, "PredictionX")
	BindOption("ManualPredictionY", Flags.Aimbot.Prediction, "PredictionY")

	SubPredictionDependency:SetupDependencies({ { Options.PredictionMode, "Manual" } })

	AimbotMain:AddSlider("AimMultipointScale", {
		Text = "Multipoint Scale",
		Default = Flags.Aimbot.MultipointScale,
		Min = 0,
		Max = 100,
		Rounding = 1,
		Suffix = "%",
		Compact = false,
	})
	BindOption("AimMultipointScale", Flags.Aimbot, "MultipointScale")

	AimbotMain:AddDivider()

	AimbotMain:AddToggle("DrawAimFOV", {
		Text = "Draw FOV",
		Default = Flags.Aimbot.FieldOfView.DrawingEnabled,
	})
		:AddColorPicker("FOVFillColor", {
			Title = "FOV Fill Color",
			Default = Flags.Aimbot.FieldOfView.Color.Fill.Color,
			Transparency = Flags.Aimbot.FieldOfView.Color.Fill.Transparency,
		})
		:AddColorPicker("FOVOutlineColor", {
			Title = "FOV Outline Color",
			Default = Flags.Aimbot.FieldOfView.Color.Outline.Color,
			Transparency = Flags.Aimbot.FieldOfView.Color.Outline.Transparency,
		})
	AimbotMain:AddSlider("AimFOV", {
		Text = "Field Of View",
		Default = Flags.Aimbot.FieldOfView.Degrees,
		Min = 0,
		Max = 500,
		Rounding = 1,
		Suffix = "°",
		Compact = false,
	})
	BindToggle("DrawAimFOV", Flags.Aimbot.FieldOfView, "DrawingEnabled")
	BindColorPicker("FOVFillColor", function(Color, Transparency)
		local Fill = Flags.Aimbot.FieldOfView.Color.Fill
		Fill.Color = Color
		if Transparency then
			Fill.Transparency = Transparency
		end
	end)
	BindColorPicker("FOVOutlineColor", function(Color, Transparency)
		local Outline = Flags.Aimbot.FieldOfView.Color.Outline
		Outline.Color = Color
		if Transparency then
			Outline.Transparency = Transparency
		end
	end)
	BindOption("AimFOV", Flags.Aimbot.FieldOfView, "Degrees")

	AimbotMain:AddToggle("DrawAimDeadzoneFOV", {
		Text = "Draw Deadzone",
		Default = Flags.Aimbot.Deadzone.DrawingEnabled,
	})
		:AddColorPicker("DeadzoneFillColor", {
			Title = "Deadzone Fill Color",
			Default = Flags.Aimbot.Deadzone.Color.Fill.Color,
			Transparency = Flags.Aimbot.Deadzone.Color.Fill.Transparency,
		})
		:AddColorPicker("DeadzoneOutlineColor", {
			Title = "Deadzone Outline Color",
			Default = Flags.Aimbot.Deadzone.Color.Outline.Color,
			Transparency = Flags.Aimbot.Deadzone.Color.Outline.Transparency,
		})
	AimbotMain:AddSlider("AimDeadzoneFOV", {
		Text = "Field Of View",
		Default = Flags.Aimbot.Deadzone.Degrees,
		Min = 0,
		Max = 500,
		Rounding = 1,
		Suffix = "°",
		Compact = false,
	})
	BindToggle("DrawAimDeadzoneFOV", Flags.Aimbot.Deadzone, "DrawingEnabled")
	BindColorPicker("DeadzoneFillColor", function(Color, Transparency)
		local Fill = Flags.Aimbot.Deadzone.Color.Fill
		Fill.Color = Color
		if Transparency then
			Fill.Transparency = Transparency
		end
	end)
	BindColorPicker("DeadzoneOutlineColor", function(Color, Transparency)
		local Outline = Flags.Aimbot.Deadzone.Color.Outline
		Outline.Color = Color
		if Transparency then
			Outline.Transparency = Transparency
		end
	end)
	BindOption("AimDeadzoneFOV", Flags.Aimbot.Deadzone, "Degrees")

	AimbotMain:AddDivider()

	AimbotMain:AddSlider("AimMaxDistance", {
		Text = "Max Distance",
		Default = Flags.Aimbot.MaxDistance,
		Min = 1,
		Max = 5000,
		Rounding = 1,
		Suffix = "m",
		Compact = false,
	})
	BindOption("AimMaxDistance", Flags.Aimbot, "MaxDistance")
end

function Component:Load()
	BuildMenu()

	Cheat:Connect(RunService.Heartbeat, function()
		print(Flags.Aimbot.MaxDistance)
	end)
end
function Component:Unload() end

return Component
