return {
	Aimbot = {
		Enabled = false,
		KeybindHeld = false,

		SmoothnessX = 50,
		SmoothnessY = 50,

		DrawFOV = false,
		FieldOfView = 70,

		DrawDeadzone = false,
		DeadzoneFieldOfView = 0,

		AimMethod = "Mouse",
		AimStyle = "Linear",
		AimTargetting = "Closest To Crosshair",
		AimChecks = {
			Forcefield = false,
			["Local Dead"] = false,
			Invisible = false,
			Visible = false,
			Team = true,
		},
		MaxDistance = 500,
	},
	Visuals = {},
	Settings = {
		MenuKeybind = "Z",
		RaycastOrigin = "Camera",
		StreamMode = false,
		ShowWatermark = false,
		ShowKeybinds = false,

		EntityLogs = {
			Enabled = false,
			PlaySoundOnLog = false,
			SoundToPlay = nil,
			Types = {
				Added = false,
				Removed = false,
				Hit = false,
				Killed = false,
			},
		},

		Hitmarkers = {
			Enabled = false,
			AnimateHitmarker = false,
			RotationSpeed = 1,
			HitmarkerSound = false,
			HitmarkerSoundVolume = 0.3,
			SoundToPlay = nil,
		},
	},
}
