--[[
	SimpleDialogue V35 - Dialogue NPC + Selection CLASSE (pas starter!)
	Quand le serveur fire ShowDialogueSimple, on affiche le choix de classe
	4 classes: Guerrier, Mage, Archer, Moine
	Chaque classe donne une arme adaptee + un monstre starter
]]

print("[SimpleDialogue V35] Script loaded!")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

if not player then
	print("[SimpleDialogue] No player!")
	return
end

local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then
	print("[SimpleDialogue] No PlayerGui!")
	return
end

-- Attendre les remotes
local remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
if not remotes then
	print("[SimpleDialogue] No remotes folder!")
	return
end

local changeClassRemote = remotes:WaitForChild("ChangeClass", 10)
print("[SimpleDialogue] ChangeClass:", changeClassRemote and "FOUND" or "MISSING")

-- === CLASS DATA (affichage local) ===
local CLASSES = {
	{
		name = "Guerrier",
		emoji = "⚔️",
		color = Color3.fromRGB(200, 50, 50),
		weapon = "Epee en bois",
		weaponEmoji = "🗡️",
		starter = "Flameguard 🔥",
		desc = "Force brute, haute defense\nArme: Epee en bois (melee)\nStarter: Flameguard",
		stats = "ATK +5 | DEF +3 | VIT +2",
	},
	{
		name = "Mage",
		emoji = "🔮",
		color = Color3.fromRGB(100, 50, 200),
		weapon = "Baguette magique",
		weaponEmoji = "🪄",
		starter = "Voltsprite ⚡",
		desc = "Boules de feu a distance\nArme: Baguette (distance, DoT)\nStarter: Voltsprite",
		stats = "ATK +7 | DEF +1 | VIT +1",
	},
	{
		name = "Archer",
		emoji = "🏹",
		color = Color3.fromRGB(40, 160, 40),
		weapon = "Arc en bois",
		weaponEmoji = "🏹",
		starter = "Shadeveil 🌑",
		desc = "Fleches a distance (infinies)\nArme: Arc (distance, precision)\nStarter: Shadeveil",
		stats = "ATK +4 | AGI +5 | DEF +1",
	},
	{
		name = "Moine",
		emoji = "🙏",
		color = Color3.fromRGB(255, 220, 50),
		weapon = "Poings",
		weaponEmoji = "👊",
		starter = "Aquashell 💧",
		desc = "Combat au corps a corps\nArme: Poings (melee, rapide)\nStarter: Aquashell",
		stats = "ATK +2 | DEF +4 | VIT +4",
	},
}

-- === AFFICHER LE DIALOGUE DE CLASSE ===
local function showClassSelection()
	print("[SimpleDialogue] SHOWING CLASS SELECTION!")
	
	-- Supprimer un ancien popup s'il existe
	local old = playerGui:FindFirstChild("DialoguePopup")
	if old then old:Destroy() end
	
	local gui = Instance.new("ScreenGui")
	gui.Name = "DialoguePopup"
	gui.ResetOnSpawn = false
	gui.Parent = playerGui
	
	-- Fond noir semi-transparent
	local bg = Instance.new("Frame")
	bg.Name = "Background"
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.new(0, 0, 0)
	bg.BackgroundTransparency = 0.4
	bg.Parent = gui
	
	-- Boite de dialogue
	local dialog = Instance.new("Frame")
	dialog.Name = "DialogBox"
	dialog.Size = UDim2.new(0, 850, 0, 520)
	dialog.AnchorPoint = Vector2.new(0.5, 0.5)
	dialog.Position = UDim2.new(0.5, 0, 0.5, 0)
	dialog.BackgroundColor3 = Color3.fromRGB(25, 18, 35)
	dialog.BorderSizePixel = 3
	dialog.BorderColor3 = Color3.fromRGB(200, 150, 80)
	dialog.Parent = gui
	
	-- Coins arrondis
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = dialog
	
	-- Titre Aldric
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -20, 0, 36)
	title.Position = UDim2.new(0, 10, 0, 8)
	title.BackgroundTransparency = 1
	title.TextSize = 22
	title.Font = Enum.Font.GothamBold
	title.TextColor3 = Color3.fromRGB(255, 220, 100)
	title.Text = "🧙 Guide Aldric"
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = dialog
	
	-- Texte dialogue
	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(1, -20, 0, 60)
	text.Position = UDim2.new(0, 10, 0, 44)
	text.BackgroundTransparency = 1
	text.TextSize = 13
	text.Font = Enum.Font.Gotham
	text.TextColor3 = Color3.new(0.95, 0.95, 0.95)
	text.TextWrapped = true
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.TextYAlignment = Enum.TextYAlignment.Top
	text.Text = "Bienvenue, heros ! Notre cristal magique est en danger !\nAvant de combattre, tu dois choisir ta CLASSE. Chaque classe a une arme unique et un monstre compagnon. Choisis bien !"
	text.Parent = dialog
	
	-- Titre section
	local classTitle = Instance.new("TextLabel")
	classTitle.Size = UDim2.new(1, 0, 0, 28)
	classTitle.Position = UDim2.new(0, 0, 0, 108)
	classTitle.BackgroundTransparency = 1
	classTitle.TextSize = 18
	classTitle.Font = Enum.Font.GothamBold
	classTitle.TextColor3 = Color3.fromRGB(255, 180, 50)
	classTitle.Text = "⚔️ CHOISIS TA CLASSE ⚔️"
	classTitle.Parent = dialog
	
	-- 4 cartes de classe
	for i, cls in ipairs(CLASSES) do
		local cardX = 16 + ((i - 1) * 205)
		
		local card = Instance.new("Frame")
		card.Name = "Card_" .. cls.name
		card.Size = UDim2.new(0, 195, 0, 360)
		card.Position = UDim2.new(0, cardX, 0, 140)
		card.BackgroundColor3 = Color3.fromRGB(40, 35, 55)
		card.BorderSizePixel = 2
		card.BorderColor3 = cls.color
		card.Parent = dialog
		
		local cardCorner = Instance.new("UICorner")
		cardCorner.CornerRadius = UDim.new(0, 8)
		cardCorner.Parent = card
		
		-- Emoji classe
		local emojiLabel = Instance.new("TextLabel")
		emojiLabel.Size = UDim2.new(1, 0, 0, 50)
		emojiLabel.Position = UDim2.new(0, 0, 0, 5)
		emojiLabel.BackgroundTransparency = 1
		emojiLabel.TextSize = 38
		emojiLabel.Text = cls.emoji
		emojiLabel.Parent = card
		
		-- Nom classe
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1, -10, 0, 24)
		nameLabel.Position = UDim2.new(0, 5, 0, 55)
		nameLabel.BackgroundTransparency = 1
		nameLabel.TextSize = 17
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextColor3 = cls.color
		nameLabel.Text = cls.name
		nameLabel.Parent = card
		
		-- Arme
		local weaponLabel = Instance.new("TextLabel")
		weaponLabel.Size = UDim2.new(1, -10, 0, 18)
		weaponLabel.Position = UDim2.new(0, 5, 0, 82)
		weaponLabel.BackgroundTransparency = 1
		weaponLabel.TextSize = 11
		weaponLabel.Font = Enum.Font.GothamBold
		weaponLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
		weaponLabel.Text = cls.weaponEmoji .. " " .. cls.weapon
		weaponLabel.Parent = card
		
		-- Description
		local descLabel = Instance.new("TextLabel")
		descLabel.Size = UDim2.new(1, -10, 0, 60)
		descLabel.Position = UDim2.new(0, 5, 0, 104)
		descLabel.BackgroundTransparency = 1
		descLabel.TextSize = 10
		descLabel.Font = Enum.Font.Gotham
		descLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
		descLabel.TextWrapped = true
		descLabel.TextYAlignment = Enum.TextYAlignment.Top
		descLabel.Text = cls.desc
		descLabel.Parent = card
		
		-- Stats
		local statsLabel = Instance.new("TextLabel")
		statsLabel.Size = UDim2.new(1, -10, 0, 16)
		statsLabel.Position = UDim2.new(0, 5, 0, 168)
		statsLabel.BackgroundTransparency = 1
		statsLabel.TextSize = 9
		statsLabel.Font = Enum.Font.Gotham
		statsLabel.TextColor3 = Color3.fromRGB(150, 200, 150)
		statsLabel.Text = cls.stats
		statsLabel.Parent = card

		-- Monstre starter
		local starterLabel = Instance.new("TextLabel")
		starterLabel.Size = UDim2.new(1, -10, 0, 18)
		starterLabel.Position = UDim2.new(0, 5, 0, 188)
		starterLabel.BackgroundTransparency = 1
		starterLabel.TextSize = 10
		starterLabel.Font = Enum.Font.Gotham
		starterLabel.TextColor3 = Color3.fromRGB(180, 180, 255)
		starterLabel.Text = "Compagnon: " .. cls.starter
		starterLabel.Parent = card
		
		-- Separator line
		local sep = Instance.new("Frame")
		sep.Size = UDim2.new(0.85, 0, 0, 1)
		sep.Position = UDim2.new(0.075, 0, 0, 215)
		sep.BackgroundColor3 = cls.color
		sep.BackgroundTransparency = 0.5
		sep.BorderSizePixel = 0
		sep.Parent = card
		
		-- Bouton CHOISIR
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -20, 0, 42)
		btn.Position = UDim2.new(0, 10, 0, 228)
		btn.BackgroundColor3 = cls.color
		btn.TextSize = 15
		btn.Font = Enum.Font.GothamBold
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.Text = "CHOISIR " .. cls.name:upper()
		btn.Parent = card
		
		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 6)
		btnCorner.Parent = btn
		
		-- Hover effect
		local origColor = cls.color
		btn.MouseEnter:Connect(function()
			btn.BackgroundColor3 = Color3.new(
				math.min(1, origColor.R * 1.3),
				math.min(1, origColor.G * 1.3),
				math.min(1, origColor.B * 1.3)
			)
		end)
		btn.MouseLeave:Connect(function()
			btn.BackgroundColor3 = origColor
		end)
		
		btn.MouseButton1Click:Connect(function()
			print("[SimpleDialogue] Class chosen:", cls.name)
			
			-- Fire au serveur (ChangeClass remote)
			if changeClassRemote then
				changeClassRemote:FireServer(cls.name)
				print("[SimpleDialogue] Fired ChangeClass with", cls.name)
			else
				warn("[SimpleDialogue] ChangeClass remote not found!")
			end
			
			-- Message de confirmation
			for _, child in ipairs(dialog:GetChildren()) do
				if child:IsA("GuiObject") then
					child:Destroy()
				end
			end
			
			local confirmText = Instance.new("TextLabel")
			confirmText.Size = UDim2.new(1, -40, 1, -40)
			confirmText.Position = UDim2.new(0, 20, 0, 20)
			confirmText.BackgroundTransparency = 1
			confirmText.TextSize = 24
			confirmText.Font = Enum.Font.GothamBold
			confirmText.TextColor3 = cls.color
			confirmText.TextWrapped = true
			confirmText.Text = cls.emoji .. " Tu es maintenant " .. cls.name .. " !\n\n"
				.. cls.weaponEmoji .. " Arme: " .. cls.weapon .. "\n"
				.. "🐾 Compagnon: " .. cls.starter .. "\n\n"
				.. "Les monstres vont commencer a apparaitre...\nBonne chance, heros !"
			confirmText.Parent = dialog
			
			-- Fermer apres 4 secondes
			task.delay(4, function()
				if gui and gui.Parent then
					gui:Destroy()
				end
			end)
		end)
	end
	
	-- Bouton fermer (X) en haut a droite
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 35, 0, 35)
	closeBtn.Position = UDim2.new(1, -40, 0, 5)
	closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
	closeBtn.TextSize = 20
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextColor3 = Color3.new(1, 1, 1)
	closeBtn.Text = "X"
	closeBtn.Parent = dialog
	
	local closeBtnCorner = Instance.new("UICorner")
	closeBtnCorner.CornerRadius = UDim.new(0, 6)
	closeBtnCorner.Parent = closeBtn
	
	closeBtn.MouseButton1Click:Connect(function()
		gui:Destroy()
	end)
end

-- === ECOUTER LE SERVEUR ===
local showDialogueSimple = remotes:WaitForChild("ShowDialogueSimple", 10)
if showDialogueSimple then
	print("[SimpleDialogue] ShowDialogueSimple remote FOUND! Connecting...")
	showDialogueSimple.OnClientEvent:Connect(function()
		print("[SimpleDialogue] SERVER FIRED ShowDialogueSimple! Showing class selection!")
		showClassSelection()
	end)
	print("[SimpleDialogue] Listener connected!")
else
	warn("[SimpleDialogue] ShowDialogueSimple remote NOT FOUND!")
end

print("[SimpleDialogue V35] Ready! Waiting for NPC interaction (class selection)...")
