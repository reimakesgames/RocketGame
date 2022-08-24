local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared
local GameData = Shared.GameData

local Physics = {}

local function InitializeDataFolder(part: Model)
	GameData:FindFirstDescendant(part.Name)
end

function Physics.addSubassembly(assembly: Model)
	
end

return Physics