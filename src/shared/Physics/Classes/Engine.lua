local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared
local GameData = Shared.GameData

local VISUAL_CLASS_NAMES = {
	"Decal";
	"ImageLabel";
	"PointLight";
	"Beam";
}

local THROTTLE_MAX = 100
local VISUAL_TEMP_MAX = 100

local function ThrottleNormalized(self)
	return self.Throttle / THROTTLE_MAX
end

local function GetWidth(Angle, Height)
	local OtherAngle = 180 - (Angle + 90)
	return Height / math.tan(math.rad(OtherAngle))
end

local Engine = {}
Engine.__index = Engine

local function UpdateBeamEnd(self)
	local NozzleHeight = self.Model.Nozzle.Size.Y

	local NewDistance = 32 + (96 * ThrottleNormalized(self))
	self.Model.Nozzle.BeamEnd.Position = Vector3.new(math.noise(1, 0, (self.__runtime * 32)), -NewDistance, math.noise(0, 1, (self.__runtime * 32)))
	return NewDistance
end

local function UpdateBeams(self)
	local Height = UpdateBeamEnd(self)
	local Angle = math.clamp(self.VisualAngle, 1, 75)

	local Result = GetWidth(Angle, Height)

	for _, Beam in self.Model:GetDescendants() do
		if Beam:IsA("Beam") then
			local s = (Result * 2) + (Beam.Width0 / 2)
			if Beam:FindFirstChild("Divisor") then
				s = s / Beam.Divisor.Value
			end
			Beam.Width1 = s
		end
	end
end

local function CheckInstanceIfItsA(Instance: Instance, ClassNames: Array<string>): boolean | string
	for _, ClassName in ClassNames do
		if Instance:IsA(ClassName) then
			return ClassName
		end
	end

	return false
end

local function FindOrInstantiateDefaultValue(Effect, Index)
	local DefaultValue = Effect:FindFirstChild("DefaultValue")
	if not DefaultValue then
		DefaultValue = Instance.new("NumberValue", Effect)
		DefaultValue.Name = "DefaultValue"
		DefaultValue.Value = Effect[Index]
	end
	return DefaultValue
end

local function UpdateEffects(self, Effect, Value)
	if Value == "PointLight" then
		if Effect.Name == "Throttle" then end
		if Effect.Name == "Flare" then end

		if Effect.Name == "Temperature" then
			local DefaultValue = FindOrInstantiateDefaultValue(Effect, "Brightness")

			Effect.Brightness = DefaultValue.Value * (self.VisualTemp / VISUAL_TEMP_MAX)
		end
	elseif Value == "Beam" then
		if Effect.Name == "Throttle" then
			local DefaultValue = FindOrInstantiateDefaultValue(Effect, "Brightness")

			Effect.Brightness = (not self.Activated and 0) or (DefaultValue.Value * (self.Throttle / THROTTLE_MAX))
		end

		if Effect.Name == "Flare" then
			local DefaultValue = FindOrInstantiateDefaultValue(Effect, "Brightness")

			Effect.Brightness = (not self.Activated and 0) or (DefaultValue.Value * (self.Throttle / THROTTLE_MAX)) - math.clamp((math.noise(1, 1, (self.__runtime * 8))), 0, 0.5)
		end
	elseif Value == "ImageLabel" then
		if Effect.Name == "Throttle" then end

		if Effect.Name == "Flare" then
			local DefaultValue = FindOrInstantiateDefaultValue(Effect, "ImageTransparency")

			Effect.ImageTransparency = (not self.Activated and 1) or (1 - (self.Throttle / THROTTLE_MAX)) - ((math.noise(1, 1, (self.__runtime * 8)) * 0.1) - 0.1)
		end

		if Effect.Name == "Temperature" then end
	elseif Value == "Decal" then
		if Effect.Name == "Throttle" then end
		if Effect.Name == "Flare" then end
		if Effect.Name == "Temperature" then
			Effect.Transparency = 1 - (self.VisualTemp / VISUAL_TEMP_MAX)
		end
	end
end

function Engine:Update(deltaTime)
	local scaledDeltaTime = deltaTime * 60
	self.__runtime = self.__runtime + deltaTime

	self.VisualTemp = math.clamp((not self.Activated) and (self.VisualTemp - (5 * scaledDeltaTime)) or (self.VisualTemp + ((self.Throttle / 50) * scaledDeltaTime)), 0, VISUAL_TEMP_MAX)

	for _, Effect: Instance | PointLight in self.Model:GetDescendants() do
		local Value = CheckInstanceIfItsA(Effect, VISUAL_CLASS_NAMES)

		if Value ~= false then
			UpdateEffects(self, Effect, Value)
		end
	end

	UpdateBeams(self)
end

function Engine:ThrottleValue(newThrottleValue)
	self.Throttle = newThrottleValue
end

function Engine:Toggle(bool)
	self.Activated = bool;
end

function Engine.new(name: string, model: Model)
	local self = setmetatable({
		__runtime = 0;

		Activated = false;

		Throttle = 0; -- 0-100 (sorry i hate floats)
		VisualTemp = 0; -- 0-100
		VisualAngle = 45;

		Stats = require(GameData.Parts.Engines[name]);
		Model = model
	}, Engine)

	return self
end

return Engine