if not Ketamine then
	getgenv().Ketamine = {}
end

if Ketamine and Ketamine.IsLoaded then
	Ketamine:Notify({
		Title = "!",
		Description = "FAILED TO LOAD: Already loaded.",
	})
	return
end

function Ketamine:Notify(...)
	if Ketamine and Ketamine.Library and not Ketamine.StreamMode then
		Ketamine.Library:Notify(...)
	end
end

function Ketamine:SecureCall(Function, ...)
	if typeof(Function) ~= "function" then
		print(`[K.T]: Function expected got {typeof(Function)}`)
		return
	end

	local Success, Result = pcall(Function, ...)
	if not Success and Result then
		local Traceback = debug.traceback()
		if Ketamine.Notify then
			Ketamine:Notify({
				Title = "!",
				Description = "Exception Caught, Check F9 Logs",
			})
		end

		print(`[K.T]: Exception Caught: {Result}, Traceback: {Traceback}`)
	end
end

function Ketamine:SecureSpawn(Function, ...)
	task.spawn(Ketamine.SecureCall, Ketamine, Function, ...)
end

function Ketamine:Import(Path)
	local Success, Response = Ketamine:SecureSpawn(request, {
		Url = `{Ketamine.Repo}{Path}`,
		Method = "GET",
	})

	if not Success then
		return nil
	end

	local Function = loadstring(Response.Body)
	return typeof(Function) == "function" and Function() or nil
end

return function(Options: {
	StreamMode: boolean,
})
	if Ketamine and Ketamine.IsLoaded then
		Ketamine:Notify({
			Title = "!",
			Description = "FAILED TO LOAD: Already loaded.",
		})
		return
	end

	Ketamine.Repo = "https://raw.githubusercontent.com/gratitudee/ketamine.tranq/refs/heads/main/"
	Ketamine.IsLoaded = true
	Ketamine.StreamMode = Options.StreamMode
	Ketamine.Library = Ketamine:Import("packages/Library.luau")
	Ketamine.LibraryAddons = {
		Save = Ketamine:Import("packages/SaveManager.luau"),
		Theme = Ketamine:Import("packages/ThemeManager.luau"),
	}

	-- Top Level API
	getgenv().Entity = Ketamine:Import("modules/Components/Entity.luau")
	getgenv().Utility = Ketamine:Import("modules/Components/Utility.luau")
	getgenv().Draw = Ketamine:Import("modules/Components/Draw.luau")
	getgenv().Cheat = Ketamine:Import("modules/Components/Cheat.luau")

	-- Private Level Cheat Functions
	local Aimbot = Ketamine:Import("modules/Private/Aimbot.luau")
	local Visuals = Ketamine:Import("modules/Private/Visuals.luau")
	local Settings = Ketamine:Import("modules/Private/Settings.luau")

	local GameSupport = Ketamine:Import(`modules/Support/{game.GameId}`)
	if GameSupport then
		Ketamine.Support = GameSupport
	end

	-- Window Creation
	Ketamine.Window = Ketamine.Library:CreateWindow({
		Title = "ketamine.tranq",
		Center = true,
		AutoShow = not Ketamine.StreamMode,
		UnlockMouseWhileOpen = true,
	})

	-- Start Dependencies
	Ketamine:SecureSpawn(Entity.Load, Entity)
	Ketamine:SecureSpawn(Utility.Load, Utility)
	Ketamine:SecureSpawn(Draw.Load, Draw)
	Ketamine:SecureSpawn(Cheat.Load, Cheat)

	-- Start Features
	Ketamine:SecureSpawn(Aimbot.Load, Aimbot)
	Ketamine:SecureSpawn(Visuals.Load, Visuals)
	Ketamine:SecureSpawn(Settings.Load, Settings)

	Cheat:OnUnload(function()
		Ketamine:Notify({
			Title = "!",
			Description = "Unloading Cheat",
		})

		-- Unload Dependencies
		Ketamine:SecureSpawn(Entity.Unload, Entity)
		Ketamine:SecureSpawn(Utility.Unload, Utility)
		Ketamine:SecureSpawn(Draw.Unload, Draw)
		Ketamine:SecureSpawn(Cheat.Unload, Cheat)

		-- Unload Features
		Ketamine:SecureSpawn(Aimbot.Unload, Aimbot)
		Ketamine:SecureSpawn(Visuals.Unload, Visuals)
		Ketamine:SecureSpawn(Settings.Unload, Settings)
		Ketamine.Library:Unload()

		task.delay(1, function()
			getgenv().Ketamine = nil
		end)
	end)

	Ketamine.Library:OnUnload(function()
		Ketamine.Library.Unloaded = true
	end)
end
