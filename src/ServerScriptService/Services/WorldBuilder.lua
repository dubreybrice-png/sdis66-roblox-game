--[[
	WorldBuilder V30 - MEGA UPDATE
	Crée une ville détaillée avec vrais bâtiments, fontaine centrale,
	murailles, zones thématiques, ponts, tours de garde, jardins
]]

local WorldBuilder = {}

-- === HELPER: Créer un bâtiment complet ===
local function createBuilding(parent, name, pos, size, wallColor, roofColor, roofStyle, extras)
	local building = Instance.new("Model")
	building.Name = name
	
	-- Fondation
	local foundation = Instance.new("Part")
	foundation.Name = "Foundation"
	foundation.Size = Vector3.new(size.X + 2, 0.5, size.Z + 2)
	foundation.Position = pos + Vector3.new(0, 0.25, 0)
	foundation.Anchored = true
	foundation.Material = Enum.Material.Concrete
	foundation.BrickColor = BrickColor.new("Medium stone grey")
	foundation.Parent = building
	
	-- Murs (4 côtés)
	local wallHeight = size.Y
	local wallThick = 1
	local wallDefs = {
		{s = Vector3.new(size.X, wallHeight, wallThick), o = Vector3.new(0, wallHeight/2 + 0.5, size.Z/2)},
		{s = Vector3.new(size.X, wallHeight, wallThick), o = Vector3.new(0, wallHeight/2 + 0.5, -size.Z/2)},
		{s = Vector3.new(wallThick, wallHeight, size.Z), o = Vector3.new(size.X/2, wallHeight/2 + 0.5, 0)},
		{s = Vector3.new(wallThick, wallHeight, size.Z), o = Vector3.new(-size.X/2, wallHeight/2 + 0.5, 0)},
	}
	for i, wd in ipairs(wallDefs) do
		local wall = Instance.new("Part")
		wall.Name = "Wall_" .. i
		wall.Size = wd.s
		wall.Position = pos + wd.o
		wall.Anchored = true
		wall.Material = Enum.Material.Brick
		wall.BrickColor = BrickColor.new(wallColor)
		wall.Parent = building
	end
	
	-- Toit
	if roofStyle == "flat" then
		local roof = Instance.new("Part")
		roof.Name = "Roof"
		roof.Size = Vector3.new(size.X + 3, 1, size.Z + 3)
		roof.Position = pos + Vector3.new(0, wallHeight + 1, 0)
		roof.Anchored = true
		roof.Material = Enum.Material.Slate
		roof.BrickColor = BrickColor.new(roofColor)
		roof.Parent = building
	elseif roofStyle == "peaked" then
		-- Toit en triangle (2 pentes)
		for side = -1, 1, 2 do
			local roofSide = Instance.new("Part")
			roofSide.Name = "RoofSide_" .. (side == -1 and "L" or "R")
			roofSide.Size = Vector3.new(size.X + 3, 1.5, size.Z/2 + 2)
			roofSide.CFrame = CFrame.new(pos + Vector3.new(0, wallHeight + 2.5, side * size.Z/4))
				* CFrame.Angles(side * math.rad(20), 0, 0)
			roofSide.Anchored = true
			roofSide.Material = Enum.Material.Slate
			roofSide.BrickColor = BrickColor.new(roofColor)
			roofSide.Parent = building
		end
	elseif roofStyle == "tower" then
		-- Toit de tour (pyramidal simulé par une grande pièce inclinée)
		local top = Instance.new("Part")
		top.Name = "TowerTop"
		top.Size = Vector3.new(size.X * 0.6, size.Y * 0.4, size.Z * 0.6)
		top.Position = pos + Vector3.new(0, wallHeight + size.Y * 0.2 + 0.5, 0)
		top.Anchored = true
		top.Material = Enum.Material.Slate
		top.BrickColor = BrickColor.new(roofColor)
		top.Parent = building
		
		local spire = Instance.new("Part")
		spire.Name = "Spire"
		spire.Size = Vector3.new(1, size.Y * 0.3, 1)
		spire.Position = pos + Vector3.new(0, wallHeight + size.Y * 0.55, 0)
		spire.Anchored = true
		spire.Material = Enum.Material.Metal
		spire.BrickColor = BrickColor.new("Gold")
		spire.Parent = building
	end
	
	-- Porte
	local door = Instance.new("Part")
	door.Name = "Door"
	door.Size = Vector3.new(4, 6, 0.5)
	door.Position = pos + Vector3.new(0, 3.5, size.Z/2 + 0.3)
	door.Anchored = true
	door.Material = Enum.Material.Wood
	door.BrickColor = BrickColor.new("Dark orange")
	door.Parent = building
	
	-- Fenêtres (2 de chaque côté)
	for side = -1, 1, 2 do
		for h = 1, 2 do
			local window = Instance.new("Part")
			window.Name = "Window"
			window.Size = Vector3.new(0.3, 3, 2.5)
			window.Position = pos + Vector3.new(side * (size.X/2 + 0.2), 3 + (h-1)*4, 0)
			window.Anchored = true
			window.Material = Enum.Material.Glass
			window.BrickColor = BrickColor.new("Cyan")
			window.Transparency = 0.4
			window.Parent = building
			if h > 1 and wallHeight < 10 then break end
		end
	end
	
	-- Extras optionnels
	if extras then
		if extras.sign then
			local signPart = Instance.new("Part")
			signPart.Name = "Sign"
			signPart.Size = Vector3.new(8, 3, 0.5)
			signPart.Position = pos + Vector3.new(0, wallHeight + 3, size.Z/2 + 1)
			signPart.Anchored = true
			signPart.Material = Enum.Material.Wood
			signPart.BrickColor = BrickColor.new("Dark orange")
			signPart.Parent = building
			
			local gui = Instance.new("SurfaceGui")
			gui.Face = Enum.NormalId.Front
			gui.Parent = signPart
			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, 0, 1, 0)
			label.BackgroundTransparency = 1
			label.Text = extras.sign
			label.TextScaled = true
			label.TextColor3 = Color3.fromRGB(255, 220, 100)
			label.Font = Enum.Font.GothamBold
			label.Parent = gui
		end
		if extras.light then
			local light = Instance.new("PointLight")
			light.Brightness = 1.5
			light.Range = 25
			light.Color = extras.lightColor or Color3.new(1, 0.9, 0.7)
			light.Parent = foundation
		end
		if extras.chimney then
			local chimney = Instance.new("Part")
			chimney.Name = "Chimney"
			chimney.Size = Vector3.new(2, 4, 2)
			chimney.Position = pos + Vector3.new(size.X/3, wallHeight + 3, -size.Z/4)
			chimney.Anchored = true
			chimney.Material = Enum.Material.Brick
			chimney.BrickColor = BrickColor.new("Dark stone grey")
			chimney.Parent = building
			
			local smoke = Instance.new("ParticleEmitter")
			smoke.Color = ColorSequence.new(Color3.fromRGB(100, 100, 100))
			smoke.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.5),
				NumberSequenceKeypoint.new(1, 4)
			})
			smoke.Lifetime = NumberRange.new(3, 6)
			smoke.Rate = 5
			smoke.Speed = NumberRange.new(1, 3)
			smoke.SpreadAngle = Vector2.new(10, 10)
			smoke.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.3),
				NumberSequenceKeypoint.new(1, 1)
			})
			smoke.Parent = chimney
		end
	end
	
	building.PrimaryPart = foundation
	building.Parent = parent
	return building
end

-- === HELPER: Créer un arbre détaillé ===
local function createTree(parent, pos, treeType)
	local tree = Instance.new("Model")
	tree.Name = "Tree"
	
	local trunkH = math.random(8, 15)
	local trunkW = math.random(1, 3)
	
	local trunk = Instance.new("Part")
	trunk.Name = "Trunk"
	trunk.Size = Vector3.new(trunkW, trunkH, trunkW)
	trunk.Position = pos + Vector3.new(0, trunkH/2, 0)
	trunk.Anchored = true
	trunk.Material = Enum.Material.Wood
	trunk.BrickColor = BrickColor.new(treeType == "dark" and "Really black" or "Brown")
	trunk.Parent = tree
	
	if treeType == "pine" then
		-- Sapin (3 niveaux de feuillage)
		for layer = 1, 3 do
			local leaves = Instance.new("Part")
			leaves.Name = "Leaves" .. layer
			local leafSize = 10 - layer * 2.5
			leaves.Size = Vector3.new(leafSize, 3, leafSize)
			leaves.Position = pos + Vector3.new(0, trunkH - 2 + layer * 3, 0)
			leaves.Anchored = true
			leaves.Material = Enum.Material.Grass
			leaves.BrickColor = BrickColor.new("Dark green")
			leaves.Parent = tree
		end
	elseif treeType == "dark" then
		-- Arbre mort/sombre
		local leaves = Instance.new("Part")
		leaves.Shape = Enum.PartType.Ball
		leaves.Name = "DarkLeaves"
		leaves.Size = Vector3.new(8, 6, 8)
		leaves.Position = pos + Vector3.new(0, trunkH + 2, 0)
		leaves.Anchored = true
		leaves.Material = Enum.Material.Slate
		leaves.BrickColor = BrickColor.new("Dark indigo")
		leaves.Transparency = 0.2
		leaves.Parent = tree
		
		-- Particules violettes
		local particles = Instance.new("ParticleEmitter")
		particles.Color = ColorSequence.new(Color3.fromRGB(100, 0, 150))
		particles.Size = NumberSequence.new(0.3, 0)
		particles.Lifetime = NumberRange.new(2, 4)
		particles.Rate = 3
		particles.Speed = NumberRange.new(0.5, 1)
		particles.Parent = leaves
	elseif treeType == "palm" then
		-- Palmier
		for i = 1, 5 do
			local frond = Instance.new("Part")
			frond.Name = "Frond" .. i
			local angle = (i / 5) * math.pi * 2
			frond.Size = Vector3.new(1, 0.3, 8)
			frond.CFrame = CFrame.new(pos + Vector3.new(math.cos(angle) * 3, trunkH, math.sin(angle) * 3))
				* CFrame.Angles(math.rad(30), angle, 0)
			frond.Anchored = true
			frond.Material = Enum.Material.Grass
			frond.BrickColor = BrickColor.new("Lime green")
			frond.Parent = tree
		end
	else
		-- Arbre normal (rond)
		local leaves = Instance.new("Part")
		leaves.Shape = Enum.PartType.Ball
		leaves.Name = "Leaves"
		leaves.Size = Vector3.new(10, 8, 10)
		leaves.Position = pos + Vector3.new(0, trunkH + 3, 0)
		leaves.Anchored = true
		leaves.Material = Enum.Material.Grass
		leaves.BrickColor = BrickColor.new("Earth green")
		leaves.Parent = tree
	end
	
	tree.Parent = parent
	return tree
end

-- === HELPER: Créer une lampe/torche ===
local function createLamp(parent, pos, style)
	local lamp = Instance.new("Model")
	lamp.Name = "Lamp"
	
	local pole = Instance.new("Part")
	pole.Name = "Pole"
	pole.Size = Vector3.new(0.5, 8, 0.5)
	pole.Position = pos + Vector3.new(0, 4, 0)
	pole.Anchored = true
	pole.Material = style == "medieval" and Enum.Material.Wood or Enum.Material.Metal
	pole.BrickColor = BrickColor.new(style == "medieval" and "Dark orange" or "Dark stone grey")
	pole.Parent = lamp
	
	local bulb = Instance.new("Part")
	bulb.Name = "Bulb"
	bulb.Shape = Enum.PartType.Ball
	bulb.Size = Vector3.new(2, 2, 2)
	bulb.Position = pos + Vector3.new(0, 8.5, 0)
	bulb.Anchored = true
	bulb.Material = Enum.Material.Neon
	bulb.BrickColor = BrickColor.new("New Yeller")
	bulb.Parent = lamp
	
	local light = Instance.new("PointLight")
	light.Brightness = 2
	light.Range = 30
	light.Color = Color3.fromRGB(255, 220, 150)
	light.Parent = bulb
	
	lamp.Parent = parent
	return lamp
end

-- === HELPER: Créer un mur de ville ===
local function createCityWall(parent, startPos, endPos, height, hasGate)
	height = height or 12
	local dx = endPos.X - startPos.X
	local dz = endPos.Z - startPos.Z
	local length = math.sqrt(dx*dx + dz*dz)
	local midPoint = (startPos + endPos) / 2
	local angle = math.atan2(dx, dz)
	
	if hasGate then
		-- Mur avec porte au milieu
		local halfLen = (length - 12) / 2
		for side = -1, 1, 2 do
			local wall = Instance.new("Part")
			wall.Name = "CityWall"
			wall.Size = Vector3.new(3, height, halfLen)
			local offset = side * (halfLen/2 + 6)
			wall.CFrame = CFrame.new(midPoint + Vector3.new(0, height/2, 0))
				* CFrame.Angles(0, angle, 0)
				* CFrame.new(0, 0, offset)
			wall.Anchored = true
			wall.Material = Enum.Material.Brick
			wall.BrickColor = BrickColor.new("Medium stone grey")
			wall.Parent = parent
		end
		
		-- Arche de la porte
		local arch = Instance.new("Part")
		arch.Name = "GateArch"
		arch.Size = Vector3.new(3, 4, 14)
		arch.CFrame = CFrame.new(midPoint + Vector3.new(0, height - 2, 0))
			* CFrame.Angles(0, angle, 0)
		arch.Anchored = true
		arch.Material = Enum.Material.Brick
		arch.BrickColor = BrickColor.new("Dark stone grey")
		arch.Parent = parent
		
		-- Panneau sur la porte
		local signPart = Instance.new("Part")
		signPart.Name = "GateSign"
		signPart.Size = Vector3.new(0.5, 3, 10)
		signPart.CFrame = CFrame.new(midPoint + Vector3.new(0, height + 2, 0))
			* CFrame.Angles(0, angle, 0)
		signPart.Anchored = true
		signPart.Material = Enum.Material.Wood
		signPart.BrickColor = BrickColor.new("Dark orange")
		signPart.Parent = parent
	else
		local wall = Instance.new("Part")
		wall.Name = "CityWall"
		wall.Size = Vector3.new(3, height, length)
		wall.CFrame = CFrame.new(midPoint + Vector3.new(0, height/2, 0))
			* CFrame.Angles(0, angle, 0)
		wall.Anchored = true
		wall.Material = Enum.Material.Brick
		wall.BrickColor = BrickColor.new("Medium stone grey")
		wall.Parent = parent
	end
end

-- === HELPER: Tour de garde ===
local function createWatchTower(parent, pos, name)
	local tower = Instance.new("Model")
	tower.Name = name or "WatchTower"
	
	-- Base
	local base = Instance.new("Part")
	base.Name = "Base"
	base.Size = Vector3.new(8, 20, 8)
	base.Position = pos + Vector3.new(0, 10, 0)
	base.Anchored = true
	base.Material = Enum.Material.Brick
	base.BrickColor = BrickColor.new("Medium stone grey")
	base.Parent = tower
	
	-- Plateforme supérieure
	local platform = Instance.new("Part")
	platform.Name = "Platform"
	platform.Size = Vector3.new(12, 1, 12)
	platform.Position = pos + Vector3.new(0, 20.5, 0)
	platform.Anchored = true
	platform.Material = Enum.Material.Brick
	platform.BrickColor = BrickColor.new("Dark stone grey")
	platform.Parent = tower
	
	-- Créneaux
	for i = 1, 4 do
		local angle = (i / 4) * math.pi * 2
		local merlon = Instance.new("Part")
		merlon.Name = "Merlon" .. i
		merlon.Size = Vector3.new(2, 3, 2)
		merlon.Position = pos + Vector3.new(math.cos(angle) * 5, 22.5, math.sin(angle) * 5)
		merlon.Anchored = true
		merlon.Material = Enum.Material.Brick
		merlon.BrickColor = BrickColor.new("Medium stone grey")
		merlon.Parent = tower
	end
	
	-- Toit conique
	local roof = Instance.new("Part")
	roof.Name = "Roof"
	roof.Size = Vector3.new(10, 6, 10)
	roof.Position = pos + Vector3.new(0, 27, 0)
	roof.Anchored = true
	roof.Material = Enum.Material.Slate
	roof.BrickColor = BrickColor.new("Dark red")
	roof.Parent = tower
	
	-- Lumière
	local light = Instance.new("PointLight")
	light.Brightness = 2.5
	light.Range = 50
	light.Color = Color3.fromRGB(255, 200, 100)
	light.Parent = platform
	
	-- Drapeau
	local flagPole = Instance.new("Part")
	flagPole.Name = "FlagPole"
	flagPole.Size = Vector3.new(0.3, 8, 0.3)
	flagPole.Position = pos + Vector3.new(0, 34, 0)
	flagPole.Anchored = true
	flagPole.Material = Enum.Material.Metal
	flagPole.BrickColor = BrickColor.new("Gold")
	flagPole.Parent = tower
	
	local flag = Instance.new("Part")
	flag.Name = "Flag"
	flag.Size = Vector3.new(0.1, 3, 5)
	flag.Position = pos + Vector3.new(0, 36, 2.5)
	flag.Anchored = true
	flag.Material = Enum.Material.Fabric
	flag.BrickColor = BrickColor.new("Bright red")
	flag.Parent = tower
	
	tower.Parent = parent
	return tower
end

-- ============================================================
-- CRISTAL CENTRAL
-- ============================================================
function WorldBuilder.CreateCrystal()
	print("🔵 WorldBuilder V30 - CreateCrystal()")
	local ws = game.Workspace
	
	local oldCrystal = ws:FindFirstChild("Crystal")
	if oldCrystal then oldCrystal:Destroy() end
	
	-- Base circulaire ornée
	local base = Instance.new("Part")
	base.Name = "CrystalBase"
	base.Shape = Enum.PartType.Cylinder
	base.Size = Vector3.new(2, 18, 18)
	base.CFrame = CFrame.new(0, 1, 0) * CFrame.Angles(0, 0, math.rad(90))
	base.Anchored = true
	base.Material = Enum.Material.Marble
	base.BrickColor = BrickColor.new("Institutional white")
	base.Parent = ws
	
	-- Anneau extérieur
	for i = 1, 12 do
		local angle = (i / 12) * math.pi * 2
		local pillar = Instance.new("Part")
		pillar.Name = "BasePillar" .. i
		pillar.Size = Vector3.new(1.5, 3, 1.5)
		pillar.Position = Vector3.new(math.cos(angle) * 8, 1.5, math.sin(angle) * 8)
		pillar.Anchored = true
		pillar.Material = Enum.Material.Marble
		pillar.BrickColor = BrickColor.new("Light blue")
		pillar.Parent = ws
	end
	
	-- Cristal principal (Model)
	local crystal = Instance.new("Model")
	crystal.Name = "Crystal"
	crystal.Parent = ws
	
	-- Corps du cristal (plus détaillé)
	local core = Instance.new("Part")
	core.Name = "Core"
	core.Size = Vector3.new(5, 14, 5)
	core.Position = Vector3.new(0, 9, 0)
	core.Anchored = true
	core.Material = Enum.Material.Neon
	core.BrickColor = BrickColor.new("Cyan")
	core.Transparency = 0.15
	core.Parent = crystal
	
	-- Pointes cristallines (8 au lieu de 6)
	for i = 1, 8 do
		local angle = (i / 8) * math.pi * 2
		local spike = Instance.new("Part")
		spike.Name = "Spike" .. i
		spike.Size = Vector3.new(1.2, 10, 1.2)
		spike.CFrame = CFrame.new(
			math.cos(angle) * 4,
			7 + math.sin(i) * 2,
			math.sin(angle) * 4
		) * CFrame.Angles(math.rad(20), angle, math.rad(10))
		spike.Anchored = true
		spike.Material = Enum.Material.Glass
		spike.BrickColor = BrickColor.new("Light blue")
		spike.Transparency = 0.25
		spike.Parent = crystal
	end
	
	-- Mini cristaux au sol autour
	for i = 1, 6 do
		local angle = (i / 6) * math.pi * 2
		local mini = Instance.new("Part")
		mini.Name = "MiniCrystal" .. i
		mini.Size = Vector3.new(0.8, 3, 0.8)
		mini.CFrame = CFrame.new(
			math.cos(angle) * 6,
			1.5,
			math.sin(angle) * 6
		) * CFrame.Angles(math.rad(math.random(-15, 15)), 0, math.rad(math.random(-15, 15)))
		mini.Anchored = true
		mini.Material = Enum.Material.Neon
		mini.BrickColor = BrickColor.new("Teal")
		mini.Transparency = 0.3
		mini.Parent = crystal
	end
	
	-- Lumière centrale puissante
	local light = Instance.new("PointLight")
	light.Brightness = 4
	light.Range = 60
	light.Color = Color3.fromRGB(100, 200, 255)
	light.Parent = core
	
	-- Particules magiques
	local particles = Instance.new("ParticleEmitter")
	particles.Color = ColorSequence.new(Color3.fromRGB(100, 200, 255), Color3.fromRGB(200, 220, 255))
	particles.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.5, 0.8),
		NumberSequenceKeypoint.new(1, 0)
	})
	particles.Lifetime = NumberRange.new(2, 5)
	particles.Rate = 15
	particles.Speed = NumberRange.new(1, 3)
	particles.SpreadAngle = Vector2.new(360, 360)
	particles.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(1, 1)
	})
	particles.LightEmission = 1
	particles.Parent = core
	
	-- Rotation du cristal
	local rotate = Instance.new("BodyAngularVelocity")
	rotate.AngularVelocity = Vector3.new(0, 0.3, 0)
	rotate.MaxTorque = Vector3.new(0, math.huge, 0)
	rotate.Parent = core
	
	crystal.PrimaryPart = core
	crystal:SetAttribute("CrystalHP", 500)
	crystal:SetAttribute("MaxHP", 500)
	
	print("[WorldBuilder] ✨ Crystal created with particles & mini crystals")
	return crystal
end

-- ============================================================
-- VILLE PRINCIPALE - 400x400 avec quartiers
-- ============================================================
function WorldBuilder.CreateTown()
	local ws = game.Workspace
	
	local oldTown = ws:FindFirstChild("Town")
	if oldTown then oldTown:Destroy() end
	
	local town = Instance.new("Folder")
	town.Name = "Town"
	town.Parent = ws
	
	-- ========================
	-- SOL PRINCIPAL (400x400)
	-- ========================
	local ground = Instance.new("Part")
	ground.Name = "Ground"
	ground.Size = Vector3.new(400, 1, 400)
	ground.Position = Vector3.new(0, -0.5, 0)
	ground.Anchored = true
	ground.BrickColor = BrickColor.new("Dark green")
	ground.Material = Enum.Material.Grass
	ground.Parent = town
	
	-- ========================
	-- PLACE CENTRALE PAVÉE (rayon ~40)
	-- ========================
	-- Sol pavé central
	local plaza = Instance.new("Part")
	plaza.Name = "CentralPlaza"
	plaza.Shape = Enum.PartType.Cylinder
	plaza.Size = Vector3.new(0.2, 80, 80)
	plaza.CFrame = CFrame.new(0, 0.1, 0) * CFrame.Angles(0, 0, math.rad(90))
	plaza.Anchored = true
	plaza.CanCollide = false
	plaza.Material = Enum.Material.Cobblestone
	plaza.BrickColor = BrickColor.new("Sand red")
	plaza.Parent = town
	
	-- Anneau décoratif
	for i = 1, 20 do
		local angle = (i / 20) * math.pi * 2
		local tile = Instance.new("Part")
		tile.Name = "PlazaRing" .. i
		tile.Size = Vector3.new(5, 0.08, 5)
		tile.Position = Vector3.new(math.cos(angle) * 38, 0.04, math.sin(angle) * 38)
		tile.Anchored = true
		tile.CanCollide = false
		tile.Material = Enum.Material.Marble
		tile.BrickColor = BrickColor.new("Institutional white")
		tile.Parent = town
	end
	
	-- ========================
	-- FONTAINE CENTRALE (devant le cristal)
	-- ========================
	local fountainPos = Vector3.new(0, 0, -25)
	
	-- Bassin
	local basin = Instance.new("Part")
	basin.Name = "FountainBasin"
	basin.Shape = Enum.PartType.Cylinder
	basin.Size = Vector3.new(1, 14, 14)
	basin.CFrame = CFrame.new(fountainPos + Vector3.new(0, 0.5, 0)) * CFrame.Angles(0, 0, math.rad(90))
	basin.Anchored = true
	basin.Material = Enum.Material.Marble
	basin.BrickColor = BrickColor.new("Institutional white")
	basin.Parent = town
	
	-- Eau
	local water = Instance.new("Part")
	water.Name = "FountainWater"
	water.Shape = Enum.PartType.Cylinder
	water.Size = Vector3.new(0.3, 12, 12)
	water.CFrame = CFrame.new(fountainPos + Vector3.new(0, 0.8, 0)) * CFrame.Angles(0, 0, math.rad(90))
	water.Anchored = true
	water.Material = Enum.Material.Glass
	water.BrickColor = BrickColor.new("Bright blue")
	water.Transparency = 0.3
	water.Parent = town
	
	-- Colonne centrale de la fontaine
	local fCol = Instance.new("Part")
	fCol.Name = "FountainColumn"
	fCol.Size = Vector3.new(2, 6, 2)
	fCol.Position = fountainPos + Vector3.new(0, 3.5, 0)
	fCol.Anchored = true
	fCol.Material = Enum.Material.Marble
	fCol.BrickColor = BrickColor.new("Institutional white")
	fCol.Parent = town
	
	-- Jets d'eau (particules)
	local waterJet = Instance.new("ParticleEmitter")
	waterJet.Color = ColorSequence.new(Color3.fromRGB(150, 200, 255))
	waterJet.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.5, 0.8),
		NumberSequenceKeypoint.new(1, 0.1)
	})
	waterJet.Lifetime = NumberRange.new(1, 2)
	waterJet.Rate = 30
	waterJet.Speed = NumberRange.new(5, 8)
	waterJet.SpreadAngle = Vector2.new(15, 15)
	waterJet.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(1, 0.8)
	})
	waterJet.Parent = fCol
	
	-- ========================
	-- MURAILLES DE LA VILLE (rayon ~90)
	-- ========================
	local wallRadius = 90
	local wallHeight = 14
	local numSegments = 16
	
	for i = 1, numSegments do
		local angle1 = ((i - 1) / numSegments) * math.pi * 2
		local angle2 = (i / numSegments) * math.pi * 2
		
		local p1 = Vector3.new(math.cos(angle1) * wallRadius, 0, math.sin(angle1) * wallRadius)
		local p2 = Vector3.new(math.cos(angle2) * wallRadius, 0, math.sin(angle2) * wallRadius)
		
		-- Porte aux 4 directions cardinales
		local isGate = (i == 1 or i == 5 or i == 9 or i == 13)
		
		local mid = (p1 + p2) / 2
		local dx = p2.X - p1.X
		local dz = p2.Z - p1.Z
		local segLength = math.sqrt(dx*dx + dz*dz)
		local segAngle = math.atan2(dx, dz)
		
		if isGate then
			-- Demi-murs avec passage
			local halfLen = (segLength - 10) / 2
			for side = -1, 1, 2 do
				local wallSeg = Instance.new("Part")
				wallSeg.Name = "CityWall_" .. i .. "_" .. side
				wallSeg.Size = Vector3.new(3, wallHeight, halfLen)
				wallSeg.CFrame = CFrame.new(mid + Vector3.new(0, wallHeight/2, 0))
					* CFrame.Angles(0, segAngle, 0)
					* CFrame.new(0, 0, side * (halfLen/2 + 5))
				wallSeg.Anchored = true
				wallSeg.Material = Enum.Material.Brick
				wallSeg.BrickColor = BrickColor.new("Medium stone grey")
				wallSeg.Parent = town
			end
			
			-- Arche au dessus de la porte
			local arch = Instance.new("Part")
			arch.Name = "GateArch_" .. i
			arch.Size = Vector3.new(3, 4, 12)
			arch.CFrame = CFrame.new(mid + Vector3.new(0, wallHeight - 2, 0))
				* CFrame.Angles(0, segAngle, 0)
			arch.Anchored = true
			arch.Material = Enum.Material.Brick
			arch.BrickColor = BrickColor.new("Dark stone grey")
			arch.Parent = town
		else
			local wallSeg = Instance.new("Part")
			wallSeg.Name = "CityWall_" .. i
			wallSeg.Size = Vector3.new(3, wallHeight, segLength)
			wallSeg.CFrame = CFrame.new(mid + Vector3.new(0, wallHeight/2, 0))
				* CFrame.Angles(0, segAngle, 0)
			wallSeg.Anchored = true
			wallSeg.Material = Enum.Material.Brick
			wallSeg.BrickColor = BrickColor.new("Medium stone grey")
			wallSeg.Parent = town
		end
	end
	
	-- ========================
	-- 4 TOURS DE GARDE (aux coins)
	-- ========================
	local towerPositions = {
		{pos = Vector3.new(wallRadius * 0.7, 0, wallRadius * 0.7), name = "Tower_NE"},
		{pos = Vector3.new(-wallRadius * 0.7, 0, wallRadius * 0.7), name = "Tower_NW"},
		{pos = Vector3.new(wallRadius * 0.7, 0, -wallRadius * 0.7), name = "Tower_SE"},
		{pos = Vector3.new(-wallRadius * 0.7, 0, -wallRadius * 0.7), name = "Tower_SW"},
	}
	for _, td in ipairs(towerPositions) do
		createWatchTower(town, td.pos, td.name)
	end
	
	-- ========================
	-- ROUTES PAVÉES (4 axes + circulaire)
	-- ========================
	-- Routes cardinales (du cristal aux portes)
	local roadDirections = {
		{dir = Vector3.new(0, 0, -1), name = "RoadNorth"},
		{dir = Vector3.new(0, 0, 1), name = "RoadSouth"},
		{dir = Vector3.new(1, 0, 0), name = "RoadEast"},
		{dir = Vector3.new(-1, 0, 0), name = "RoadWest"},
	}
	
	for _, rd in ipairs(roadDirections) do
		for i = 1, 10 do
			local roadPiece = Instance.new("Part")
			roadPiece.Name = rd.name .. "_" .. i
			local dist = 40 + i * 5
			if rd.dir.X ~= 0 then
				roadPiece.Size = Vector3.new(6, 0.08, 8)
			else
				roadPiece.Size = Vector3.new(8, 0.08, 6)
			end
			roadPiece.Position = rd.dir * dist + Vector3.new(0, 0.04, 0)
			roadPiece.Anchored = true
			roadPiece.CanCollide = false
			roadPiece.Material = Enum.Material.Cobblestone
			roadPiece.BrickColor = BrickColor.new("Nougat")
			roadPiece.Parent = town
		end
	end
	
	-- Route circulaire intérieure (rayon ~55)
	for i = 1, 32 do
		local angle = (i / 32) * math.pi * 2
		local ringRoad = Instance.new("Part")
		ringRoad.Name = "RingRoad" .. i
		ringRoad.Size = Vector3.new(6, 0.08, 6)
		ringRoad.Position = Vector3.new(math.cos(angle) * 55, 0.04, math.sin(angle) * 55)
		ringRoad.Anchored = true
		ringRoad.CanCollide = false
		ringRoad.Material = Enum.Material.Cobblestone
		ringRoad.BrickColor = BrickColor.new("Nougat")
		ringRoad.Parent = town
	end
	
	-- ========================
	-- BÂTIMENTS DE LA VILLE (vrais bâtiments!)
	-- ========================
	
	-- AUBERGE (Nord-Ouest dans les murs)
	createBuilding(town, "Auberge", Vector3.new(-55, 0, -50),
		Vector3.new(16, 10, 12), "Reddish brown", "Dark red", "peaked",
		{sign = "🏨 Auberge du Cristal", light = true, chimney = true})
	
	-- FORGE / ARMURERIE (Nord-Est)
	createBuilding(town, "Forge", Vector3.new(55, 0, -50),
		Vector3.new(14, 8, 14), "Dark stone grey", "Really black", "flat",
		{sign = "⚒️ Forge", light = true, chimney = true,
		 lightColor = Color3.fromRGB(255, 100, 50)})
	
	-- MARCHÉ (Est)
	createBuilding(town, "Marche", Vector3.new(60, 0, 10),
		Vector3.new(20, 6, 16), "Cashmere", "Nougat", "flat",
		{sign = "🛒 Marché", light = true})
	
	-- BIBLIOTHÈQUE / MAGIE (Ouest)
	createBuilding(town, "Bibliotheque", Vector3.new(-60, 0, 10),
		Vector3.new(14, 12, 14), "Pastel Blue", "Navy blue", "tower",
		{sign = "📚 Bibliothèque Arcane", light = true,
		 lightColor = Color3.fromRGB(100, 100, 255)})
	
	-- BANQUE (Sud-Ouest)
	createBuilding(town, "Banque", Vector3.new(-50, 0, 55),
		Vector3.new(16, 10, 12), "Gold", "Dark stone grey", "flat",
		{sign = "🏦 Banque Royale", light = true,
		 lightColor = Color3.fromRGB(255, 220, 100)})
	
	-- CASERNE (Sud-Est)
	createBuilding(town, "Caserne", Vector3.new(50, 0, 55),
		Vector3.new(18, 10, 14), "Sand red", "Dark red", "peaked",
		{sign = "⚔️ Caserne", light = true})
	
	-- TEMPLE DE SOIN (Nord, près de la fontaine)
	createBuilding(town, "Temple", Vector3.new(0, 0, -55),
		Vector3.new(16, 14, 12), "Institutional white", "Light blue", "tower",
		{sign = "🏥 Temple de Soin", light = true,
		 lightColor = Color3.fromRGB(100, 255, 150)})
	
	-- CENTRE DE STOCKAGE (Sud)
	createBuilding(town, "Stockage", Vector3.new(0, 0, 60),
		Vector3.new(20, 8, 16), "Brown", "Dark orange", "flat",
		{sign = "📦 Centre de Stockage", light = true})
	
	-- ========================
	-- ÉCLAIRAGE DE LA VILLE (lampes le long des routes)
	-- ========================
	for i = 1, 12 do
		local angle = (i / 12) * math.pi * 2
		createLamp(town, Vector3.new(math.cos(angle) * 30, 0, math.sin(angle) * 30), "medieval")
	end
	-- Lampes sur la route circulaire
	for i = 1, 8 do
		local angle = (i / 8) * math.pi * 2
		createLamp(town, Vector3.new(math.cos(angle) * 55, 0, math.sin(angle) * 55), "medieval")
	end
	
	-- ========================
	-- ARBRES ET JARDINS
	-- ========================
	-- Jardins entre les bâtiments
	local gardenPositions = {
		Vector3.new(-35, 0, -30), Vector3.new(35, 0, -30),
		Vector3.new(-35, 0, 35), Vector3.new(35, 0, 35),
		Vector3.new(-25, 0, 0), Vector3.new(25, 0, 0),
	}
	for _, gp in ipairs(gardenPositions) do
		-- Petite haie
		local hedge = Instance.new("Part")
		hedge.Name = "Hedge"
		hedge.Size = Vector3.new(6, 2, 6)
		hedge.Position = gp + Vector3.new(0, 1, 0)
		hedge.Anchored = true
		hedge.Material = Enum.Material.Grass
		hedge.BrickColor = BrickColor.new("Earth green")
		hedge.Parent = town
		
		-- Fleurs (couleur aléatoire)
		local flowerColors = {"Bright red", "Bright yellow", "Bright violet", "Hot pink", "Bright orange"}
		local flower = Instance.new("Part")
		flower.Name = "Flowers"
		flower.Size = Vector3.new(4, 0.5, 4)
		flower.Position = gp + Vector3.new(0, 2.2, 0)
		flower.Anchored = true
		flower.CanCollide = false
		flower.Material = Enum.Material.Grass
		flower.BrickColor = BrickColor.new(flowerColors[math.random(#flowerColors)])
		flower.Parent = town
	end
	
	-- Arbres autour de la muraille intérieure
	for i = 1, 16 do
		local angle = (i / 16) * math.pi * 2 + 0.2
		local treePos = Vector3.new(math.cos(angle) * 75, 0, math.sin(angle) * 75)
		createTree(town, treePos, "normal")
	end
	
	-- ========================
	-- CHEMINS EXTÉRIEURS (au-delà des murailles)
	-- ========================
	
	-- CHEMIN NORD: Forêt dense
	for i = 1, 20 do
		local path = Instance.new("Part")
		path.Size = Vector3.new(10, 0.05, 8)
		path.Position = Vector3.new(0, 0.03, -90 - i * 8)
		path.Anchored = true
		path.CanCollide = false
		path.BrickColor = BrickColor.new("Nougat")
		path.Material = Enum.Material.Sand
		path.Parent = town
		
		-- Forêt dense des deux côtés
		if i % 2 == 0 then
			for side = -1, 1, 2 do
				local treeX = side * math.random(12, 25)
				createTree(town, Vector3.new(treeX, 0, -90 - i * 8), "pine")
				-- Deuxième rangée
				createTree(town, Vector3.new(treeX + side * math.random(5, 10), 0, -90 - i * 8 + math.random(-5, 5)), "normal")
			end
		end
	end
	
	-- CHEMIN EST: Zone montagneuse / rocheux
	for i = 1, 20 do
		local path = Instance.new("Part")
		path.Size = Vector3.new(8, 0.05, 10)
		path.Position = Vector3.new(90 + i * 8, 0.03, 0)
		path.Anchored = true
		path.CanCollide = false
		path.BrickColor = BrickColor.new("Medium stone grey")
		path.Material = Enum.Material.Slate
		path.Parent = town
		
		-- Rochers et formations rocheuses
		if i % 2 == 0 then
			for side = -1, 1, 2 do
				-- Gros rocher
				local rock = Instance.new("Part")
				rock.Size = Vector3.new(
					math.random(5, 10),
					math.random(4, 12),
					math.random(5, 10)
				)
				rock.Position = Vector3.new(90 + i * 8, rock.Size.Y/2, side * math.random(12, 20))
				rock.Anchored = true
				rock.Material = Enum.Material.Slate
				rock.BrickColor = BrickColor.new("Dark stone grey")
				rock.Parent = town
				
				-- Petit rocher
				local smallRock = Instance.new("Part")
				smallRock.Size = Vector3.new(3, 2, 3)
				smallRock.Position = rock.Position + Vector3.new(math.random(-3, 3), -rock.Size.Y/2 + 1, math.random(-3, 3))
				smallRock.Anchored = true
				smallRock.Material = Enum.Material.Slate
				smallRock.BrickColor = BrickColor.new("Medium stone grey")
				smallRock.Parent = town
			end
		end
		
		-- Élévation progressive du terrain
		if i > 10 then
			local elevation = Instance.new("Part")
			elevation.Size = Vector3.new(40, (i - 10) * 1.5, 40)
			elevation.Position = Vector3.new(90 + i * 8, (i - 10) * 0.75, 0)
			elevation.Anchored = true
			elevation.Material = Enum.Material.Rock
			elevation.BrickColor = BrickColor.new("Dark stone grey")
			elevation.Transparency = 0
			elevation.Parent = town
		end
	end
	
	-- CHEMIN SUD: Zone maritime / plage
	for i = 1, 20 do
		local path = Instance.new("Part")
		path.Size = Vector3.new(10, 0.05, 8)
		path.Position = Vector3.new(0, 0.03, 90 + i * 8)
		path.Anchored = true
		path.CanCollide = false
		path.BrickColor = BrickColor.new("Brick yellow")
		path.Material = Enum.Material.Sand
		path.Parent = town
		
		-- Transition herbe → sable → eau
		if i > 5 then
			-- Sable
			for side = -1, 1, 2 do
				local sand = Instance.new("Part")
				sand.Size = Vector3.new(20, 0.5, 10)
				sand.Position = Vector3.new(side * 15, 0.25, 90 + i * 8)
				sand.Anchored = true
				sand.Material = Enum.Material.Sand
				sand.BrickColor = BrickColor.new("Brick yellow")
				sand.Parent = town
			end
			-- Palmiers
			if i % 3 == 0 then
				createTree(town, Vector3.new(math.random(-20, 20), 0, 90 + i * 8), "palm")
			end
		end
		
		-- Eau (les derniers segments)
		if i > 12 then
			local waterPart = Instance.new("Part")
			waterPart.Size = Vector3.new(50, 1.5, 10)
			waterPart.Position = Vector3.new(0, 0.5, 90 + i * 8)
			waterPart.Anchored = true
			waterPart.Material = Enum.Material.Glass
			waterPart.BrickColor = BrickColor.new("Bright blue")
			waterPart.Transparency = 0.3
			waterPart.CanCollide = false
			waterPart.Parent = town
		end
	end
	
	-- CHEMIN OUEST: Zone sombre / forêt maudite
	for i = 1, 20 do
		local path = Instance.new("Part")
		path.Size = Vector3.new(8, 0.05, 10)
		path.Position = Vector3.new(-90 - i * 8, 0.03, 0)
		path.Anchored = true
		path.CanCollide = false
		path.BrickColor = BrickColor.new("Really black")
		path.Material = Enum.Material.Cobblestone
		path.Parent = town
		
		-- Arbres morts et brouillard
		if i % 2 == 0 then
			for side = -1, 1, 2 do
				createTree(town, Vector3.new(-90 - i * 8, 0, side * math.random(10, 20)), "dark")
			end
		end
		
		-- Brouillard progressif
		if i > 5 then
			local fog = Instance.new("Part")
			fog.Size = Vector3.new(15, 6, 15)
			fog.Position = Vector3.new(-90 - i * 8, 3, math.random(-10, 10))
			fog.Anchored = true
			fog.CanCollide = false
			fog.Transparency = 0.85
			fog.Material = Enum.Material.Neon
			fog.BrickColor = BrickColor.new("Dark indigo")
			fog.Parent = town
		end
	end
	
	-- ========================
	-- PONT sur la rivière (zone sud)
	-- ========================
	local bridgePos = Vector3.new(0, 0, 195)
	
	-- Plateforme du pont
	local bridgeDeck = Instance.new("Part")
	bridgeDeck.Name = "BridgeDeck"
	bridgeDeck.Size = Vector3.new(12, 1, 30)
	bridgeDeck.Position = bridgePos + Vector3.new(0, 2, 0)
	bridgeDeck.Anchored = true
	bridgeDeck.Material = Enum.Material.Wood
	bridgeDeck.BrickColor = BrickColor.new("Brown")
	bridgeDeck.Parent = town
	
	-- Rampes
	for side = -1, 1, 2 do
		local ramp = Instance.new("Part")
		ramp.Name = "BridgeRamp"
		ramp.Size = Vector3.new(0.5, 3, 30)
		ramp.Position = bridgePos + Vector3.new(side * 6, 3, 0)
		ramp.Anchored = true
		ramp.Material = Enum.Material.Wood
		ramp.BrickColor = BrickColor.new("Dark orange")
		ramp.Parent = town
	end
	
	-- Piliers
	for z = -1, 1, 2 do
		local pillar = Instance.new("Part")
		pillar.Name = "BridgePillar"
		pillar.Size = Vector3.new(2, 5, 2)
		pillar.Position = bridgePos + Vector3.new(0, 0, z * 10)
		pillar.Anchored = true
		pillar.Material = Enum.Material.Concrete
		pillar.BrickColor = BrickColor.new("Medium stone grey")
		pillar.Parent = town
	end
	
	print("[WorldBuilder] 🏰 Massive town created (400x400) with buildings, walls, fountain, gardens!")
	return town
end

-- ============================================================
-- PNJ GUIDE (Aldric)
-- ============================================================
function WorldBuilder.CreateNPC()
	local ws = game.Workspace
	
	local npcPos = Vector3.new(12, 1, -20) -- Près de la fontaine
	
	local npc = Instance.new("Model")
	npc.Name = "GuideNPC"
	npc.Parent = ws
	
	-- Torse
	local torso = Instance.new("Part")
	torso.Name = "Torso"
	torso.Size = Vector3.new(2, 2, 1)
	torso.Position = npcPos + Vector3.new(0, 3, 0)
	torso.Anchored = true
	torso.BrickColor = BrickColor.new("Bright blue")
	torso.Parent = npc
	
	-- Tête
	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(2, 1, 1)
	head.Position = torso.Position + Vector3.new(0, 1.5, 0)
	head.Anchored = true
	head.BrickColor = BrickColor.new("Light orange")
	head.Parent = npc
	
	-- Visage
	local face = Instance.new("Decal")
	face.Texture = "rbxasset://textures/face.png"
	face.Face = Enum.NormalId.Front
	face.Parent = head
	
	-- Chapeau de mage
	local hat = Instance.new("Part")
	hat.Name = "Hat"
	hat.Size = Vector3.new(2.5, 3, 2.5)
	hat.Position = head.Position + Vector3.new(0, 2, 0)
	hat.Anchored = true
	hat.Material = Enum.Material.Fabric
	hat.BrickColor = BrickColor.new("Navy blue")
	hat.Parent = npc
	
	-- Bord du chapeau
	local hatBrim = Instance.new("Part")
	hatBrim.Name = "HatBrim"
	hatBrim.Size = Vector3.new(4, 0.3, 4)
	hatBrim.Position = head.Position + Vector3.new(0, 1, 0)
	hatBrim.Anchored = true
	hatBrim.Material = Enum.Material.Fabric
	hatBrim.BrickColor = BrickColor.new("Navy blue")
	hatBrim.Parent = npc
	
	-- Jambes
	for i = -1, 1, 2 do
		local leg = Instance.new("Part")
		leg.Name = "Leg"
		leg.Size = Vector3.new(1, 2, 1)
		leg.Position = torso.Position + Vector3.new(i * 0.5, -2, 0)
		leg.Anchored = true
		leg.BrickColor = BrickColor.new("Dark green")
		leg.Parent = npc
	end
	
	-- Bras
	for i = -1, 1, 2 do
		local arm = Instance.new("Part")
		arm.Name = "Arm"
		arm.Size = Vector3.new(1, 2, 1)
		arm.Position = torso.Position + Vector3.new(i * 1.5, 0, 0)
		arm.Anchored = true
		arm.BrickColor = BrickColor.new("Bright blue")
		arm.Parent = npc
	end
	
	-- Bâton magique
	local staff = Instance.new("Part")
	staff.Name = "Staff"
	staff.Size = Vector3.new(0.4, 7, 0.4)
	staff.Position = torso.Position + Vector3.new(2, 0, 0)
	staff.Anchored = true
	staff.Material = Enum.Material.Wood
	staff.BrickColor = BrickColor.new("Brown")
	staff.Parent = npc
	
	local staffOrb = Instance.new("Part")
	staffOrb.Name = "StaffOrb"
	staffOrb.Shape = Enum.PartType.Ball
	staffOrb.Size = Vector3.new(1.2, 1.2, 1.2)
	staffOrb.Position = staff.Position + Vector3.new(0, 3.8, 0)
	staffOrb.Anchored = true
	staffOrb.Material = Enum.Material.Neon
	staffOrb.BrickColor = BrickColor.new("Cyan")
	staffOrb.Parent = npc
	
	local staffLight = Instance.new("PointLight")
	staffLight.Brightness = 1.5
	staffLight.Range = 15
	staffLight.Color = Color3.fromRGB(100, 200, 255)
	staffLight.Parent = staffOrb
	
	npc.PrimaryPart = torso
	
	-- Billboard
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.fromOffset(220, 60)
	billboard.StudsOffset = Vector3.new(0, 5, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = head
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 1, 0)
	nameLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 60)
	nameLabel.BackgroundTransparency = 0.3
	nameLabel.Text = "🧙 Guide Aldric"
	nameLabel.TextScaled = true
	nameLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Parent = billboard
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = nameLabel
	
	-- Interaction
	local detector = Instance.new("ClickDetector")
	detector.MaxActivationDistance = 25
	detector.CursorIcon = "rbxasset://textures/GunCursor.png"
	detector.Parent = torso
	
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Parler"
	prompt.ObjectText = "Guide Aldric"
	prompt.KeyboardKeyCode = Enum.KeyCode.F
	prompt.MaxActivationDistance = 20
	prompt.HoldDuration = 0
	prompt.RequiresLineOfSight = false
	prompt.Parent = torso
	
	npc:SetAttribute("NPCType", "Guide")
	
	print("[WorldBuilder] 🧙 NPC Aldric created near fountain")
	return npc, detector, prompt
end

-- ============================================================
-- SPAWN POINTS (4 zones thématiques, plus loin)
-- ============================================================
function WorldBuilder.CreateSpawnPoints()
	local ws = game.Workspace
	
	local oldSpawns = ws:FindFirstChild("WildSpawnPoints")
	if oldSpawns then oldSpawns:Destroy() end
	
	local folder = Instance.new("Folder")
	folder.Name = "WildSpawnPoints"
	folder.Parent = ws
	
	local spawnData = {
		{name = "SP_Foret", pos = Vector3.new(0, 0.5, -250), color = "Earth green"},
		{name = "SP_Montagne", pos = Vector3.new(250, 0.5, 0), color = "Medium stone grey"},
		{name = "SP_Mer", pos = Vector3.new(0, 0.5, 250), color = "Bright blue"},
		{name = "SP_Sombre", pos = Vector3.new(-250, 0.5, 0), color = "Really black"},
	}
	
	for _, data in ipairs(spawnData) do
		local sp = Instance.new("Part")
		sp.Name = data.name
		sp.Size = Vector3.new(12, 1, 12)
		sp.Position = data.pos
		sp.Anchored = true
		sp.CanCollide = false
		sp.Transparency = 0.6
		sp.BrickColor = BrickColor.new(data.color)
		sp.Material = Enum.Material.Neon
		sp.Parent = folder
		
		-- Beacon lumineux
		local beacon = Instance.new("Part")
		beacon.Size = Vector3.new(1, 30, 1)
		beacon.Position = data.pos + Vector3.new(0, 15, 0)
		beacon.Anchored = true
		beacon.CanCollide = false
		beacon.Transparency = 0.7
		beacon.BrickColor = BrickColor.new(data.color)
		beacon.Material = Enum.Material.Neon
		beacon.Parent = folder
		
		-- Particules au sol
		local glow = Instance.new("ParticleEmitter")
		glow.Color = ColorSequence.new(sp.BrickColor.Color)
		glow.Size = NumberSequence.new(0.5, 0)
		glow.Lifetime = NumberRange.new(1, 3)
		glow.Rate = 5
		glow.Speed = NumberRange.new(2, 5)
		glow.SpreadAngle = Vector2.new(30, 30)
		glow.Parent = sp
	end
	
	print("[WorldBuilder] 🌍 4 spawn points created (farther: 250 studs)")
	return folder
end

-- ============================================================
-- PLAYER SPAWN
-- ============================================================
function WorldBuilder.CreatePlayerSpawn()
	local ws = game.Workspace
	
	-- Supprimer TOUS les SpawnLocation
	for _, obj in pairs(ws:GetDescendants()) do
		if obj:IsA("SpawnLocation") then
			obj:Destroy()
		end
	end
	
	-- Zone de spawn joueur (près de la fontaine, dans la place centrale)
	local spawn = Instance.new("Part")
	spawn.Name = "PlayerSpawn"
	spawn.Size = Vector3.new(15, 1, 15)
	spawn.Position = Vector3.new(0, 0.5, -40)
	spawn.Anchored = true
	spawn.CanCollide = false
	spawn.Transparency = 0.8
	spawn.BrickColor = BrickColor.new("Bright green")
	spawn.Material = Enum.Material.Grass
	spawn.Parent = ws
	
	print("[WorldBuilder] 🟢 Player spawn at (0, 0, -40)")
	return spawn
end

-- ============================================================
-- HALL DES CLASSES (temple amélioré)
-- ============================================================
function WorldBuilder.CreateClassHall()
	local ws = game.Workspace
	
	local hallPos = Vector3.new(80, 0, -60)
	
	local hall = Instance.new("Model")
	hall.Name = "ClassHall"
	
	-- Sol du hall (marbre blanc)
	local floor = Instance.new("Part")
	floor.Name = "Floor"
	floor.Size = Vector3.new(55, 1, 45)
	floor.Position = hallPos + Vector3.new(0, 0.5, 0)
	floor.Anchored = true
	floor.BrickColor = BrickColor.new("Institutional white")
	floor.Material = Enum.Material.Marble
	floor.Parent = hall
	
	-- Murs massifs
	local wallData = {
		{size = Vector3.new(55, 18, 2), offset = Vector3.new(0, 9.5, -21.5)},
		{size = Vector3.new(2, 18, 45), offset = Vector3.new(-26.5, 9.5, 0)},
		{size = Vector3.new(2, 18, 45), offset = Vector3.new(26.5, 9.5, 0)},
	}
	
	for i, wd in ipairs(wallData) do
		local wall = Instance.new("Part")
		wall.Name = "Wall_" .. i
		wall.Size = wd.size
		wall.Position = hallPos + wd.offset
		wall.Anchored = true
		wall.BrickColor = BrickColor.new("Sand red")
		wall.Material = Enum.Material.Brick
		wall.Parent = hall
	end
	
	-- Grand toit
	local roof = Instance.new("Part")
	roof.Name = "Roof"
	roof.Size = Vector3.new(60, 2, 50)
	roof.Position = hallPos + Vector3.new(0, 19, 0)
	roof.Anchored = true
	roof.BrickColor = BrickColor.new("Dark red")
	roof.Material = Enum.Material.Slate
	roof.Parent = hall
	
	-- 6 colonnes (style temple grec)
	local columnPositions = {-20, -12, -4, 4, 12, 20}
	for _, cx in ipairs(columnPositions) do
		local col = Instance.new("Part")
		col.Name = "Column"
		col.Size = Vector3.new(3, 17, 3)
		col.Position = hallPos + Vector3.new(cx, 9, 21)
		col.Anchored = true
		col.BrickColor = BrickColor.new("Institutional white")
		col.Material = Enum.Material.Marble
		col.Parent = hall
	end
	
	-- Enseigne
	local mainSign = Instance.new("Part")
	mainSign.Name = "MainSign"
	mainSign.Size = Vector3.new(40, 6, 1)
	mainSign.Position = hallPos + Vector3.new(0, 22, 21)
	mainSign.Anchored = true
	mainSign.Material = Enum.Material.SmoothPlastic
	mainSign.BrickColor = BrickColor.new("Really black")
	mainSign.Parent = hall
	
	local signGui = Instance.new("SurfaceGui")
	signGui.Face = Enum.NormalId.Front
	signGui.Parent = mainSign
	local signLabel = Instance.new("TextLabel")
	signLabel.Size = UDim2.new(1, 0, 1, 0)
	signLabel.BackgroundTransparency = 1
	signLabel.Text = "⚔️ HALL DES CLASSES ⚔️\n(Niveau 10 requis)"
	signLabel.TextScaled = true
	signLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
	signLabel.Font = Enum.Font.GothamBold
	signLabel.Parent = signGui
	
	-- Éclairage intérieur
	local hallLight = Instance.new("PointLight")
	hallLight.Brightness = 3
	hallLight.Range = 40
	hallLight.Color = Color3.fromRGB(255, 200, 150)
	hallLight.Parent = floor
	
	-- 4 podiums pour les 4 classes (plus détaillés)
	local classes = {
		{name = "Guerrier", color = Color3.fromRGB(200, 50, 50), emoji = "⚔️", offset = Vector3.new(-16, 0, -5),
		 desc = "Force brute\nBonus: ATK +5, DEF +3"},
		{name = "Archer", color = Color3.fromRGB(50, 200, 50), emoji = "🏹", offset = Vector3.new(-5, 0, -5),
		 desc = "Précision mortelle\nBonus: Portée, Vitesse"},
		{name = "Mage", color = Color3.fromRGB(100, 50, 200), emoji = "🔮", offset = Vector3.new(5, 0, -5),
		 desc = "Puissance arcane\nBonus: Magie, Capture"},
		{name = "Acolyte", color = Color3.fromRGB(255, 220, 50), emoji = "✨", offset = Vector3.new(16, 0, -5),
		 desc = "Lumière sacrée\nBonus: Soin, Support"},
	}
	
	for _, cls in ipairs(classes) do
		-- Podium (escalier)
		local podiumBase = Instance.new("Part")
		podiumBase.Name = "PodiumBase_" .. cls.name
		podiumBase.Size = Vector3.new(10, 1, 10)
		podiumBase.Position = hallPos + cls.offset + Vector3.new(0, 1, 0)
		podiumBase.Anchored = true
		podiumBase.Color = cls.color
		podiumBase.Material = Enum.Material.Marble
		podiumBase.Transparency = 0.1
		podiumBase.Parent = hall
		
		local podium = Instance.new("Part")
		podium.Name = "Podium_" .. cls.name
		podium.Size = Vector3.new(8, 2, 8)
		podium.Position = hallPos + cls.offset + Vector3.new(0, 2.5, 0)
		podium.Anchored = true
		podium.Color = cls.color
		podium.Material = Enum.Material.Marble
		podium.Parent = hall
		
		-- Statue brillante
		local statue = Instance.new("Part")
		statue.Name = "Statue_" .. cls.name
		statue.Size = Vector3.new(2, 6, 2)
		statue.Position = hallPos + cls.offset + Vector3.new(0, 6.5, 0)
		statue.Anchored = true
		statue.Color = cls.color
		statue.Material = Enum.Material.Neon
		statue.Transparency = 0.2
		statue.Parent = hall
		
		-- Aura autour de la statue
		local aura = Instance.new("ParticleEmitter")
		aura.Color = ColorSequence.new(cls.color)
		aura.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(1, 0)
		})
		aura.Lifetime = NumberRange.new(1, 2)
		aura.Rate = 8
		aura.Speed = NumberRange.new(1, 2)
		aura.SpreadAngle = Vector2.new(360, 360)
		aura.LightEmission = 0.8
		aura.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(1, 1)
		})
		aura.Parent = statue
		
		-- Panneau classe
		local classBillboard = Instance.new("BillboardGui")
		classBillboard.Size = UDim2.new(0, 150, 0, 80)
		classBillboard.StudsOffset = Vector3.new(0, 6, 0)
		classBillboard.AlwaysOnTop = false
		classBillboard.Parent = statue
		
		local classLabel = Instance.new("TextLabel")
		classLabel.Size = UDim2.new(1, 0, 0.5, 0)
		classLabel.BackgroundColor3 = Color3.new(0, 0, 0)
		classLabel.BackgroundTransparency = 0.3
		classLabel.Text = cls.emoji .. " " .. cls.name
		classLabel.TextScaled = true
		classLabel.TextColor3 = Color3.new(1, 1, 1)
		classLabel.Font = Enum.Font.GothamBold
		classLabel.Parent = classBillboard
		
		local descLabel = Instance.new("TextLabel")
		descLabel.Size = UDim2.new(1, 0, 0.5, 0)
		descLabel.Position = UDim2.new(0, 0, 0.5, 0)
		descLabel.BackgroundTransparency = 1
		descLabel.Text = cls.desc
		descLabel.TextScaled = true
		descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		descLabel.Font = Enum.Font.Gotham
		descLabel.Parent = classBillboard
		
		-- ProximityPrompt
		local classPrompt = Instance.new("ProximityPrompt")
		classPrompt.ActionText = "Choisir " .. cls.name
		classPrompt.ObjectText = cls.name
		classPrompt.KeyboardKeyCode = Enum.KeyCode.F
		classPrompt.MaxActivationDistance = 10
		classPrompt.HoldDuration = 1.5
		classPrompt.RequiresLineOfSight = false
		classPrompt.Parent = podium
		
		podium:SetAttribute("ClassName", cls.name)
	end
	
	hall.Parent = ws
	print("[WorldBuilder] ⚔️ Class Hall (temple) created at", hallPos)
	return hall
end

-- ============================================================
-- ÉCLAIRAGE AVANCÉ
-- ============================================================
function WorldBuilder.SetupLighting()
	local Lighting = game:GetService("Lighting")
	
	-- Atmosphere
	local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
	if not atmo then
		atmo = Instance.new("Atmosphere")
		atmo.Parent = Lighting
	end
	atmo.Density = 0.3
	atmo.Offset = 0.1
	atmo.Color = Color3.fromRGB(180, 200, 240)
	atmo.Decay = Color3.fromRGB(130, 150, 190)
	atmo.Glare = 0
	atmo.Haze = 2
	
	-- Bloom
	local bloom = Lighting:FindFirstChild("Bloom")
	if not bloom then
		bloom = Instance.new("BloomEffect")
		bloom.Name = "Bloom"
		bloom.Parent = Lighting
	end
	bloom.Intensity = 0.12
	bloom.Size = 24
	bloom.Threshold = 1.1
	
	-- ColorCorrection
	local cc = Lighting:FindFirstChild("ColorCorrection")
	if not cc then
		cc = Instance.new("ColorCorrectionEffect")
		cc.Name = "ColorCorrection"
		cc.Parent = Lighting
	end
	cc.Brightness = 0.03
	cc.Contrast = 0.1
	cc.Saturation = 0.2
	cc.TintColor = Color3.fromRGB(255, 248, 240)
	
	-- SunRays
	local rays = Lighting:FindFirstChild("SunRays")
	if not rays then
		rays = Instance.new("SunRaysEffect")
		rays.Name = "SunRays"
		rays.Parent = Lighting
	end
	rays.Intensity = 0.05
	rays.Spread = 0.7
	
	-- Lighting properties
	Lighting.Ambient = Color3.fromRGB(70, 75, 90)
	Lighting.OutdoorAmbient = Color3.fromRGB(100, 110, 130)
	Lighting.Brightness = 2.5
	Lighting.ClockTime = 14
	Lighting.GeographicLatitude = 35
	Lighting.EnvironmentDiffuseScale = 0.65
	Lighting.EnvironmentSpecularScale = 0.45
	Lighting.GlobalShadows = true
	Lighting.ShadowSoftness = 0.15
	Lighting.ExposureCompensation = 0.1
	
	-- Sky
	local sky = Lighting:FindFirstChildOfClass("Sky")
	if not sky then
		sky = Instance.new("Sky")
		sky.Parent = Lighting
	end
	sky.CelestialBodiesShown = true
	sky.StarCount = 3000
	sky.MoonAngularSize = 11
	sky.SunAngularSize = 21
	sky.SkyboxBk = "rbxassetid://6444884337"
	sky.SkyboxDn = "rbxassetid://6444884785"
	sky.SkyboxFt = "rbxassetid://6444884337"
	sky.SkyboxLf = "rbxassetid://6444884337"
	sky.SkyboxRt = "rbxassetid://6444884337"
	sky.SkyboxUp = "rbxassetid://6444885122"
	
	-- DepthOfField
	local dof = Lighting:FindFirstChild("DepthOfField")
	if not dof then
		dof = Instance.new("DepthOfFieldEffect")
		dof.Name = "DepthOfField"
		dof.Parent = Lighting
	end
	dof.FarIntensity = 0.08
	dof.FocusDistance = 60
	dof.InFocusRadius = 40
	dof.NearIntensity = 0
	
	print("[WorldBuilder] 🌅 Lighting setup complete!")
end

return WorldBuilder
