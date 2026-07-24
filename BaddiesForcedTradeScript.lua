-- Delta Roblox Game: Baddies Forced Trade Script
-- Forces enemy to automatically put down all items and accept trade

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Configuration
local TRADE_DURATION = 8
local TRADE_COOLDOWN = 20

-- Create RemoteEvents for client-server communication
local ForcedTradeEvent = Instance.new("RemoteEvent")
ForcedTradeEvent.Name = "ForcedTrade"
ForcedTradeEvent.Parent = ReplicatedStorage

local ForceItemDrop = Instance.new("RemoteEvent")
ForceItemDrop.Name = "ForceItemDrop"
ForceItemDrop.Parent = ReplicatedStorage

local ForceTradeAccept = Instance.new("RemoteEvent")
ForceTradeAccept.Name = "ForceTradeAccept"
ForceTradeAccept.Parent = ReplicatedStorage

-- Tables to track state
local tradeCooldowns = {}
local activeForces = {}

-- Function to get all items from a player
local function getAllPlayerItems(player)
	local items = {}
	
	-- Check in Backpack
	if player:FindFirstChild("Backpack") then
		for _, item in pairs(player.Backpack:GetChildren()) do
			table.insert(items, item)
		end
	end
	
	-- Check in character
	if player.Character then
		for _, item in pairs(player.Character:GetChildren()) do
			if item:IsA("Tool") or item:IsA("Model") then
				table.insert(items, item)
			end
		end
	end
	
	return items
end

-- Function to force drop all items
local function forceDropAllItems(targetPlayer)
	local items = getAllPlayerItems(targetPlayer)
	
	for _, item in pairs(items) do
		if item:FindFirstChild("Humanoid") == nil then -- Don't drop character parts
			item.Parent = workspace
		end
	end
	
	return #items
end

-- Function to initiate forced trade
local function initiateForcedTrade(tradingPlayer, targetPlayer)
	if not targetPlayer or not Players:FindFirstChild(targetPlayer.Name) then
		return false, "Target player not found"
	end
	
	if activeForces[targetPlayer.UserId] then
		return false, "Target already in forced trade"
	end
	
	if tradeCooldowns[tradingPlayer.UserId] and tradeCooldowns[tradingPlayer.UserId] > tick() then
		return false, "Trade on cooldown"
	end
	
	-- Mark as active
	activeForces[targetPlayer.UserId] = true
	
	-- Force drop all items
	local itemsDropped = forceDropAllItems(targetPlayer)
	
	-- Force accept trade on client side
	ForceTradeAccept:FireClient(targetPlayer, tradingPlayer.Name, itemsDropped)
	ForceTradeAccept:FireClient(tradingPlayer, targetPlayer.Name, itemsDropped)
	
	-- Set cooldown
	tradeCooldowns[tradingPlayer.UserId] = tick() + TRADE_COOLDOWN
	
	-- Clear active force after trade duration
	task.wait(TRADE_DURATION)
	activeForces[targetPlayer.UserId] = nil
	
	return true, "Forced trade completed!"
end

-- Server event handler
ForcedTradeEvent.OnServerEvent:Connect(function(player, targetPlayerName)
	local targetPlayer = Players:FindFirstChild(targetPlayerName)
	
	if targetPlayer then
		local success, message = initiateForcedTrade(player, targetPlayer)
		ForcedTradeEvent:FireClient(player, success, message)
	else
		ForcedTradeEvent:FireClient(player, false, "Target not found")
	end
end)

print("Delta Forced Trade Script loaded!")
print("Features: Force item drop + Auto-accept trade")
