--[[
	WeaponSystem V35 - Armes par classe
	========================================
	Guerrier  -> Epee en bois (melee, degats moyens)
	Mage      -> Baguette magique (distance, boules de feu, DoT, faibles degats)
	Archer    -> Arc en bois (distance, fleches infinies, precision)
	Moine     -> Poings (melee, rapide, faibles degats)
	
	+ Laser de capture (debloque via armurerie)
]]

local WeaponSystem = {}

-- Types d'armes
WeaponSystem.WEAPONS = {
	-- === ARMES DE CLASSE (donnees au debut) ===
	WOODEN_SWORD = {
		id = "wooden_sword",
		name = "Epee en Bois",
		class = "Guerrier",
		minLevel = 1,
		attackPower = 3,
		attackSpeed = 1.0,      -- attaques par seconde
		range = 8,              -- distance d'attaque (melee)
		isRanged = false,
		captureChance = 0,
		icon = "🗡️",
		desc = "Epee solide pour le combat rapproche. Degats corrects.",
	},
	MAGIC_WAND = {
		id = "magic_wand",
		name = "Baguette Magique",
		class = "Mage",
		minLevel = 1,
		attackPower = 1,        -- faibles degats directs
		attackSpeed = 0.8,      -- un peu plus lent
		range = 40,             -- DISTANCE! boules de feu
		isRanged = true,
		dotDamage = 2,          -- degats dans le temps (par tick, 3 ticks)
		dotDuration = 3,        -- duree du DoT en secondes
		captureChance = 0,
		icon = "🪄",
		desc = "Lance des boules de feu a distance. Peu de degats mais brule!",
	},
	WOODEN_BOW = {
		id = "wooden_bow",
		name = "Arc en Bois",
		class = "Archer",
		minLevel = 1,
		attackPower = 2,
		attackSpeed = 1.2,      -- rapide
		range = 50,             -- LONGUE DISTANCE!
		isRanged = true,
		infiniteAmmo = true,    -- fleches de base infinies
		captureChance = 0,
		icon = "🏹",
		desc = "Arc precis a longue portee. Fleches de base infinies.",
	},
	FISTS = {
		id = "fists",
		name = "Poings",
		class = "Moine",
		minLevel = 1,
		attackPower = 1,        -- faibles degats
		attackSpeed = 2.0,      -- TRES RAPIDE! (2 coups/sec)
		range = 6,              -- melee proche
		isRanged = false,
		lifeSteal = 0.05,       -- 5% vol de vie
		captureChance = 0,
		icon = "👊",
		desc = "Coups rapides au corps a corps. Vole un peu de vie.",
	},
	
	-- === ARME LEGACY (compatibilite) ===
	NOVICE_STAFF = {
		id = "novice_staff",
		name = "Baton de Novice",
		class = nil,
		minLevel = 1,
		maxLevel = 9,
		attackPower = 1,
		attackSpeed = 1.0,
		range = 8,
		isRanged = false,
		captureChance = 0,
		icon = "🔱",
		desc = "Baton basique. Remplace par une arme de classe!",
	},
	
	-- === LASER DE CAPTURE ===
	LASER_GUN = {
		id = "laser_gun",
		name = "Pistolet Laser",
		class = nil,
		minLevel = 10,
		attackPower = 2,
		attackSpeed = 0.5,
		range = 30,
		isRanged = true,
		captureChance = 0.15,   -- 15% de base
		captureSpeed = 1.5,
		retryChance = 0,
		icon = "🔫",
		desc = "Capture les monstres assommes!",
	}
}

-- Arme par defaut selon la classe
WeaponSystem.CLASS_WEAPON_MAP = {
	Guerrier = "WOODEN_SWORD",
	Mage = "MAGIC_WAND",
	Archer = "WOODEN_BOW",
	Moine = "FISTS",
}

-- Obtenir l'arme du joueur selon sa classe
function WeaponSystem:GetWeaponForClass(className)
	local key = self.CLASS_WEAPON_MAP[className]
	if key then
		return self.WEAPONS[key]
	end
	return self.WEAPONS.NOVICE_STAFF
end

-- Obtenir l'arme du joueur selon son niveau (compat legacy)
function WeaponSystem:GetWeaponForLevel(level)
	if level >= 10 then
		return self.WEAPONS.LASER_GUN
	else
		return self.WEAPONS.NOVICE_STAFF
	end
end

-- Donner une arme au joueur
function WeaponSystem:GiveWeapon(player, weapon)
	print("[WeaponSystem] Giving", weapon.name, "to", player.Name)
	
	-- Creer/mettre a jour PlayerData
	local playerData = player:FindFirstChild("PlayerData")
	if not playerData then
		playerData = Instance.new("Folder")
		playerData.Name = "PlayerData"
		playerData.Parent = player
	end
	
	-- Sauvegarder l'arme actuelle
	local currentWeapon = Instance.new("StringValue")
	currentWeapon.Name = "CurrentWeapon"
	currentWeapon.Value = weapon.id
	
	local oldWeapon = playerData:FindFirstChild("CurrentWeapon")
	if oldWeapon then oldWeapon:Destroy() end
	currentWeapon.Parent = playerData
	
	-- Sync attributes pour le HUD client
	player:SetAttribute("WeaponName", weapon.name)
	player:SetAttribute("WeaponIcon", weapon.icon or "")
	player:SetAttribute("WeaponRange", weapon.range or 8)
	player:SetAttribute("WeaponIsRanged", weapon.isRanged or false)
	player:SetAttribute("WeaponATK", weapon.attackPower or 1)
	player:SetAttribute("WeaponSpeed", weapon.attackSpeed or 1.0)
	
	print("[WeaponSystem] Player now has:", weapon.name, "(range:", weapon.range, ", ranged:", weapon.isRanged, ")")
	return true
end

-- Calculer les degats d'une arme
function WeaponSystem:CalculateDamage(weapon, playerATK)
	local base = weapon.attackPower or 1
	local total = base + playerATK
	
	-- Critical hit? (10% chance de base)
	local isCrit = math.random() < 0.10
	if isCrit then
		total = math.floor(total * 1.8)
	end
	
	return math.floor(total), isCrit
end

-- Calculer la chance de capture (ameliorations du shop a venir)
function WeaponSystem:CalculateCaptureChance(weapon, monsterHealth, monsterMaxHealth)
	local baseChance = weapon.captureChance or 0
	
	-- Bonus selon la sante du monstre (plus faible = plus facile)
	local healthPercent = monsterHealth / monsterMaxHealth
	local healthBonus = (1 - healthPercent) * 0.3 -- Jusqu'a +30% si tres affaibli
	
	local finalChance = math.min(0.95, baseChance + healthBonus) -- Max 95%
	
	return finalChance
end

return WeaponSystem
