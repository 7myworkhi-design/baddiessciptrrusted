-- Delta Executor: Baddies Forced Trade Script
-- Direct execution - paste into Delta executor

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Configuration
local FORCE_TRADE_COOLDOWN = 30
local KEYBIND = Enum.KeyCode.F -- Press F to trigger

-- Track cooldowns
local tradeTimeouts = {}
local activeForces = {}

-- Get all weapons from a player
local function getPlayerWeapons(player)
	local weapons = {}
	
	if player.Character then
		for _, item in pairs(player.Character:GetChildren()) do
			if item:IsA("Tool") then
				table.insert(weapons, item)
			end
		end
	end
	
	if player:FindFirstChild("Backpack") then
		for _, item in pairs(player.Backpack:GetChildren()) do
			if item:IsA("Tool") then
				table.insert(weapons, item)
			end
		end
	end
	
	return weapons
end

-- Force weapons to trade
local function forceWeaponsToTrade(targetPlayer)
	local weapons = getPlayerWeapons(targetPlayer)
	local weaponNames = {}
	
	for _, weapon in pairs(weapons) do
		table.insert(weaponNames, weapon.Name)
		-- Force equip/move weapon
		if weapon.Parent == targetPlayer.Backpack then
			weapon.Parent = targetPlayer.Character
		end
	end
	
	return weapons, weaponNames
end

-- Force accept trade
local function forceAcceptTrade(targetPlayer)
	task.wait(0.5)
	
	-- Find trade GUI
	local playerGui = targetPlayer:FindFirstChild("PlayerGui")
	if not playerGui then return false end
	
	-- Search for trade window
	for _, gui in pairs(playerGui:GetDescendants()) do
		if gui:IsA("GuiButton") and (gui.Name:match("Accept") or gui.Name:match("Confirm") or gui.Name:match("Trade")) then
			gui:Activate()
			return true
		end
	end
	
	return false
end

-- Main forced trade function
local function executeForcedTrade(targetPlayer)
	if not targetPlayer or not Players:FindFirstChild(targetPlayer.Name) then
		warn("❌ Target player not found")
		return false
	end
	
	if targetPlayer == LocalPlayer then
		warn("❌ Cannot trade with yourself")
		return false
	end
	
	-- Check cooldown
	if tradeTimeouts[targetPlayer.UserId] and tradeTimeouts[targetPlayer.UserId] > tick() then
		warn("⏳ Player on cooldown: " .. tostring(math.ceil(tradeTimeouts[targetPlayer.UserId] - tick())) .. "s")
		return false
	end
	
	if activeForces[targetPlayer.UserId] then
		warn("❌ Player already in forced trade")
		return false
	end
	
	print("🔄 Starting forced trade with: " .. targetPlayer.Name)
	activeForces[targetPlayer.UserId] = true
	
	-- Force weapons
	local weapons, weaponNames = forceWeaponsToTrade(targetPlayer)
	print("✅ Forced " .. #weapons .. " weapons: " .. table.concat(weaponNames, ", "))
	
	task.wait(0.3)
	
	-- Force accept
	local accepted = forceAcceptTrade(targetPlayer)
	print("✅ Trade accepted: " .. tostring(accepted))
	
	-- Set cooldown
	tradeTimeouts[targetPlayer.UserId] = tick() + FORCE_TRADE_COOLDOWN
	activeForces[targetPlayer.UserId] = nil
	
	return true
end

-- Find nearest player (for easy targeting)
local function getNearestPlayer()
	local nearestPlayer = nil
	local nearestDistance = math.huge
	
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
			if distance < nearestDistance then
				nearestDistance = distance
				nearestPlayer = player
			end
		end
	end
	
	return nearestPlayer
end

-- Keybind listener
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == KEYBIND then
		local target = getNearestPlayer()
		if target then
			executeForcedTrade(target)
		else
			warn("❌ No players nearby")
		end
	end
end)

-- Export functions
_G.ForcedTrade = executeForcedTrade
_G.GetNearestPlayer = getNearestPlayer
_G.GetPlayerWeapons = getPlayerWeapons

print("═══════════════════════════════════════")
print("🔥 DELTA BADDIES FORCED TRADE LOADED 🔥")
print("═══════════════════════════════════════")
print("📌 Press F to force trade nearest player")
print("📌 Or use: _G.ForcedTrade(player)")
print("═══════════════════════════════════════")
