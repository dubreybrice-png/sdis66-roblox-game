--[[
	QuestUI V30 - Interface des quêtes côté client
	Touche Q pour ouvrir/fermer le panneau des quêtes
	Affiche quêtes principales, quotidiennes, de zone
	Barres de progression, récompenses
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

print("[QuestUI V30] Loading...")

-- Attendre les remotes
local remotes = ReplicatedStorage:WaitForChild("Remotes", 15)
if not remotes then
	warn("[QuestUI] Remotes not found!")
	return
end

local questListRemote = remotes:WaitForChild("QuestList", 10)
local questUpdateRemote = remotes:WaitForChild("QuestUpdate", 10)

-- === COULEURS ===
local COLORS = {
	bg = Color3.fromRGB(15, 15, 30),
	panel = Color3.fromRGB(25, 25, 50),
	main = Color3.fromRGB(255, 200, 50),
	daily = Color3.fromRGB(100, 200, 255),
	zone = Color3.fromRGB(100, 255, 100),
	text = Color3.fromRGB(230, 230, 230),
	progressBg = Color3.fromRGB(40, 40, 60),
	progressFill = Color3.fromRGB(100, 255, 100),
	gold = Color3.fromRGB(255, 220, 100),
	xp = Color3.fromRGB(100, 200, 255),
}

-- === CRÉER L'UI ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "QuestUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Panneau principal (caché par défaut)
local mainPanel = Instance.new("Frame")
mainPanel.Name = "QuestPanel"
mainPanel.Size = UDim2.new(0, 380, 0, 500)
mainPanel.Position = UDim2.new(0, 15, 0.5, -250)
mainPanel.BackgroundColor3 = COLORS.bg
mainPanel.BackgroundTransparency = 0.05
mainPanel.BorderSizePixel = 0
mainPanel.Visible = false
mainPanel.Parent = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 12)
panelCorner.Parent = mainPanel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(80, 80, 120)
panelStroke.Thickness = 2
panelStroke.Parent = mainPanel

-- Titre
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
title.BackgroundTransparency = 0
title.Text = "📋 QUÊTES"
title.TextScaled = true
title.TextColor3 = COLORS.main
title.Font = Enum.Font.GothamBold
title.Parent = mainPanel

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = title

-- Hint en bas
local hint = Instance.new("TextLabel")
hint.Size = UDim2.new(1, 0, 0, 25)
hint.Position = UDim2.new(0, 0, 1, -25)
hint.BackgroundTransparency = 1
hint.Text = "[Q] Fermer  •  Quêtes quotidiennes se réinitialisent toutes les 20 min"
hint.TextScaled = true
hint.TextColor3 = Color3.fromRGB(120, 120, 150)
hint.Font = Enum.Font.Gotham
hint.Parent = mainPanel

-- ScrollFrame pour les quêtes
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -80)
scrollFrame.Position = UDim2.new(0, 10, 0, 50)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be updated
scrollFrame.Parent = mainPanel

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 6)
listLayout.Parent = scrollFrame

-- Indicateur mini (toujours visible quand panneau fermé)
local miniIndicator = Instance.new("TextButton")
miniIndicator.Name = "QuestMini"
miniIndicator.Size = UDim2.new(0, 40, 0, 40)
miniIndicator.Position = UDim2.new(0, 10, 0.5, -20)
miniIndicator.BackgroundColor3 = COLORS.bg
miniIndicator.BackgroundTransparency = 0.2
miniIndicator.Text = "📋"
miniIndicator.TextScaled = true
miniIndicator.Font = Enum.Font.GothamBold
miniIndicator.Parent = screenGui

local miniCorner = Instance.new("UICorner")
miniCorner.CornerRadius = UDim.new(0, 10)
miniCorner.Parent = miniIndicator

miniIndicator.MouseButton1Click:Connect(function()
	mainPanel.Visible = not mainPanel.Visible
	miniIndicator.Visible = not mainPanel.Visible
	if mainPanel.Visible and questListRemote then
		questListRemote:FireServer()
	end
end)

-- === CRÉER UNE CARTE DE QUÊTE ===
local function createQuestCard(questData, layoutOrder)
	local card = Instance.new("Frame")
	card.Name = "Quest_" .. (questData.id or "unknown")
	card.Size = UDim2.new(1, 0, 0, 80)
	card.BackgroundColor3 = COLORS.panel
	card.BackgroundTransparency = 0.1
	card.LayoutOrder = layoutOrder or 0
	
	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 8)
	cardCorner.Parent = card
	
	-- Barre de catégorie (couleur selon type)
	local catColor = COLORS.text
	local catText = ""
	if questData.isMain then
		catColor = COLORS.main
		catText = "⭐ PRINCIPALE"
	elseif questData.isDaily then
		catColor = COLORS.daily
		catText = "📅 QUOTIDIENNE"
	else
		catColor = COLORS.zone
		catText = "🌍 ZONE"
	end
	
	local catBar = Instance.new("Frame")
	catBar.Size = UDim2.new(0, 4, 1, -8)
	catBar.Position = UDim2.new(0, 4, 0, 4)
	catBar.BackgroundColor3 = catColor
	catBar.Parent = card
	
	local catCorner2 = Instance.new("UICorner")
	catCorner2.CornerRadius = UDim.new(0, 2)
	catCorner2.Parent = catBar
	
	-- Titre de la quête
	local questTitle = Instance.new("TextLabel")
	questTitle.Size = UDim2.new(0.7, -15, 0, 22)
	questTitle.Position = UDim2.new(0, 15, 0, 4)
	questTitle.BackgroundTransparency = 1
	questTitle.Text = questData.title or "???"
	questTitle.TextScaled = true
	questTitle.TextColor3 = catColor
	questTitle.Font = Enum.Font.GothamBold
	questTitle.TextXAlignment = Enum.TextXAlignment.Left
	questTitle.Parent = card
	
	-- Tag catégorie
	local catLabel = Instance.new("TextLabel")
	catLabel.Size = UDim2.new(0.3, 0, 0, 18)
	catLabel.Position = UDim2.new(0.7, 0, 0, 6)
	catLabel.BackgroundTransparency = 1
	catLabel.Text = catText
	catLabel.TextScaled = true
	catLabel.TextColor3 = catColor
	catLabel.Font = Enum.Font.Gotham
	catLabel.TextXAlignment = Enum.TextXAlignment.Right
	catLabel.Parent = card
	
	-- Description
	local desc = Instance.new("TextLabel")
	desc.Size = UDim2.new(1, -20, 0, 18)
	desc.Position = UDim2.new(0, 15, 0, 26)
	desc.BackgroundTransparency = 1
	desc.Text = questData.desc or ""
	desc.TextScaled = true
	desc.TextColor3 = Color3.fromRGB(180, 180, 200)
	desc.Font = Enum.Font.Gotham
	desc.TextXAlignment = Enum.TextXAlignment.Left
	desc.Parent = card
	
	-- Barre de progression
	local progressBg = Instance.new("Frame")
	progressBg.Size = UDim2.new(0.6, -15, 0, 10)
	progressBg.Position = UDim2.new(0, 15, 0, 48)
	progressBg.BackgroundColor3 = COLORS.progressBg
	progressBg.Parent = card
	
	local progressCorner = Instance.new("UICorner")
	progressCorner.CornerRadius = UDim.new(0, 5)
	progressCorner.Parent = progressBg
	
	local progress = questData.progress or 0
	local target = questData.target or 1
	local ratio = math.clamp(progress / target, 0, 1)
	
	local progressFill = Instance.new("Frame")
	progressFill.Size = UDim2.new(ratio, 0, 1, 0)
	progressFill.BackgroundColor3 = ratio >= 1 and Color3.fromRGB(100, 255, 100) or catColor
	progressFill.Parent = progressBg
	
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 5)
	fillCorner.Parent = progressFill
	
	-- Texte progression
	local progressText = Instance.new("TextLabel")
	progressText.Size = UDim2.new(0.4, -15, 0, 14)
	progressText.Position = UDim2.new(0.6, 0, 0, 46)
	progressText.BackgroundTransparency = 1
	progressText.Text = progress .. " / " .. target
	progressText.TextScaled = true
	progressText.TextColor3 = Color3.fromRGB(200, 200, 220)
	progressText.Font = Enum.Font.GothamBold
	progressText.TextXAlignment = Enum.TextXAlignment.Right
	progressText.Parent = card
	
	-- Récompenses
	local rewardText = ""
	local reward = questData.reward
	if reward then
		if reward.gold then rewardText = rewardText .. "💰" .. reward.gold .. "  " end
		if reward.xp then rewardText = rewardText .. "⭐" .. reward.xp .. "  " end
		if reward.orbs then rewardText = rewardText .. "🔮" .. reward.orbs end
	end
	
	local rewardLabel = Instance.new("TextLabel")
	rewardLabel.Size = UDim2.new(1, -20, 0, 16)
	rewardLabel.Position = UDim2.new(0, 15, 0, 60)
	rewardLabel.BackgroundTransparency = 1
	rewardLabel.Text = "Récompenses: " .. rewardText
	rewardLabel.TextScaled = true
	rewardLabel.TextColor3 = COLORS.gold
	rewardLabel.Font = Enum.Font.Gotham
	rewardLabel.TextXAlignment = Enum.TextXAlignment.Left
	rewardLabel.Parent = card
	
	return card
end

-- === METTRE À JOUR LA LISTE ===
local function updateQuestList(quests)
	-- Vider
	for _, child in ipairs(scrollFrame:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	
	if not quests or #quests == 0 then
		local empty = Instance.new("TextLabel")
		empty.Size = UDim2.new(1, 0, 0, 50)
		empty.BackgroundTransparency = 1
		empty.Text = "Aucune quête active"
		empty.TextScaled = true
		empty.TextColor3 = Color3.fromRGB(120, 120, 150)
		empty.Font = Enum.Font.Gotham
		empty.Parent = scrollFrame
		return
	end
	
	-- Trier: principales d'abord, puis quotidiennes, puis zones
	table.sort(quests, function(a, b)
		local orderA = a.isMain and 0 or (a.isDaily and 1 or 2)
		local orderB = b.isMain and 0 or (b.isDaily and 1 or 2)
		return orderA < orderB
	end)
	
	for i, quest in ipairs(quests) do
		local card = createQuestCard(quest, i)
		card.Parent = scrollFrame
	end
	
	-- Ajuster la taille du canvas
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #quests * 86)
end

-- === ÉCOUTER LES UPDATES ===
if questUpdateRemote then
	questUpdateRemote.OnClientEvent:Connect(function(quests)
		updateQuestList(quests)
	end)
end

-- === TOGGLE AVEC TOUCHE Q ===
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.Q then
		mainPanel.Visible = not mainPanel.Visible
		miniIndicator.Visible = not mainPanel.Visible
		if mainPanel.Visible and questListRemote then
			questListRemote:FireServer()
		end
	end
end)

-- Demander les quêtes au démarrage (après un délai)
task.delay(5, function()
	if questListRemote then
		questListRemote:FireServer()
	end
end)

-- Rafraîchir toutes les 30 secondes si ouvert
task.spawn(function()
	while true do
		task.wait(30)
		if mainPanel.Visible and questListRemote then
			questListRemote:FireServer()
		end
	end
end)

print("[QuestUI V30] ✅ Quest UI ready! Press Q to toggle")
