local box=script.Parent
local root=box.Parent
local Config=require(root.Parent.Parent.Parent.Scripts.Configuration)

local values=box.Parent.Values
local poweredOn=values.PoweredOn
local smartValue=values.SmartValue
local lock=box.Parent.Lock

local led=box.Parent.LED
local speaker=box.Parent.Speaker
local status=root.Parent.Parent.Parent.Values.Status

local originalColor=led.Color
local originalMaterial=led.Material
local currentSound
local lightID=0
local lastStatus=status.Value
local lockDebounce=false

local function debug(...)
	if Config.DebugLogs then print("[SmartBoot]["..box.Name.."]",...) end
end

local function getColor(rgb)
	if type(rgb)~="table" then return originalColor end
	return Color3.fromRGB(
		math.clamp(tonumber(rgb[1]) or 255,0,255),
		math.clamp(tonumber(rgb[2]) or 255,0,255),
		math.clamp(tonumber(rgb[3]) or 255,0,255)
	)
end

local function getMaterial(name)
	return Enum.Material[name] or originalMaterial
end

local function stopSound()
	if currentSound then
		currentSound:Stop()
		currentSound:Destroy()
		currentSound=nil
	end
end

local function playSound(name)
	if not Config.Enabled or not poweredOn.Value then return end
	if not Config.Sounds or not Config.Sounds.Enabled then return end

	local source=Config.Sounds[name]

	if not source then
		debug("NO SOUND:",name)
		return
	end

	if not source:IsA("Sound") then
		debug("NOT A SOUND:",name)
		return
	end

	stopSound()

	currentSound=source:Clone()
	currentSound.Parent=speaker
	currentSound.Looped=false

	debug("Playing:",name,"ID:",currentSound.SoundId,"Volume:",currentSound.Volume)

	currentSound:Play()

	local sound=currentSound

	sound.Ended:Connect(function()
		if currentSound==sound then
			sound:Destroy()
			currentSound=nil
		end
	end)
end

local function playLockSound()
	if not Config.Enabled then return end
	if not Config.Sounds or not Config.Sounds.Enabled then return end

	local source=Config.Sounds.Lock

	if not source then
		debug("NO LOCK SOUND")
		return
	end

	if not source:IsA("Sound") then
		debug("LOCK IS NOT A SOUND")
		return
	end

	local sound=source:Clone()
	sound.Parent=speaker
	sound.Looped=false
	sound:Play()

	debug("Playing Lock Sound:",sound.SoundId)

	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

local function resetLED()
	led.Color=originalColor
	led.Material=originalMaterial
end

local function getLightConfig()
	if not Config.Enabled or not Config.SmartLight.Enabled then
		return nil
	end

	if not poweredOn.Value then
		return Config.SmartLight.PoweredOff
	end

	local s=tonumber(status.Value) or 0

	if s==1 then return Config.SmartLight.Status1 end
	if s==2 then return Config.SmartLight.Status2 end
	if s==3 then return Config.SmartLight.Status3 end

	return nil
end

local function updateLight()
	lightID+=1
	local id=lightID

	task.spawn(function()
		while id==lightID do
			local cfg=getLightConfig()

			if not cfg or not cfg.Enabled then
				resetLED()
				return
			end

			led.Color=getColor(cfg.Color)
			led.Material=getMaterial(cfg.Material)

			task.wait(math.max(tonumber(cfg.OnDelay) or 1,.01))

			if id~=lightID then return end

			resetLED()

			task.wait(math.max(tonumber(cfg.OffDelay) or 1,.01))
		end
	end)
end

local function statusSound(value)
	if value==0 then
		playSound("Ready")
	elseif value==1 then
		playSound("AllClear")
	elseif value==2 then
		playSound("SecureMode")
	elseif value==3 then
		playSound("Lockdown")
	end
end

status.Changed:Connect(function(value)
	if value==lastStatus then return end

	lastStatus=value

	debug("Status:",value)

	updateLight()
	statusSound(value)
end)

poweredOn.Changed:Connect(function(value)
	debug("PoweredOn:",value)

	if not value then
		stopSound()
	end
	updateLight()
end)

local clickDetector = lock:FindFirstChildOfClass("ClickDetector")

if not clickDetector then
	warn("No ClickDetector found inside lock!")
	return
end

clickDetector.MouseClick:Connect(function(player)
	if lockDebounce then
		return
	end

	-- Check both equipped tools and inventory
	local character = player.Character
	local backpack = player:FindFirstChildOfClass("Backpack")

	local tool = nil

	if character then
		tool = character:FindFirstChild("SmartBoot Key")
	end

	if not tool and backpack then
		tool = backpack:FindFirstChild("SmartBoot Key")
	end

	-- Player doesn't have the key
	if not tool or not tool:IsA("Tool") then
		return
	end

	lockDebounce = true

	poweredOn.Value = not poweredOn.Value
	playLockSound()

	debug("SmartBoot Key used by:", player.Name, "PoweredOn:", poweredOn.Value)

	task.wait(0.5)
	lockDebounce = false
end)


debug(
	"Loaded:",
	smartValue and smartValue.Value or box.Name,
	"Status:",status.Value,
	"PoweredOn:",poweredOn.Value
)

updateLight()

task.defer(function()
	statusSound(status.Value)
end)
