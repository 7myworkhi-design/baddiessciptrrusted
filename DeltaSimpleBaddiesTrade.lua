-- Delta Executor: Baddies Simple Forced Trade
-- Ultra-simple direct execution

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

print("✅ Script Loaded - Testing...")

-- Test 1: Check if we can see players
print("Players in game: " .. #Players:GetPlayers())
for _, player in pairs(Players:GetPlayers()) do
	print("  - " .. player.Name)
end

-- Test 2: Check if LocalPlayer exists
if LocalPlayer then
	print("✅ LocalPlayer found: " .. LocalPlayer.Name)
else
	print("❌ LocalPlayer not found")
	return
end

-- Test 3: Check if we have a character
if LocalPlayer.Character then
	print("✅ Character exists")
else
	print("❌ No character")
	return
end

-- Simple function to find a player
local function findPlayer(name)
	return Players:FindFirstChild(name)
end

-- Simple function to get nearest player
local function getNearestPlayer()
	if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		return nil
	end
	
	local nearestPlayer = nil
	local nearestDistance = math.huge
	
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
			if distance < nearestDistance then
				nearestDistance = distance
				nearestPlayer = player
			end
		end
	end
	
	print("Nearest player: " .. (nearestPlayer and nearestPlayer.Name or "None") .. " (Distance: " .. math.floor(nearestDistance) .. ")")
	return nearestPlayer
end

-- Get target player's items
local function getPlayerItems(player)
	local items = {}
	
	if player.Character then
		for _, item in pairs(player.Character:GetChildren()) do
			if item:IsA("Tool") then
				table.insert(items, item.Name)
			end
		end
	end
	
	if player:FindFirstChild("Backpack") then
		for _, item in pairs(player.Backpack:GetChildren()) do
			if item:IsA("Tool") then
				table.insert(items, item.Name)
			end
		end
	end
	
	return items
end

-- Attempt forced trade
local function forceTrade(targetPlayer)
	if not targetPlayer then
		print("❌ No target player")
		return false
	end
	
	print("🔄 Attempting trade with: " .. targetPlayer.Name)
	
	-- Get items
	local items = getPlayerItems(targetPlayer)
	print("✅ Items found: " .. table.concat(items, ", "))
	
	-- Try to find RemoteEvent for trading
	local found = false
	
	-- Check ReplicatedStorage
	local rs = game:GetService("ReplicatedStorage")
	for _, obj in pairs(rs:GetDescendants()) do
		if obj:IsA("RemoteEvent") and obj.Name:match("[Tt]rade") then
			print("✅ Found RemoteEvent: " .. obj.Name)
			found = true
		end
	end
	
	if not found then
		print("⚠️  No trade RemoteEvent found - game may use different system")
	end
	
	return true
end

-- Export to globals
_G.getNearestPlayer = getNearestPlayer
_G.findPlayer = findPlayer
_G.getPlayerItems = getPlayerItems
_G.forceTrade = forceTrade

print("═══════════════════════════════════════")
print("✅ SCRIPT LOADED SUCCESSFULLY")
print("═══════════════════════════════════════")
print("Commands:")
print("  _G.getNearestPlayer()")
print("  _G.findPlayer('PlayerName')")
print("  _G.getPlayerItems(player)")
print("  _G.forceTrade(player)")
print("═══════════════════════════════════════")
