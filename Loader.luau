getgenv().Repo = "https://raw.githubusercontent.com/gratitudee/ketamine.tranq/refs/heads/main/"

getgenv().SecureCall = function(f, ...)
	if typeof(f) ~= "function" then
		print(...)
		print(`[KETAMINE.TRANQ]: Function expected got {typeof(f)}`)
		return
	end

	local Success, Result = pcall(f, ...)
	if not Success and Result then
		local Traceback = debug.traceback()
		print(`[KETAMINE.TRANQ]: Exception Caught: {Result}, Traceback:\n{Traceback}`)
	end

	return Success, Result
end

getgenv().SecureSpawn = function(f, ...)
	print(...)
	task.spawn(SecureCall, f, ...)
end

getgenv().Import = function(ModulePath)
	local Success, Response = SecureCall(request, {
		Url = `{Repo}{ModulePath}`,
		Method = "GET",
	})

	if not Success then
		return nil
	end

	local Function = loadstring(Response.Body)
	return Function and typeof(Function) == "function" and Function() or nil
end

getgenv().DebugNotify = function(Message)
	if not Message then
		return
	end

	-- Silent Mode
	if not Ketamine or Ketamine.StealthMode then
		return
	end

	if Library then
		Library:Notify(Message, 3)
	end
end

return function(LaunchOptions: {
	StealthMode: boolean,
})
	if Ketamine and Ketamine.Loaded then
		DebugNotify("Failed to load, already loaded.")
		return
	end

	getgenv().Ketamine = {
		Loaded = true,
		StealthMode = LaunchOptions and LaunchOptions.StealthMode or false,
		Interface = {
			Library = Import("Packages/Library.luau"),
			SaveManager = Import("Packages/SaveManager.luau"),
			ThemeManager = Import("Packages/ThemeManager.luau"),
		},
		Modules = {
			Cheat = Import("Modules/Cheat.luau"),
			Entity = Import("Modules/Entity.luau"),
			Utility = Import("Modules/Utility.luau"),
		},
	}

	local Source = Import("Source.luau")

	task.delay(1, function()
		Source:OnUnload(function()
			Ketamine.Interface.Library:Unload()
			Ketamine.Loaded = false
			getgenv().Ketamine = nil
		end)
		Source:Load()
	end)
end
