-- Detach and initialize a Lycoris instance.
local Lycoris = { queued = false, silent = false, dpscanning = false }

---@module Menu
local Menu = require("Menu")

---@module Features
local Features = require("Features")

---@module Utility.ControlModule
local ControlModule = require("Utility/ControlModule")

---@module Game.Timings.SaveManager
local SaveManager = require("Game/Timings/SaveManager")

---@module Utility.Maid
local Maid = require("Utility/Maid")

---@module Utility.Signal
local Signal = require("Utility/Signal")

---@module Game.Timings.ModuleManager
local ModuleManager = require("Game/Timings/ModuleManager")

---@module Utility.CoreGuiManager
local CoreGuiManager = require("Utility/CoreGuiManager")

---@module Utility.PersistentData
local PersistentData = require("Utility/PersistentData")

---@module Game.PlayerScanning
local PlayerScanning = require("Game/PlayerScanning")

---@module Game.Keybinding
local Keybinding = require("Game/Keybinding")

-- Lycoris maid.
local lycorisMaid = Maid.new()

-- Constants.
local LOBBY_PLACE_ID = 14067600077

-- Services.
local playersService = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")

-- Timestamp.
local startTimestamp = os.clock()

---Initialize instance.
function Lycoris.init()
	local localPlayer = nil

	repeat
		task.wait()
	until game:IsLoaded()

	repeat
		localPlayer = playersService.LocalPlayer
	until localPlayer ~= nil

	PersistentData.init()

	if isfile and isfile("smarker_ts.txt") then
		Lycoris.silent = true
	end

	if isfile and isfile("dpscanning_ts.txt") then
		Lycoris.dpscanning = true
	end

	if script_key and queue_on_teleport and not Lycoris.queued and not no_queue_on_teleport then
		local scriptKeyQueueString = string.format("script_key = '%s'", script_key or "N/A")
		local loadStringQueueString =
			'loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/0216eb5f95556e660be56009441409ae.lua"))()'
		queue_on_teleport(scriptKeyQueueString .. "\n" .. loadStringQueueString)
		Lycoris.queued = true
	end

	local tslot = PersistentData.get("tslot")
	local tdestination = PersistentData.get("tdestination")

	if game.PlaceId == LOBBY_PLACE_ID and tslot and tdestination then
		local remotes = replicatedStorage:WaitForChild("Remotes")
		local chooseSlotRemote = remotes:WaitForChild("ChooseSlot")
		local teleportRemote = remotes:WaitForChild("Teleport")

		chooseSlotRemote:InvokeServer(tslot, nil)
		teleportRemote:InvokeServer({ teleportTo = tdestination })
	end

	PersistentData.set("tslot", nil)
	PersistentData.set("tdestination", nil)

	if game.PlaceId == LOBBY_PLACE_ID then
		return
	end

	local remotes = replicatedStorage:WaitForChild("Remotes")
	local vastoVfx = remotes:FindFirstChild("VastoVfx")

	if vastoVfx then
		vastoVfx:Destroy()
	end

	PlayerScanning.init()
	Keybinding.init()
	CoreGuiManager.set()
	SaveManager.init()
	ModuleManager.refresh()
	ControlModule.init()
	Features.init()
	Menu.init()
end

---Detach instance.
function Lycoris.detach()
	lycorisMaid:clean()

	PlayerScanning.detach()
	Keybinding.detach()
	ModuleManager.detach()
	SaveManager.detach()
	Menu.detach()
	ControlModule.detach()
	Features.detach()
	CoreGuiManager.clear()
end

-- Return Lycoris module.
return Lycoris
