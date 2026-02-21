--[[
	QuestSystem V30 - Système de quêtes
	Quêtes quotidiennes, hebdomadaires et principales
	Donne des récompenses en or, XP, orbes
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Attendre les remotes
local remotes = ReplicatedStorage:WaitForChild("Remotes", 15)
if not remotes then
	warn("[QuestSystem] Remotes not found!")
	return
end

local PlayerDataService = require(ServerScriptService.Services.PlayerDataService)

print("[QuestSystem V30] Loading...")

-- === DÉFINITION DES QUÊTES ===
local QUEST_TEMPLATES = {
	-- QUÊTES PRINCIPALES (storyline)
	main = {
		{id = "main_1", title = "Premier contact", desc = "Parle au Guide Aldric", type = "talk_npc", target = 1, reward = {gold = 50, xp = 20}},
		{id = "main_2", title = "Premier compagnon", desc = "Choisis un monstre starter", type = "get_starter", target = 1, reward = {gold = 100, xp = 50}},
		{id = "main_3", title = "Baptême du feu", desc = "Élimine 5 monstres sauvages", type = "kill", target = 5, reward = {gold = 150, xp = 80}},
		{id = "main_4", title = "Collectionneur", desc = "Capture 3 monstres", type = "capture", target = 3, reward = {gold = 200, xp = 100, orbs = 3}},
		{id = "main_5", title = "Bâtisseur", desc = "Construis ton premier bâtiment", type = "build", target = 1, reward = {gold = 300, xp = 150}},
		{id = "main_6", title = "Vague 10", desc = "Survie jusqu'à la vague 10", type = "wave", target = 10, reward = {gold = 500, xp = 250}},
		{id = "main_7", title = "Spécialisation", desc = "Choisis une classe au Hall des Classes", type = "change_class", target = 1, reward = {gold = 400, xp = 300}},
		{id = "main_8", title = "Chasseur d'élite", desc = "Élimine 50 monstres", type = "kill", target = 50, reward = {gold = 800, xp = 500}},
		{id = "main_9", title = "Maître Captureur", desc = "Capture 15 monstres différents", type = "unique_capture", target = 15, reward = {gold = 1000, xp = 700, orbs = 10}},
		{id = "main_10", title = "Tueur de Boss", desc = "Vaincs un boss (vague 25)", type = "wave", target = 25, reward = {gold = 2000, xp = 1000}},
		{id = "main_11", title = "Empire naissant", desc = "Construis 5 bâtiments", type = "build", target = 5, reward = {gold = 1500, xp = 800}},
		{id = "main_12", title = "Légende vivante", desc = "Atteins la vague 50", type = "wave", target = 50, reward = {gold = 5000, xp = 2000}},
	},
	
	-- QUÊTES QUOTIDIENNES (reset toutes les 24h en jeu = toutes les 20 minutes IRL)
	daily = {
		{id = "daily_kill_10", title = "Entraînement", desc = "Élimine 10 monstres", type = "kill", target = 10, reward = {gold = 100, xp = 50}},
		{id = "daily_capture_2", title = "Safari", desc = "Capture 2 monstres", type = "capture", target = 2, reward = {gold = 80, xp = 40, orbs = 1}},
		{id = "daily_wave_5", title = "Défenseur", desc = "Survie 5 vagues", type = "wave_count", target = 5, reward = {gold = 120, xp = 60}},
		{id = "daily_gold_200", title = "Prospérité", desc = "Gagne 200 or total", type = "earn_gold", target = 200, reward = {gold = 100, xp = 30}},
		{id = "daily_kill_rare", title = "Chasseur de rares", desc = "Élimine 3 monstres Rares+", type = "kill_rare", target = 3, reward = {gold = 150, xp = 80}},
	},
	
	-- QUÊTES DE ZONE (spécifiques à chaque zone)
	zone = {
		{id = "zone_forest", title = "Gardien de la forêt", desc = "Élimine 20 monstres en zone Forêt", type = "kill_zone", zone = "Foret", target = 20, reward = {gold = 300, xp = 150}},
		{id = "zone_mountain", title = "Roi de la montagne", desc = "Élimine 20 monstres en zone Montagne", type = "kill_zone", zone = "Montagne", target = 20, reward = {gold = 300, xp = 150}},
		{id = "zone_sea", title = "Maître des flots", desc = "Élimine 20 monstres en zone Mer", type = "kill_zone", zone = "Mer", target = 20, reward = {gold = 300, xp = 150}},
		{id = "zone_dark", title = "Purificateur", desc = "Élimine 20 monstres en zone Ténèbres", type = "kill_zone", zone = "Sombre", target = 20, reward = {gold = 400, xp = 200}},
	},
}

-- === STOCKAGE DES QUÊTES JOUEUR ===
local playerQuests = {} -- playerQuests[player] = {active = {}, completed = {}, dailyTimer = 0}

local function initPlayerQuests(player)
	playerQuests[player] = {
		active = {},      -- {questId = {progress = 0, quest = questTemplate}}
		completed = {},   -- {questId = true}
		dailyActive = {}, -- quêtes quotidiennes actives
		dailyCompleted = {}, -- quêtes quotidiennes complétées cette "journée"
		dailyResetTime = tick() + 1200, -- Reset toutes les 20 minutes
		totalKills = 0,
		totalCaptures = 0,
		totalGoldEarned = 0,
		wavesCompleted = 0,
	}
	
	-- Activer la première quête principale
	local q = playerQuests[player]
	for _, quest in ipairs(QUEST_TEMPLATES.main) do
		if not q.completed[quest.id] then
			q.active[quest.id] = {progress = 0, quest = quest}
			break -- Une seule quête principale active à la fois
		end
	end
	
	-- Activer 2 quêtes quotidiennes aléatoires
	assignDailyQuests(player)
	
	-- Activer toutes les quêtes de zone
	for _, quest in ipairs(QUEST_TEMPLATES.zone) do
		if not q.completed[quest.id] then
			q.active[quest.id] = {progress = 0, quest = quest}
		end
	end
end

function assignDailyQuests(player)
	local q = playerQuests[player]
	if not q then return end
	
	q.dailyActive = {}
	q.dailyCompleted = {}
	
	-- Choisir 2 quêtes quotidiennes au hasard
	local available = {}
	for i, quest in ipairs(QUEST_TEMPLATES.daily) do
		table.insert(available, quest)
	end
	
	for i = 1, math.min(2, #available) do
		local idx = math.random(#available)
		local quest = table.remove(available, idx)
		q.active[quest.id] = {progress = 0, quest = quest}
		q.dailyActive[quest.id] = true
	end
end

-- === PROGRESSION DES QUÊTES ===
local function checkQuestProgress(player, eventType, eventData)
	local q = playerQuests[player]
	if not q then return end
	
	-- Vérifier reset quotidien
	if tick() > q.dailyResetTime then
		q.dailyResetTime = tick() + 1200
		-- Supprimer les anciennes quêtes quotidiennes
		for qId, _ in pairs(q.dailyActive) do
			q.active[qId] = nil
		end
		assignDailyQuests(player)
		
		local notify = remotes:FindFirstChild("NotifyPlayer")
		if notify then
			notify:FireClient(player, "📋 Nouvelles quêtes quotidiennes disponibles!")
		end
	end
	
	local completedQuests = {}
	
	for questId, questData in pairs(q.active) do
		local quest = questData.quest
		local progressed = false
		
		if eventType == "kill" and (quest.type == "kill" or quest.type == "kill_rare" or quest.type == "kill_zone") then
			if quest.type == "kill" then
				questData.progress = questData.progress + 1
				progressed = true
			elseif quest.type == "kill_rare" and eventData and eventData.rarity then
				local rareRarities = {Rare = true, Exceptionnel = true, Epique = true, Legendaire = true}
				if rareRarities[eventData.rarity] then
					questData.progress = questData.progress + 1
					progressed = true
				end
			elseif quest.type == "kill_zone" and eventData and eventData.zone then
				if quest.zone and string.find(eventData.zone or "", quest.zone) then
					questData.progress = questData.progress + 1
					progressed = true
				end
			end
		elseif eventType == "capture" and (quest.type == "capture" or quest.type == "unique_capture") then
			questData.progress = questData.progress + 1
			progressed = true
		elseif eventType == "build" and quest.type == "build" then
			questData.progress = questData.progress + 1
			progressed = true
		elseif eventType == "wave" and (quest.type == "wave" or quest.type == "wave_count") then
			if quest.type == "wave" then
				questData.progress = math.max(questData.progress, eventData.wave or 0)
			else
				questData.progress = questData.progress + 1
			end
			progressed = true
		elseif eventType == "get_starter" and quest.type == "get_starter" then
			questData.progress = 1
			progressed = true
		elseif eventType == "talk_npc" and quest.type == "talk_npc" then
			questData.progress = 1
			progressed = true
		elseif eventType == "change_class" and quest.type == "change_class" then
			questData.progress = 1
			progressed = true
		elseif eventType == "earn_gold" and quest.type == "earn_gold" then
			questData.progress = questData.progress + (eventData.amount or 0)
			progressed = true
		end
		
		-- Quête complétée ?
		if progressed and questData.progress >= quest.target then
			table.insert(completedQuests, questId)
		end
	end
	
	-- Distribuer les récompenses
	for _, questId in ipairs(completedQuests) do
		local questData = q.active[questId]
		if questData then
			local quest = questData.quest
			local reward = quest.reward
			
			-- Donner récompenses
			if reward.gold then
				PlayerDataService:AddGold(player, reward.gold)
			end
			if reward.xp then
				PlayerDataService:AddPlayerXP(player, reward.xp)
			end
			if reward.orbs then
				local data = PlayerDataService:GetData(player)
				if data then
					data.CaptureOrbs = (data.CaptureOrbs or 5) + reward.orbs
				end
			end
			
			-- Notification
			local notify = remotes:FindFirstChild("NotifyPlayer")
			if notify then
				local rewardText = ""
				if reward.gold then rewardText = rewardText .. " +" .. reward.gold .. "💰" end
				if reward.xp then rewardText = rewardText .. " +" .. reward.xp .. "⭐" end
				if reward.orbs then rewardText = rewardText .. " +" .. reward.orbs .. "🔮" end
				notify:FireClient(player, "✅ Quête complétée: " .. quest.title .. " |" .. rewardText)
			end
			
			-- Marquer comme complété
			q.completed[questId] = true
			q.active[questId] = nil
			
			print("[QuestSystem] Quest completed:", quest.title, "for", player.Name)
			
			-- Si c'est une quête principale, activer la suivante
			if string.sub(questId, 1, 5) == "main_" then
				for _, nextQuest in ipairs(QUEST_TEMPLATES.main) do
					if not q.completed[nextQuest.id] and not q.active[nextQuest.id] then
						q.active[nextQuest.id] = {progress = 0, quest = nextQuest}
						if notify then
							task.delay(3, function()
								notify:FireClient(player, "📋 Nouvelle quête: " .. nextQuest.title .. " - " .. nextQuest.desc)
							end)
						end
						break
					end
				end
			end
		end
	end
end

-- === CONNEXION AUX EVENTS ===
Players.PlayerAdded:Connect(function(player)
	task.wait(2) -- Attendre que les données soient chargées
	initPlayerQuests(player)
	print("[QuestSystem] Quests initialized for", player.Name)
end)

Players.PlayerRemoving:Connect(function(player)
	playerQuests[player] = nil
end)

-- Remote pour demander la liste des quêtes
local questListRemote = remotes:WaitForChild("QuestList", 5)
if not questListRemote then
	questListRemote = Instance.new("RemoteEvent")
	questListRemote.Name = "QuestList"
	questListRemote.Parent = remotes
end

-- Remote pour les updates de quêtes
local questUpdateRemote = remotes:FindFirstChild("QuestUpdate")
if not questUpdateRemote then
	questUpdateRemote = Instance.new("RemoteEvent")
	questUpdateRemote.Name = "QuestUpdate"
	questUpdateRemote.Parent = remotes
end

-- Quand un joueur demande ses quêtes
questListRemote.OnServerEvent:Connect(function(player)
	local q = playerQuests[player]
	if not q then return end
	
	local questList = {}
	for questId, questData in pairs(q.active) do
		table.insert(questList, {
			id = questId,
			title = questData.quest.title,
			desc = questData.quest.desc,
			progress = questData.progress,
			target = questData.quest.target,
			reward = questData.quest.reward,
			isDaily = q.dailyActive[questId] or false,
			isMain = string.sub(questId, 1, 5) == "main_",
		})
	end
	
	questUpdateRemote:FireClient(player, questList)
end)

-- === API PUBLIQUE (pour être appelé par d'autres systems) ===
-- On écoute les remotes existants pour tracker la progression

-- Kill tracking
local attackRemote = remotes:FindFirstChild("PlayerAttack")
if attackRemote then
	-- Note: les kills sont gérés par MonsterSpawner qui fire NotifyPlayer
	-- On va plutôt hook sur le gold gagné par kill
end

-- Surveillance des événements via attributs joueur
task.spawn(function()
	while true do
		task.wait(5)
		for player, q in pairs(playerQuests) do
			if player.Parent then
				local data = PlayerDataService:GetData(player)
				if data then
					-- Track wave
					local currentWave = data.CurrentWave or 0
					if currentWave > (q._lastWave or 0) then
						checkQuestProgress(player, "wave", {wave = currentWave})
						checkQuestProgress(player, "wave_count", {})
						q._lastWave = currentWave
					end
					
					-- Track kills
					local totalKills = data.TotalKills or 0
					if totalKills > q.totalKills then
						local diff = totalKills - q.totalKills
						for i = 1, diff do
							checkQuestProgress(player, "kill", {})
						end
						q.totalKills = totalKills
					end
					
					-- Track captures
					local totalCaptures = data.TotalCaptures or 0
					if totalCaptures > q.totalCaptures then
						local diff = totalCaptures - q.totalCaptures
						for i = 1, diff do
							checkQuestProgress(player, "capture", {})
						end
						q.totalCaptures = totalCaptures
					end
					
					-- Track starter
					if data.HasStarter and not q.completed["main_2"] then
						checkQuestProgress(player, "get_starter", {})
					end
					
					-- Track class change
					if data.CurrentClass ~= "Novice" and not q.completed["main_7"] then
						checkQuestProgress(player, "change_class", {})
					end
					
					-- Track buildings
					local buildCount = 0
					if data.Buildings then
						for _, bData in pairs(data.Buildings) do
							if bData.Level and bData.Level > 0 then
								buildCount = buildCount + 1
							end
						end
					end
					local lastBuilds = q._lastBuilds or 0
					if buildCount > lastBuilds then
						for i = 1, buildCount - lastBuilds do
							checkQuestProgress(player, "build", {})
						end
						q._lastBuilds = buildCount
					end
				end
			end
		end
	end
end)

print("[QuestSystem V30] ✅ Quest system active! " .. #QUEST_TEMPLATES.main .. " main quests, " .. #QUEST_TEMPLATES.daily .. " daily quests, " .. #QUEST_TEMPLATES.zone .. " zone quests")
