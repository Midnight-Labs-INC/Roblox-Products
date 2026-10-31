--[[
	/*******************************************************************************
	Midnight Labs | Roblox Division
	Driven by technology. Built through creativity.

	@project    SmartBoot System
	@version    1.0.0
	@license    All Rights Reserved
	@copyright  (c) 2026 Midnight Labs 
	@authors    @Midnight_Labs


	This software and associated documentation files are proprietary and confidential.
	Unauthorized copying, modification, or distribution is strictly prohibited.
	******************************************************************************/
]]

local smartBoot = script.Parent
local Config = require(smartBoot.Parent.Configuration)

local maintenanceMode = smartBoot.Parent.Parent.Values.MaintenanceMode

local legacy = smartBoot.Parent.Parent.Legacy
local rfsInt = legacy.DemoPanel

local activeAlarms = rfsInt.ActiveAlarms
local resetCommand = rfsInt.ResetCommand

local values = smartBoot.Parent.Parent.Values
local status = values and values.Status

local alarmsActive = false

local function debug(...)
	if Config.DebugLogs then
		print("[SmartBoot]", ...)
	end
end

local function setStatus(value)
	if status and status.Value ~= value then
		status.Value = value
		debug("Status changed:", value)
	end
end

local function lockdown()
	if not Config.Enabled then
		return
	end

	if maintenanceMode.Value then
		debug("Maintenance Mode - lockdown suppressed.")
		return
	end

	if not Config.StatusEvents.Lockdown then
		return
	end

	debug("LOCKDOWN ACTIVATED")
	setStatus(3)
end

local function allClear()
	if not Config.Enabled or maintenanceMode.Value then
		return
	end

	if not Config.StatusEvents.AllClear then
		return
	end

	debug("ALL CLEAR")
	setStatus(1)

	local delayTime = tonumber(Config.StatusEvents.ResetDelay) or 10

	task.delay(delayTime, function()
		if #activeAlarms:GetChildren() > 0 then
			debug("Reset cancelled - alarm is active.")
			return
		end

		if maintenanceMode.Value then
			debug("Reset cancelled - Maintenance Mode.")
			return
		end

		setStatus(0)

		if resetCommand and resetCommand:IsA("BindableEvent") then
			resetCommand:Fire()
			debug("ResetCommand fired.")
		end
	end)
end

local function checkAlarms()
	local count = #activeAlarms:GetChildren()
	local active = count > 0

	debug("Active alarms:", count)

	if active == alarmsActive then
		return
	end

	alarmsActive = active

	if active then
		lockdown()
	else
		allClear()
	end
end

activeAlarms.ChildAdded:Connect(function(child)
	debug("Alarm added:", child.Name)
	checkAlarms()
end)

activeAlarms.ChildRemoved:Connect(function(child)
	debug("Alarm removed:", child.Name)
	checkAlarms()
end)

maintenanceMode.Changed:Connect(function(value)
	debug("Maintenance Mode:", value)

	if value then
		debug("Maintenance Mode enabled.")
	else
		debug("Maintenance Mode disabled.")
		checkAlarms()
	end
end)

debug("SmartBoot Controller initialized.")
checkAlarms()
