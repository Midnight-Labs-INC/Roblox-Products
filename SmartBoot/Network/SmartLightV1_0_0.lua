local box=script.Parent
local root=box.Parent
local Config=require(root.Parent.Parent.Parent.Scripts.Configuration)

local values=box.Parent.Values
local poweredOn=values.PoweredOn
local led=box.Parent.LED
local status=root.Parent.Parent.Parent.Values.Status

local originalColor=led.Color
local originalMaterial=led.Material
local lightID=0

local function getColor(rgb)
	return Color3.fromRGB(
		math.clamp(tonumber(rgb[1]) or 255,0,255),
		math.clamp(tonumber(rgb[2]) or 255,0,255),
		math.clamp(tonumber(rgb[3]) or 255,0,255)
	)
end

local function updateLight()
	lightID+=1
	local id=lightID

	task.spawn(function()
		while id==lightID do
			local cfg

			if not poweredOn.Value then
				cfg=Config.SmartLight.PoweredOff
			elseif status.Value==1 then
				cfg=Config.SmartLight.Status1
			elseif status.Value==2 then
				cfg=Config.SmartLight.Status2
			elseif status.Value==3 then
				cfg=Config.SmartLight.Status3
			end

			if not Config.Enabled or not Config.SmartLight.Enabled or not cfg or not cfg.Enabled then
				led.Color=originalColor
				led.Material=originalMaterial
				return
			end

			led.Color=getColor(cfg.Color)
			led.Material=Enum.Material[cfg.Material] or originalMaterial

			task.wait(math.max(tonumber(cfg.OnDelay) or 1,.01))

			if id~=lightID then return end

			led.Color=originalColor
			led.Material=originalMaterial

			task.wait(math.max(tonumber(cfg.OffDelay) or 1,.01))
		end
	end)
end

status.Changed:Connect(updateLight)
poweredOn.Changed:Connect(updateLight)

updateLight()
