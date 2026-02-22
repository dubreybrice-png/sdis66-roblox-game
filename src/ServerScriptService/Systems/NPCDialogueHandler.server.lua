--[[
	NPCDialogueHandler V35
	Gere les dialogues du PNJ guide (Aldric)
	- Si pas de classe: popup choix de classe (via SimpleDialogue V35)
	- Si classe choisie: Aldric conseille le prochain batiment a construire
	- Donne l'arme adaptee selon la classe choisie
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Attendre que Remotes existe (cree par Init.server.lua)
local remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
if not remotes then
	warn("[NPCDialogueHandler] Remotes folder not found!")
	return
end

-- Les remotes sont crees par Init.server.lua
local showDialogue = remotes:WaitForChild("ShowDialogue", 5)
local closeDialogue = remotes:WaitForChild("CloseDialogue", 5)

if not showDialogue or not closeDialogue then
	warn("[NPCDialogueHandler] Dialogue remotes not found!")
	return
end

-- Service
local PlayerDataService = require(script.Parent.Parent.Services.PlayerDataService)
local WeaponSystem = require(script.Parent.Parent.Services.WeaponSystem)
local BuildingDB = require(ReplicatedStorage.Data.BuildingDatabase)

-- Dialogues RP d'Aldric selon le batiment suivant
local BUILDING_DIALOGUES = {
	monster_storage = {
		"Bien joue, heros! Ta classe est choisie et ton compagnon est a tes cotes.",
		"Mais il te faut un endroit pour stocker tes futures captures...",
		"Construis le CENTRE DE STOCKAGE au nord-est! (50g)",
		"Ca te permettra de garder plus de monstres.",
	},
	gold_mine = {
		"Ton stockage est en place, parfait!",
		"Maintenant, il te faut de l'or... beaucoup d'or.",
		"Construis la MINE D'OR a l'ouest! (150g)",
		"Tes monstres pourront y travailler pour generer des revenus.",
	},
	class_hall = {
		"Ta ville commence a prendre forme!",
		"Ameliore le HALL DES CLASSES pour debloquer des options avancees! (100g)",
		"Tu pourras specialiser ta classe encore plus!",
	},
	defense_bureau = {
		"Le cristal est precieux, il faut mieux le proteger!",
		"Repare le BUREAU DES DEFENSES a l'est! (200g)",
		"Ca renforcera le cristal et tes defenseurs.",
	},
	bank = {
		"L'or que tu portes sur toi est en danger si le cristal tombe...",
		"Construis la BANQUE au sud! (200g)",
		"L'or depose en banque ne sera jamais perdu!",
	},
	armory = {
		"Tes armes sont basiques... il faut ameliorer ca.",
		"Repare l'ARMURERIE au sud-ouest! (300g)",
		"Tu auras acces a la forge et au laser de capture!",
	},
	monster_school = {
		"Tes monstres ont du potentiel cache...",
		"Repare l'ECOLE DES MONSTRES a l'est! (400g)",
		"Ils pourront y apprendre de nouvelles competences!",
	},
}

local DIALOGUE_ALL_BUILT = {
	"Impressionnant! Tu as construit tous les batiments de base.",
	"Continue a les ameliorer et prepare-toi pour l'ere suivante!",
	"Les vagues vont devenir de plus en plus difficiles...",
	"Bonne chance, heros!",
}

-- Remote pour envoyer un message RP au joueur
local function sendRPDialogue(player, lines)
	local notifyRemote = remotes:FindFirstChild("NotifyPlayer")
	if notifyRemote then
		for i, line in ipairs(lines) do
			task.delay((i - 1) * 2.5, function()
				notifyRemote:FireClient(player, "🗣 Aldric: " .. line)
			end)
		end
	end
end

-- Quand le NPC est clique
local function onNPCClicked(player, npc)
	print("[NPCDialogue] DIALOGUE TRIGGERED BY", player.Name)
	
	-- VERIFIER SI LE JOUEUR A DEJA CHOISI SA CLASSE
	local data = PlayerDataService:GetData(player)
	if data and data.CurrentClass and data.CurrentClass ~= "Novice" then
		-- Classe deja choisie -> conseiller batiment
		local nextId, nextData = BuildingDB:GetNextToBuild(data.Buildings or {})
		
		if nextId and BUILDING_DIALOGUES[nextId] then
			sendRPDialogue(player, BUILDING_DIALOGUES[nextId])
		else
			sendRPDialogue(player, DIALOGUE_ALL_BUILT)
		end
		return
	end
	
	print("[NPCDialogue] Sending class selection popup...")
	
	local showDialogueSimple = remotes:FindFirstChild("ShowDialogueSimple")
	if not showDialogueSimple then
		showDialogueSimple = Instance.new("RemoteEvent")
		showDialogueSimple.Name = "ShowDialogueSimple"
		showDialogueSimple.Parent = remotes
	end
	
	-- Envoyer au client (affiche le popup de classe)
	print("[NPCDialogue] Firing ShowDialogueSimple to client!")
	showDialogueSimple:FireClient(player)
end

-- Setup du NPC
task.wait(2) -- Attendre que le monde soit cree

local npc = workspace:WaitForChild("GuideNPC", 10)
if npc then
	print("[NPCDialogueHandler] NPC found!")
	local torso = npc:FindFirstChild("Torso")
	if torso then
		print("[NPCDialogueHandler] Torso found!")
		-- ClickDetector
		local detector = torso:FindFirstChildOfClass("ClickDetector")
		if detector then
			detector.MouseClick:Connect(function(player)
				print("[NPCDialogueHandler] ClickDetector triggered by", player.Name)
				onNPCClicked(player, npc)
			end)
			print("[NPCDialogueHandler] ClickDetector connected")
		else
			print("[NPCDialogueHandler] WARNING: No ClickDetector found!")
		end
		
		-- ProximityPrompt (methode moderne)
		local prompt = torso:FindFirstChildOfClass("ProximityPrompt")
		if prompt then
			prompt.Triggered:Connect(function(player)
				print("[NPCDialogueHandler] ProximityPrompt triggered by", player.Name)
				onNPCClicked(player, npc)
			end)
			print("[NPCDialogueHandler] ProximityPrompt connected")
		else
			print("[NPCDialogueHandler] WARNING: No ProximityPrompt found!")
		end
	else
		print("[NPCDialogueHandler] ERROR: Torso not found!")
	end
else
	print("[NPCDialogueHandler] ERROR: GuideNPC not found!")
end

-- Ecouter les choix de classe (ChangeClass) et donner l'arme adaptee
local changeClassRemote = remotes:WaitForChild("ChangeClass", 5)
if changeClassRemote then
	changeClassRemote.OnServerEvent:Connect(function(player, className)
		print("[NPCDialogueHandler] CLASS CHOSEN:", className, "by", player.Name)
		
		-- Marquer que le joueur a choisi un starter (pour compat)
		local data = PlayerDataService:GetData(player)
		if data then
			data.HasStarter = true
			print("[NPCDialogueHandler] HasStarter set to TRUE")
		end
		
		-- DONNER L'ARME ADAPTEE SELON LA CLASSE
		local CLASS_WEAPONS = {
			Guerrier = "WOODEN_SWORD",
			Mage = "MAGIC_WAND",
			Archer = "WOODEN_BOW",
			Moine = "FISTS",
		}
		
		local weaponKey = CLASS_WEAPONS[className] or "NOVICE_STAFF"
		local weapon = WeaponSystem.WEAPONS[weaponKey]
		if weapon then
			WeaponSystem:GiveWeapon(player, weapon)
			print("[NPCDialogueHandler] Given", weapon.name, "to", player.Name)
		else
			-- Fallback
			WeaponSystem:GiveWeapon(player, WeaponSystem.WEAPONS.NOVICE_STAFF)
			print("[NPCDialogueHandler] Fallback: Given NOVICE_STAFF to", player.Name)
		end
		
		-- Le MonsterSpawner ecoute ChangeClass.OnServerEvent directement
		-- Il donne le monstre starter et active les vagues
		print("[NPCDialogueHandler] Class selection complete! MonsterSpawner handles starter.")
	end)
	print("[NPCDialogueHandler] ChangeClass listener connected")
else
	print("[NPCDialogueHandler] WARNING: ChangeClass remote not found!")
end
