-- VistaDialer Version 1.0.0
--[[
Copyright (c) 2026 Chris Chrome
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
]]

local dialer = script.Parent
local system = dialer.Parent.Parent.Parent

local config = require(dialer:WaitForChild("Configuration"))
local HttpService = game:GetService("HttpService")

local values = system:WaitForChild("Values")
local status = values:WaitForChild("Status")
local maintenanceMode = values:WaitForChild("MaintenanceMode")

--[[
	CONTACT ID QUALIFIERS

	1 = New Event / Open
	3 = New Restore / Close
	6 = Previous Event / Current Status
]]

local NEW_EVENT = 1
local RESTORE = 3
local PREVIOUS = 6

--[[
	SMARTBOOT STATUS

	1 = All Clear
	2 = Secure / HOLD
	3 = Lockdown
]]

local events = {
	[2] = {
		name = "SECURE / HOLD",
		code = 122,
	},
	[3] = {
		name = "LOCKDOWN",
		code = 123,
	},
}

-- Maintenance Mode
-- 300 = System Trouble
local MAINTENANCE_EVENT = 300

--[[
	CONTACT ID FORMAT

	ACCT + Q + XYZ + GG + CCC

	ACCT = Account Number
	Q    = Qualifier
	XYZ  = Event Code
	GG   = Group / Partition
	CCC  = Zone / User

	SmartBoot does not use partitions/groups.
	GG = 00

	System events use zone 001.
]]

local function encodeContactID(eventCode, qualifier)
	local account = string.format("%04d", config.AccountNumber)
	local q = tostring(qualifier)
	local xyz = string.format("%03d", eventCode)
	local group = "00"
	local zone = "001"

	return account .. q .. xyz .. group .. zone
end

--[[
	SEND REPORT
]]

local function sendReport(message)
	local headers = {
		["Content-Type"] = "text/plain",
		["Roblox-Job-Id"] = game.JobId ~= "" and game.JobId or "studio",
	}

	for attempt = 1, config.ReportAttempts do
		local ok, response = pcall(function()
			return HttpService:RequestAsync({
				Url = config.ReportingURL,
				Method = "POST",
				Headers = headers,
				Body = message,
			})
		end)

		if ok and response.Success then
			print("VistaDialer: Report sent:", message)
			return true
		end

		if not ok then
			warn(
				"VistaDialer: HTTP error on attempt",
				attempt,
				":",
				response
			)
		else
			warn(
				"VistaDialer: Report failed on attempt",
				attempt,
				":",
				response.StatusCode,
				response.StatusMessage,
				response.Body
			)
		end

		if attempt < config.ReportAttempts then
			task.wait(config.RetryDelay)
		end
	end

	return false
end

--[[
	SEND EVENT
]]

local function sendEvent(name, eventCode, qualifier)
	local message = encodeContactID(eventCode, qualifier)

	local qualifierName = ({
		[NEW_EVENT] = "NEW EVENT",
		[RESTORE] = "RESTORE",
		[PREVIOUS] = "PREVIOUS / STATUS",
	})[qualifier] or tostring(qualifier)

	print(
		"VistaDialer:",
		name,
		"|",
		qualifierName,
		"|",
		message
	)

	task.spawn(function()
		sendReport(message)
	end)
end

--[[
	STATUS TRACKING

	1 = All Clear
	2 = Secure / HOLD
	3 = Lockdown

	Startup:
		Do NOT send anything.

	Changes:
		1 → 2 = 122 / Qualifier 1
		2 → 1 = 122 / Qualifier 3

		1 → 3 = 123 / Qualifier 1
		3 → 1 = 123 / Qualifier 3

		2 → 3 = 122 / Qualifier 3
			   123 / Qualifier 1

		3 → 2 = 123 / Qualifier 3
			   122 / Qualifier 1
]]

local lastStatus = nil

local function processStatus(value)
	value = tonumber(value)

	if value ~= 1 and value ~= 2 and value ~= 3 then
		warn("VistaDialer: Unknown Status:", value)
		return
	end

	-- Startup
	-- Record the current state but DO NOT report it.
	if lastStatus == nil then
		lastStatus = value

		print(
			"VistaDialer: Initial status:",
			value
		)

		return
	end

	-- Nothing changed
	if lastStatus == value then
		return
	end

	-- Restore previous event
	if lastStatus ~= 1 then
		local previousEvent = events[lastStatus]

		if previousEvent then
			sendEvent(
				previousEvent.name,
				previousEvent.code,
				RESTORE
			)
		end
	end

	-- Start new event
	if value ~= 1 then
		local newEvent = events[value]

		if newEvent then
			sendEvent(
				newEvent.name,
				newEvent.code,
				NEW_EVENT
			)
		end
	else
		print("VistaDialer: ALL CLEAR")
	end

	lastStatus = value
end

--[[
	MAINTENANCE MODE

	false → true
		300 / Qualifier 1

	true → false
		300 / Qualifier 3

	Startup:
		Do NOT send anything.
]]

local lastMaintenance = nil

local function processMaintenance(value)
	value = value == true

	-- Startup
	-- Record the current state but DO NOT report it.
	if lastMaintenance == nil then
		lastMaintenance = value

		print(
			"VistaDialer: Initial maintenance state:",
			value and "ON" or "OFF"
		)

		return
	end

	-- Nothing changed
	if lastMaintenance == value then
		return
	end

	-- Maintenance started
	if value then
		sendEvent(
			"SYSTEM TROUBLE",
			MAINTENANCE_EVENT,
			NEW_EVENT
		)

		print("VistaDialer: Maintenance Mode ON")

		-- Maintenance ended
	else
		sendEvent(
			"SYSTEM TROUBLE",
			MAINTENANCE_EVENT,
			RESTORE
		)

		print("VistaDialer: Maintenance Mode OFF")
	end

	lastMaintenance = value
end

--[[
	STARTUP


print("================================")
print("VistaDialer online")
print("Account:", config.AccountNumber)
print("Current Status:", status.Value)
print("Maintenance Mode:", maintenanceMode.Value)
print("================================") ]]

-- Initialize current states.
-- These DO NOT send reports.
processStatus(status.Value)
processMaintenance(maintenanceMode.Value)

--[[
	STATUS WATCHER
]]

status.Changed:Connect(function(value)
	processStatus(value)
end)

--[[
	MAINTENANCE WATCHER
]]

maintenanceMode.Changed:Connect(function(value)
	processMaintenance(value)
end)
