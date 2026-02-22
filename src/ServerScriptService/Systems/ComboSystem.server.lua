--[[
	ComboSystem V35 - Status Effects + Elemental Combos
	====================================================
	Si je gèle un monstre puis l'électrocute → COMBO bonus dégâts!
	
	Status Effects:
	  🔥 Brûlure (Feu) - DoT 5% HP/s pendant 5s
	  ❄️ Gel (Glace) - Ralenti 50% pendant 4s
	  ⚡ Électrocuté (Foudre) - Stun 1.5s
	  🌿 Empoisonné (Nature) - DoT 3% HP/s pendant 8s
	  💀 Maudit (Ombre) - -30% DEF pendant 6s
	  💧 Trempé (Eau) - +25% dégâts reçus pendant 5s
	
	Combos:
	  Gel + Foudre = "Givre Foudroyant" (+50% dégâts)
	  Brûlure + Gel = "Choc Thermique" (+40% dégâts + explosion)
	  Trempé + Foudre = "Électrocution" (+60% dégâts AoE)
	  Brûlure + Nature = "Feu de Forêt" (+35% dégâts AoE)
	  Maudit + n'importe quoi = "Malédiction" (+25% dégâts)
	  Empoisonné + Brûlure = "Toxique" (+45% DoT)
]]

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

print("[ComboSystem V35] Loading - Status Effects + Elemental Combos!")

local remotes = ReplicatedStorage:WaitForChild("Remotes", 15)
if not remotes then warn("[ComboSystem] No remotes!"); return end

-- Create combo remote if not exists
local comboRemote = remotes:FindFirstChild("ComboTriggered")
if not comboRemote then
	comboRemote = Instance.new("RemoteEvent")
	comboRemote.Name = "ComboTriggered"
	comboRemote.Parent = remotes
end

-- === STATUS EFFECT DEFINITIONS ===
local STATUS_EFFECTS = {
	Burn = {
		name = "🔥 Brûlure",
		element = "Feu",
		duration = 5,
		dotPercent = 0.05, -- 5% HP/s
		speedMult = 1, -- pas de ralenti
		defMult = 1,
		color = Color3.fromRGB(255, 100, 0),
	},
	Freeze = {
		name = "❄️ Gel",
		element = "Glace",
		duration = 4,
		dotPercent = 0,
		speedMult = 0.5, -- 50% slower
		defMult = 1,
		color = Color3.fromRGB(100, 200, 255),
	},
	Shock = {
		name = "⚡ Électrocuté",
		element = "Foudre",
		duration = 1.5,
		dotPercent = 0,
		speedMult = 0, -- stun!
		defMult = 1,
		color = Color3.fromRGB(255, 255, 50),
	},
	Poison = {
		name = "🌿 Empoisonné",
		element = "Nature",
		duration = 8,
		dotPercent = 0.03, -- 3% HP/s
		speedMult = 0.9,
		defMult = 1,
		color = Color3.fromRGB(50, 200, 50),
	},
	Curse = {
		name = "💀 Maudit",
		element = "Ombre",
		duration = 6,
		dotPercent = 0,
		speedMult = 1,
		defMult = 0.7, -- -30% DEF
		color = Color3.fromRGB(100, 0, 150),
	},
	Wet = {
		name = "💧 Trempé",
		element = "Eau",
		duration = 5,
		dotPercent = 0,
		speedMult = 0.85,
		defMult = 0.75, -- +25% dégâts reçus
		color = Color3.fromRGB(50, 100, 255),
	},
}

-- === COMBO DEFINITIONS ===
local COMBOS = {
	{status1 = "Freeze", status2 = "Shock", name = "⚡❄️ Givre Foudroyant", bonusDmg = 1.5, aoe = false},
	{status1 = "Burn", status2 = "Freeze", name = "🔥❄️ Choc Thermique", bonusDmg = 1.4, aoe = true, aoeRadius = 10},
	{status1 = "Wet", status2 = "Shock", name = "💧⚡ Électrocution", bonusDmg = 1.6, aoe = true, aoeRadius = 15},
	{status1 = "Burn", status2 = "Poison", name = "🔥🌿 Feu de Forêt", bonusDmg = 1.35, aoe = true, aoeRadius = 12},
	{status1 = "Poison", status2 = "Burn", name = "☠️ Toxique", bonusDmg = 1.45, aoe = false, extraDot = 0.04},
	{status1 = "Curse", status2 = "ANY", name = "💀 Malédiction", bonusDmg = 1.25, aoe = false},
	{status1 = "Wet", status2 = "Freeze", name = "💧❄️ Congélation", bonusDmg = 1.3, aoe = false, extraStun = 2},
	{status1 = "Shock", status2 = "Wet", name = "⚡💧 Tempête", bonusDmg = 1.5, aoe = true, aoeRadius = 20},
}

-- Track active status effects on monsters
local activeStatuses = {} -- [monster] = {statusName = {endTime, ...}}

-- === ELEMENT TO STATUS MAPPING ===
local ELEMENT_STATUS = {
	Feu = "Burn",
	Glace = "Freeze",
	Foudre = "Shock",
	Nature = "Poison",
	Ombre = "Curse",
	Eau = "Wet",
}

-- === APPLY STATUS EFFECT TO MONSTER ===
local function applyStatus(monster, statusName, attackerPlayer)
	if not monster or not monster.Parent then return end
	local body = monster.PrimaryPart or monster:FindFirstChild("Body")
	if not body then return end
	
	local statusDef = STATUS_EFFECTS[statusName]
	if not statusDef then return end
	
	-- Init tracking
	if not activeStatuses[monster] then activeStatuses[monster] = {} end
	
	-- Check for combo BEFORE applying
	local comboTriggered = nil
	for _, combo in ipairs(COMBOS) do
		local has1 = activeStatuses[monster][combo.status1]
		local has2 = activeStatuses[monster][combo.status2]
		
		if combo.status2 == "ANY" and has1 and statusName ~= combo.status1 then
			comboTriggered = combo
			break
		elseif combo.status1 == statusName and has2 then
			comboTriggered = combo
			break
		elseif combo.status2 == statusName and has1 then
			comboTriggered = combo
			break
		end
	end
	
	-- Apply the status
	activeStatuses[monster][statusName] = tick() + statusDef.duration
	monster:SetAttribute("Status_" .. statusName, true)
	monster:SetAttribute("StatusColor_" .. statusName, statusDef.color)
	
	-- Visual effect
	local statusPart = body:FindFirstChild("StatusEffect_" .. statusName)
	if not statusPart then
		statusPart = Instance.new("Part")
		statusPart.Name = "StatusEffect_" .. statusName
		statusPart.Size = body.Size + Vector3.new(0.5, 0.5, 0.5)
		statusPart.CFrame = body.CFrame
		statusPart.Anchored = false
		statusPart.CanCollide = false
		statusPart.Transparency = 0.7
		statusPart.Color = statusDef.color
		statusPart.Material = Enum.Material.ForceField
		statusPart.Parent = body
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = body
		weld.Part1 = statusPart
		weld.Parent = statusPart
	end
	
	-- Apply speed modifier via BodyVelocity
	local mover = body:FindFirstChild("Mover")
	if mover and statusDef.speedMult < 1 then
		-- Store original max force
		if not monster:GetAttribute("OriginalSpeed") then
			monster:SetAttribute("OriginalSpeed", mover.P)
		end
		if statusDef.speedMult == 0 then
			mover.Velocity = Vector3.new(0, 0, 0)
			mover.MaxForce = Vector3.new(0, 0, 0)
		else
			mover.MaxForce = Vector3.new(50000, 50000, 50000) * statusDef.speedMult
		end
	end
	
	-- DoT effect
	if statusDef.dotPercent > 0 then
		task.spawn(function()
			local hum = monster:FindFirstChildOfClass("Humanoid")
			local endTime = tick() + statusDef.duration
			while tick() < endTime and monster.Parent and hum and hum.Health > 0 do
				local dot = math.floor(hum.MaxHealth * statusDef.dotPercent)
				hum:TakeDamage(dot)
				-- Show damage number
				local dmgRemote = remotes:FindFirstChild("DamageNumber")
				if dmgRemote and attackerPlayer then
					dmgRemote:FireClient(attackerPlayer, body.Position, dot, false)
				end
				task.wait(1)
			end
		end)
	end
	
	-- COMBO TRIGGER!
	if comboTriggered then
		local hum = monster:FindFirstChildOfClass("Humanoid")
		if hum and hum.Health > 0 then
			local comboDmg = math.floor(hum.MaxHealth * 0.1 * comboTriggered.bonusDmg)
			hum:TakeDamage(comboDmg)
			
			-- Notify player
			if attackerPlayer then
				local dmgRemote = remotes:FindFirstChild("DamageNumber")
				if dmgRemote then
					dmgRemote:FireClient(attackerPlayer, body.Position + Vector3.new(0, 3, 0), comboDmg, true)
				end
				comboRemote:FireClient(attackerPlayer, comboTriggered.name, comboDmg)
			end
			
			-- AoE damage
			if comboTriggered.aoe and comboTriggered.aoeRadius then
				for _, obj in ipairs(game.Workspace:GetChildren()) do
					if obj:IsA("Model") and obj ~= monster and (obj.Name:match("^Wild_") or obj.Name:match("^Boss_")) then
						local oPart = obj.PrimaryPart or obj:FindFirstChild("Body")
						if oPart then
							local dist = (body.Position - oPart.Position).Magnitude
							if dist <= comboTriggered.aoeRadius then
								local oHum = obj:FindFirstChildOfClass("Humanoid")
								if oHum and oHum.Health > 0 then
									local aoeDmg = math.floor(comboDmg * 0.5)
									oHum:TakeDamage(aoeDmg)
								end
							end
						end
					end
				end
			end
			
			-- Combo visual
			local comboVisual = Instance.new("Part")
			comboVisual.Name = "ComboExplosion"
			comboVisual.Shape = Enum.PartType.Ball
			comboVisual.Size = Vector3.new(2, 2, 2)
			comboVisual.Position = body.Position
			comboVisual.Anchored = true
			comboVisual.CanCollide = false
			comboVisual.Transparency = 0.3
			comboVisual.Color = statusDef.color
			comboVisual.Material = Enum.Material.Neon
			comboVisual.Parent = game.Workspace
			
			-- Expand and fade
			task.spawn(function()
				for i = 1, 15 do
					comboVisual.Size = comboVisual.Size + Vector3.new(1, 1, 1)
					comboVisual.Transparency = 0.3 + i * 0.045
					task.wait(0.03)
				end
				comboVisual:Destroy()
			end)
			
			-- Clear both statuses after combo
			activeStatuses[monster][comboTriggered.status1] = nil
			if comboTriggered.status2 ~= "ANY" then
				activeStatuses[monster][comboTriggered.status2] = nil
			end
			monster:SetAttribute("Status_" .. comboTriggered.status1, nil)
			
			print("[ComboSystem] " .. comboTriggered.name .. " ! " .. comboDmg .. " bonus damage!")
		end
	end
	
	-- Clean up status after duration
	task.delay(statusDef.duration, function()
		if monster.Parent and activeStatuses[monster] then
			activeStatuses[monster][statusName] = nil
			monster:SetAttribute("Status_" .. statusName, nil)
			
			-- Remove visual
			if body.Parent then
				local sp = body:FindFirstChild("StatusEffect_" .. statusName)
				if sp then sp:Destroy() end
			end
			
			-- Restore speed
			if statusDef.speedMult < 1 then
				local mover2 = body:FindFirstChild("Mover")
				if mover2 then
					mover2.MaxForce = Vector3.new(50000, 50000, 50000)
				end
			end
		end
	end)
end

-- === LISTEN FOR ATTACKS WITH ELEMENTS ===
-- Hook into the damage system - when a player attacks with an elemental weapon/skill
local attackRemote = remotes:FindFirstChild("PlayerAttack")
if attackRemote then
	attackRemote.OnServerEvent:Connect(function(player, targetMonster, element)
		if not targetMonster or not targetMonster.Parent then return end
		
		-- Map element to status
		local statusName = ELEMENT_STATUS[element]
		if statusName then
			-- 40% chance to apply status on hit
			if math.random() < 0.4 then
				applyStatus(targetMonster, statusName, player)
			end
		end
	end)
end

-- === CLEANUP ===
game.Workspace.ChildRemoved:Connect(function(child)
	if activeStatuses[child] then
		activeStatuses[child] = nil
	end
end)

print("[ComboSystem V35] Ready! 6 status effects + 8 elemental combos!")
