--[[
	ClassSystem V35 - Classe dès le DEBUT + Système de Renaissance
	===============================================================
	- Le joueur CHOISIT sa classe au début (pas après level 10)
	- La classe détermine le monstre starter
	- Système de Renaissance (R0 → R10)
	- Chaque renaissance donne: nom de classe évolué, bonus stats, points talent
	
	Classes et évolutions:
	  Guerrier → Chevalier → Paladin → Champion → Légende
	  Mage → Sorcier → Archimage → Sage → Transcendant  
	  Archer → Chasseur → Sniper → Tireur d'élite → Oeil divin
	  Moine → Prêtre → Évêque → Cardinal → Divin
]]

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PlayerDataService = require(ServerScriptService.Services.PlayerDataService)
local GameConfig = require(ReplicatedStorage.Data.GameConfig)

print("[ClassSystem V35] Loading - Class from START + Rebirth system!")

-- === DEFINITIONS DES CLASSES ===
local CLASS_DATA = {
	Guerrier = {
		emoji = "⚔️",
		color = Color3.fromRGB(200, 50, 50),
		starterMonster = "flameguard",
		description = "Force brute, haute défense",
		baseBonus = {ATK = 5, DEF = 3, Vitality = 2},
		rebirthNames = {"Guerrier", "Chevalier", "Paladin", "Champion", "Légende"},
		rebirthBonusPer = {ATK = 3, DEF = 2, Vitality = 1},
	},
	Mage = {
		emoji = "🔮",
		color = Color3.fromRGB(100, 50, 200),
		starterMonster = "voltsprite",
		description = "Puissance magique, AoE",
		baseBonus = {ATK = 7, DEF = 1, Vitality = 1},
		rebirthNames = {"Mage", "Sorcier", "Archimage", "Sage", "Transcendant"},
		rebirthBonusPer = {ATK = 4, DEF = 1, Vitality = 1},
	},
	Archer = {
		emoji = "🏹",
		color = Color3.fromRGB(40, 160, 40),
		starterMonster = "shadeveil",
		description = "Distance, précision, flèches infinies",
		baseBonus = {ATK = 4, DEF = 1, Agility = 5},
		rebirthNames = {"Archer", "Chasseur", "Sniper", "Tireur d'élite", "Oeil divin"},
		rebirthBonusPer = {ATK = 2, Agility = 4, DEF = 0},
	},
	Moine = {
		emoji = "🙏",
		color = Color3.fromRGB(255, 220, 50),
		starterMonster = "aquashell",
		description = "Sustain, soins, support",
		baseBonus = {ATK = 2, DEF = 4, Vitality = 4},
		rebirthNames = {"Moine", "Prêtre", "Évêque", "Cardinal", "Divin"},
		rebirthBonusPer = {DEF = 3, Vitality = 3, ATK = 1},
	},
}

-- === REBIRTH CONFIG ===
local REBIRTH_CONFIG = {
	maxRebirth = 10,
	levelRequired = 50,
	levelRequiredPerRebirth = 10,
	goldCost = 1000,
	goldCostMultiplier = 2,
	talentPointsPerRebirth = 3,
	statBonusPerRebirth = 5,
}

local function getClassTitle(className, rebirthLevel)
	local data = CLASS_DATA[className]
	if not data then return className end
	local names = data.rebirthNames
	local tierIndex = math.min(math.floor(rebirthLevel / 2) + 1, #names)
	return names[tierIndex]
end

local function getRebirthBonus(className, rebirthLevel)
	local data = CLASS_DATA[className]
	if not data then return {} end
	local bonus = {}
	for stat, perLevel in pairs(data.rebirthBonusPer) do
		bonus[stat] = perLevel * rebirthLevel
	end
	bonus.GlobalPercent = rebirthLevel * REBIRTH_CONFIG.statBonusPerRebirth
	return bonus
end

local remotes = ReplicatedStorage:WaitForChild("Remotes", 15)
if not remotes then warn("[ClassSystem V35] No remotes!"); return end

-- === HANDLER: Choisir classe ===
local chooseClassRemote = remotes:WaitForChild("ChangeClass", 10)
if chooseClassRemote then
	chooseClassRemote.OnServerEvent:Connect(function(player, className)
		if not CLASS_DATA[className] then return end
		local data = PlayerDataService:GetData(player)
		if not data then return end
		
		local isFirstChoice = (data.CurrentClass == "Novice" or data.CurrentClass == nil)
		
		data.CurrentClass = className
		if not data.ClassLevels[className] then data.ClassLevels[className] = 1 end
		if not data.ClassXP[className] then data.ClassXP[className] = 0 end
		
		player:SetAttribute("CurrentClass", className)
		player:SetAttribute("PlayerLevel", data.ClassLevels[className])
		
		local classData = CLASS_DATA[className]
		player:SetAttribute("ClassEmoji", classData.emoji)
		
		local rebirthLevel = data.PlayerRebirths or 0
		local title = getClassTitle(className, rebirthLevel)
		player:SetAttribute("ClassTitle", title)
		
		local rBonus = getRebirthBonus(className, rebirthLevel)
		player:SetAttribute("RebirthBonusATK", rBonus.ATK or 0)
		player:SetAttribute("RebirthBonusDEF", rBonus.DEF or 0)
		player:SetAttribute("RebirthBonusPercent", rBonus.GlobalPercent or 0)
		
		if isFirstChoice and classData.starterMonster then
			data.PendingStarterSpecies = classData.starterMonster
			local requestStarter = remotes:FindFirstChild("RequestStarter")
			if requestStarter then requestStarter:FireClient(player) end
		end
		
		local notify = remotes:FindFirstChild("NotifyPlayer")
		if notify then notify:FireClient(player, classData.emoji .. " Classe: " .. title .. "!") end
		print("[ClassSystem V35] " .. player.Name .. " → " .. title .. " (R" .. rebirthLevel .. ")")
	end)
end

-- === HANDLER: Rebirth ===
local rebirthRemote = remotes:FindFirstChild("RequestRebirth")
if not rebirthRemote then
	rebirthRemote = Instance.new("RemoteEvent")
	rebirthRemote.Name = "RequestRebirth"
	rebirthRemote.Parent = remotes
end

rebirthRemote.OnServerEvent:Connect(function(player)
	local data = PlayerDataService:GetData(player)
	if not data then return end
	
	local currentRebirth = data.PlayerRebirths or 0
	if currentRebirth >= REBIRTH_CONFIG.maxRebirth then
		local n = remotes:FindFirstChild("NotifyPlayer")
		if n then n:FireClient(player, "❌ Renaissance max! (R" .. REBIRTH_CONFIG.maxRebirth .. ")") end
		return
	end
	
	local reqLevel = REBIRTH_CONFIG.levelRequired + (currentRebirth * REBIRTH_CONFIG.levelRequiredPerRebirth)
	local currentLevel = data.ClassLevels[data.CurrentClass] or 1
	if currentLevel < reqLevel then
		local n = remotes:FindFirstChild("NotifyPlayer")
		if n then n:FireClient(player, "❌ Niveau " .. reqLevel .. " requis! (actuel: " .. currentLevel .. ")") end
		return
	end
	
	local goldCost = math.floor(REBIRTH_CONFIG.goldCost * (REBIRTH_CONFIG.goldCostMultiplier ^ currentRebirth))
	local totalGold = data.GoldWallet + data.GoldBank
	if totalGold < goldCost then
		local n = remotes:FindFirstChild("NotifyPlayer")
		if n then n:FireClient(player, "❌ " .. goldCost .. " or requis! (actuel: " .. totalGold .. ")") end
		return
	end
	
	-- REBIRTH!
	local toDeduct = goldCost
	local fromWallet = math.min(data.GoldWallet, toDeduct)
	data.GoldWallet = data.GoldWallet - fromWallet
	toDeduct = toDeduct - fromWallet
	if toDeduct > 0 then data.GoldBank = data.GoldBank - toDeduct end
	
	data.PlayerRebirths = currentRebirth + 1
	data.ClassLevels[data.CurrentClass] = 1
	data.ClassXP[data.CurrentClass] = 0
	data.TalentPoints = (data.TalentPoints or 0) + REBIRTH_CONFIG.talentPointsPerRebirth
	
	local newTitle = getClassTitle(data.CurrentClass, data.PlayerRebirths)
	player:SetAttribute("PlayerRebirths", data.PlayerRebirths)
	player:SetAttribute("PlayerLevel", 1)
	player:SetAttribute("PlayerXP", 0)
	player:SetAttribute("ClassTitle", newTitle)
	player:SetAttribute("TalentPoints", data.TalentPoints)
	
	local rBonus = getRebirthBonus(data.CurrentClass, data.PlayerRebirths)
	player:SetAttribute("RebirthBonusATK", rBonus.ATK or 0)
	player:SetAttribute("RebirthBonusDEF", rBonus.DEF or 0)
	player:SetAttribute("RebirthBonusPercent", rBonus.GlobalPercent or 0)
	
	local n = remotes:FindFirstChild("NotifyPlayer")
	if n then n:FireClient(player, "🌟 RENAISSANCE " .. data.PlayerRebirths .. "! → " .. newTitle .. "! +" .. REBIRTH_CONFIG.talentPointsPerRebirth .. " pts talent!") end
	print("[ClassSystem V35] " .. player.Name .. " REBIRTH R" .. data.PlayerRebirths .. " → " .. newTitle)
end)

-- === HANDLER: Talent Allocation ===
local talentRemote = remotes:FindFirstChild("AllocateTalent")
if not talentRemote then
	talentRemote = Instance.new("RemoteEvent")
	talentRemote.Name = "AllocateTalent"
	talentRemote.Parent = remotes
end

-- Talent tree: 3 branches par classe, 10 talents par branche
local TALENT_TREES = {
	Guerrier = {
		["Force"] = {
			{name="Coup Puissant", desc="+5% ATK", stat="ATK", bonus=5},
			{name="Fureur", desc="+8% ATK", stat="ATK", bonus=8},
			{name="Rage", desc="+10% crit dmg", stat="CritDMG", bonus=10},
			{name="Berserk", desc="+12% ATK", stat="ATK", bonus=12},
			{name="Massacre", desc="+15% AoE", stat="AoEDMG", bonus=15},
			{name="Titan", desc="+8% taille", stat="Size", bonus=8, reqRebirth=2},
			{name="Colosse", desc="+20% ATK", stat="ATK", bonus=20, reqRebirth=3},
			{name="Destructeur", desc="+10% pénétration", stat="ArmorPen", bonus=10, reqRebirth=5},
			{name="Warlord", desc="+25% ATK", stat="ATK", bonus=25, reqRebirth=7},
			{name="Dieu de Guerre", desc="+30% tous dégâts", stat="AllDMG", bonus=30, reqRebirth=9},
		},
		["Endurance"] = {
			{name="Peau Dure", desc="+5% DEF", stat="DEF", bonus=5},
			{name="Constitution", desc="+100 HP", stat="HP", bonus=100},
			{name="Bouclier", desc="+8% DEF", stat="DEF", bonus=8},
			{name="Tenacité", desc="+200 HP", stat="HP", bonus=200},
			{name="Inébranlable", desc="+15% DEF", stat="DEF", bonus=15},
			{name="Forteresse", desc="+5% régen", stat="HPRegen", bonus=5, reqRebirth=2},
			{name="Immortel", desc="+500 HP", stat="HP", bonus=500, reqRebirth=4},
			{name="Citadelle", desc="+20% DEF", stat="DEF", bonus=20, reqRebirth=5},
			{name="Invincible", desc="+10% esquive", stat="Dodge", bonus=10, reqRebirth=7},
			{name="Éternel", desc="+1 vie supplémentaire", stat="ExtraLife", bonus=1, reqRebirth=9},
		},
		["Maîtrise"] = {
			{name="Parade", desc="+5% bloc", stat="Block", bonus=5},
			{name="Riposte", desc="+5% contre", stat="Counter", bonus=5},
			{name="Précision", desc="+10% précision", stat="Accuracy", bonus=10},
			{name="Combo", desc="+1 combo max", stat="MaxCombo", bonus=1},
			{name="Vétéran", desc="+10% XP combat", stat="CombatXP", bonus=10},
			{name="Chef", desc="+5% stats alliés", stat="AllyBuff", bonus=5, reqRebirth=2},
			{name="Stratège", desc="+15% XP", stat="AllXP", bonus=15, reqRebirth=4},
			{name="Général", desc="+10% stats alliés", stat="AllyBuff", bonus=10, reqRebirth=6},
			{name="Maréchal", desc="+20% or", stat="GoldBonus", bonus=20, reqRebirth=8},
			{name="Légende", desc="Déblocage ultime", stat="Ultimate", bonus=1, reqRebirth=10},
		},
	},
	Mage = {
		["Arcane"] = {
			{name="Étincelle", desc="+5% magie", stat="MagicDMG", bonus=5},
			{name="Foudre", desc="+8% magie", stat="MagicDMG", bonus=8},
			{name="Tempête", desc="+10% AoE", stat="AoEDMG", bonus=10},
			{name="Cataclysme", desc="+15% magie", stat="MagicDMG", bonus=15},
			{name="Apocalypse", desc="+20% AoE", stat="AoEDMG", bonus=20},
			{name="Surcharge", desc="+10% mana", stat="Mana", bonus=10, reqRebirth=2},
			{name="Nova", desc="+25% magie", stat="MagicDMG", bonus=25, reqRebirth=4},
			{name="Météore", desc="+15% AoE crit", stat="AoECrit", bonus=15, reqRebirth=6},
			{name="Éruption", desc="+30% magie", stat="MagicDMG", bonus=30, reqRebirth=8},
			{name="Annihilation", desc="+50% ultime", stat="UltiDMG", bonus=50, reqRebirth=10},
		},
		["Sagesse"] = {
			{name="Méditation", desc="+5% régen mana", stat="ManaRegen", bonus=5},
			{name="Concentration", desc="+100 mana", stat="MaxMana", bonus=100},
			{name="Intellect", desc="+8% magie", stat="MagicDMG", bonus=8},
			{name="Omniscience", desc="+200 mana", stat="MaxMana", bonus=200},
			{name="Transcendance", desc="+15% régen", stat="ManaRegen", bonus=15},
			{name="Illumination", desc="+10% CDR", stat="CDR", bonus=10, reqRebirth=2},
			{name="Éveil", desc="+500 mana", stat="MaxMana", bonus=500, reqRebirth=4},
			{name="Ascension", desc="+20% CDR", stat="CDR", bonus=20, reqRebirth=6},
			{name="Nirvana", desc="+25% soins", stat="HealBonus", bonus=25, reqRebirth=8},
			{name="Divinité", desc="Sort ultime", stat="Ultimate", bonus=1, reqRebirth=10},
		},
		["Éléments"] = {
			{name="Affinité Feu", desc="+10% feu", stat="FireDMG", bonus=10},
			{name="Affinité Glace", desc="+10% glace", stat="IceDMG", bonus=10},
			{name="Affinité Foudre", desc="+10% foudre", stat="LightningDMG", bonus=10},
			{name="Multi-élément", desc="+5% tous", stat="AllElementDMG", bonus=5},
			{name="Maîtrise", desc="+15% réactions", stat="ReactionDMG", bonus=15},
			{name="Fusion", desc="+10% combo", stat="ElementCombo", bonus=10, reqRebirth=2},
			{name="Chaos", desc="+20% tous", stat="AllElementDMG", bonus=20, reqRebirth=4},
			{name="Primordial", desc="+25% réactions", stat="ReactionDMG", bonus=25, reqRebirth=6},
			{name="Avatar", desc="+30% tous", stat="AllElementDMG", bonus=30, reqRebirth=8},
			{name="Créateur", desc="Nouvel élément", stat="Ultimate", bonus=1, reqRebirth=10},
		},
	},
	Archer = {
		["Précision"] = {
			{name="Visée", desc="+10% précision", stat="Accuracy", bonus=10},
			{name="Tir Rapide", desc="+10% vitesse tir", stat="AttackSpeed", bonus=10},
			{name="Headshot", desc="+15% crit", stat="CritRate", bonus=15},
			{name="Pluie de Flèches", desc="+10% AoE", stat="AoEDMG", bonus=10},
			{name="Oeil de Faucon", desc="+20% range", stat="Range", bonus=20},
			{name="Flèche Perçante", desc="+15% pénétration", stat="ArmorPen", bonus=15, reqRebirth=2},
			{name="Tir Chargé", desc="+25% crit dmg", stat="CritDMG", bonus=25, reqRebirth=4},
			{name="Multi-Tir", desc="+2 projectiles", stat="MultiShot", bonus=2, reqRebirth=6},
			{name="Barrage", desc="+30% vitesse tir", stat="AttackSpeed", bonus=30, reqRebirth=8},
			{name="Oeil Divin", desc="Tir guidé", stat="Ultimate", bonus=1, reqRebirth=10},
		},
		["Agilité"] = {
			{name="Esquive", desc="+8% esquive", stat="Dodge", bonus=8},
			{name="Sprint", desc="+10% vitesse", stat="Speed", bonus=10},
			{name="Roulade", desc="+1 dash", stat="DashCount", bonus=1},
			{name="Glissade", desc="+15% esquive", stat="Dodge", bonus=15},
			{name="Acrobatie", desc="+1 saut", stat="ExtraJump", bonus=1},
			{name="Fantôme", desc="+20% vitesse", stat="Speed", bonus=20, reqRebirth=2},
			{name="Camouflage", desc="+5s stealth", stat="Stealth", bonus=5, reqRebirth=4},
			{name="Évasion", desc="+25% esquive", stat="Dodge", bonus=25, reqRebirth=6},
			{name="Intouchable", desc="+30% esquive", stat="Dodge", bonus=30, reqRebirth=8},
			{name="Vent Divin", desc="Téléportation", stat="Ultimate", bonus=1, reqRebirth=10},
		},
		["Chasse"] = {
			{name="Traqueur", desc="+10% or", stat="GoldBonus", bonus=10},
			{name="Collecteur", desc="+5% drop rare", stat="RareDrop", bonus=5},
			{name="Piègeur", desc="+10% slow", stat="SlowEffect", bonus=10},
			{name="Flèche Poison", desc="+8% poison", stat="PoisonDMG", bonus=8},
			{name="Éclaireur", desc="+15% or", stat="GoldBonus", bonus=15},
			{name="Flèche Feu", desc="+10% brûlure", stat="BurnDMG", bonus=10, reqRebirth=2},
			{name="Flèche Glace", desc="+15% freeze", stat="FreezeDMG", bonus=15, reqRebirth=4},
			{name="Grand Chasseur", desc="+20% drop rare", stat="RareDrop", bonus=20, reqRebirth=6},
			{name="Maître Piégeur", desc="+30% slow zone", stat="SlowZone", bonus=30, reqRebirth=8},
			{name="Roi de la Chasse", desc="Marquage boss", stat="Ultimate", bonus=1, reqRebirth=10},
		},
	},
	Moine = {
		["Guérison"] = {
			{name="Premiers Soins", desc="+10% soins", stat="HealBonus", bonus=10},
			{name="Régénération", desc="+5% régen HP", stat="HPRegen", bonus=5},
			{name="Bénédiction", desc="+15% soins", stat="HealBonus", bonus=15},
			{name="Miracle", desc="+200 HP", stat="HP", bonus=200},
			{name="Résurrection", desc="Réanimer allié", stat="Revive", bonus=1},
			{name="Grâce Divine", desc="+10% régen", stat="HPRegen", bonus=10, reqRebirth=2},
			{name="Sanctuaire", desc="+25% soins zone", stat="AoEHeal", bonus=25, reqRebirth=4},
			{name="Immortalité", desc="+500 HP", stat="HP", bonus=500, reqRebirth=6},
			{name="Ange", desc="+50% soins", stat="HealBonus", bonus=50, reqRebirth=8},
			{name="Résurrection de Masse", desc="Réanimer tous", stat="Ultimate", bonus=1, reqRebirth=10},
		},
		["Protection"] = {
			{name="Bouclier Sacré", desc="+8% DEF alliés", stat="AllyDEF", bonus=8},
			{name="Aura", desc="+200 bouclier", stat="Shield", bonus=200},
			{name="Rempart", desc="+15% DEF", stat="DEF", bonus=15},
			{name="Immunité", desc="+10% résist status", stat="StatusResist", bonus=10},
			{name="Forteresse Divine", desc="+500 bouclier", stat="Shield", bonus=500},
			{name="Purification", desc="Nettoyer status", stat="Cleanse", bonus=1, reqRebirth=2},
			{name="Dôme Sacré", desc="+25% DEF zone", stat="AoEDEF", bonus=25, reqRebirth=4},
			{name="Invulnérabilité", desc="+5s invincible", stat="Invuln", bonus=5, reqRebirth=6},
			{name="Mur Divin", desc="+1000 bouclier", stat="Shield", bonus=1000, reqRebirth=8},
			{name="Aegis Éternel", desc="Bouclier permanent", stat="Ultimate", bonus=1, reqRebirth=10},
		},
		["Harmonie"] = {
			{name="Sérénité", desc="+5% XP", stat="AllXP", bonus=5},
			{name="Méditation", desc="+10% régen", stat="AllRegen", bonus=10},
			{name="Équilibre", desc="+5% tous stats", stat="AllStats", bonus=5},
			{name="Zen", desc="+10% XP", stat="AllXP", bonus=10},
			{name="Harmonie", desc="+10% tous stats", stat="AllStats", bonus=10},
			{name="Paix Intérieure", desc="+15% régen", stat="AllRegen", bonus=15, reqRebirth=2},
			{name="Illumination", desc="+15% tous stats", stat="AllStats", bonus=15, reqRebirth=4},
			{name="Transcendance", desc="+20% XP", stat="AllXP", bonus=20, reqRebirth=6},
			{name="Nirvana", desc="+25% tous stats", stat="AllStats", bonus=25, reqRebirth=8},
			{name="Bouddha", desc="Éveil total", stat="Ultimate", bonus=1, reqRebirth=10},
		},
	},
}

talentRemote.OnServerEvent:Connect(function(player, className, branchName, talentIndex)
	local data = PlayerDataService:GetData(player)
	if not data then return end
	
	if (data.TalentPoints or 0) <= 0 then
		local n = remotes:FindFirstChild("NotifyPlayer")
		if n then n:FireClient(player, "❌ Pas de points de talent!") end
		return
	end
	
	local classTree = TALENT_TREES[className]
	if not classTree then return end
	local branch = classTree[branchName]
	if not branch then return end
	if talentIndex < 1 or talentIndex > #branch then return end
	
	local talent = branch[talentIndex]
	
	-- Check sequential
	if talentIndex > 1 then
		local prevKey = className .. "_" .. branchName .. "_" .. (talentIndex - 1)
		if not (data.Talents and data.Talents[prevKey]) then
			local n = remotes:FindFirstChild("NotifyPlayer")
			if n then n:FireClient(player, "❌ Débloque d'abord le talent précédent!") end
			return
		end
	end
	
	-- Check rebirth
	if talent.reqRebirth and (data.PlayerRebirths or 0) < talent.reqRebirth then
		local n = remotes:FindFirstChild("NotifyPlayer")
		if n then n:FireClient(player, "❌ Renaissance " .. talent.reqRebirth .. " requise!") end
		return
	end
	
	-- Check already allocated
	local talentKey = className .. "_" .. branchName .. "_" .. talentIndex
	if data.Talents and data.Talents[talentKey] then
		local n = remotes:FindFirstChild("NotifyPlayer")
		if n then n:FireClient(player, "❌ Talent déjà débloqué!") end
		return
	end
	
	-- Allocate
	data.TalentPoints = (data.TalentPoints or 0) - 1
	if not data.Talents then data.Talents = {} end
	data.Talents[talentKey] = true
	player:SetAttribute("TalentPoints", data.TalentPoints)
	
	local n = remotes:FindFirstChild("NotifyPlayer")
	if n then n:FireClient(player, "✅ " .. talent.name .. ": " .. talent.desc) end
	print("[ClassSystem V35] " .. player.Name .. " → " .. talent.name)
end)

-- === Give talent points on level up (1 every 2 levels) ===
Players.PlayerAdded:Connect(function(player)
	task.spawn(function()
		local lastLevel = 0
		while player.Parent do
			local data = PlayerDataService:GetData(player)
			if data then
				local level = data.ClassLevels[data.CurrentClass] or 1
				if level ~= lastLevel and level > 1 then
					local earned = math.floor(level / 2) - math.floor(lastLevel / 2)
					if earned > 0 then
						data.TalentPoints = (data.TalentPoints or 0) + earned
						player:SetAttribute("TalentPoints", data.TalentPoints)
						local n = remotes:FindFirstChild("NotifyPlayer")
						if n then n:FireClient(player, "⭐ +" .. earned .. " pt talent! (nv." .. level .. ")") end
					end
					lastLevel = level
				end
			end
			task.wait(2)
		end
	end)
end)

print("[ClassSystem V35] Ready! 4 classes + Rebirth R0-R10 + Talent Trees (3 branches x 10)")
