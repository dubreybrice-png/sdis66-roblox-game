--[[
	WorldBuilder V35 - MEGA UPDATE 2
	==================================
	- 600x600 map
	- Straight walls at radius 140, gates aligned to N/S/E/W axes
	- NO decorative buildings overlapping BuildingSystem positions
	- Fixed lighting (reduced brightness)
	- Signs with MaxDistance (not always visible)
	- Zones with proper pathing (no stairs blocking spawns)
	- Ambient details: well, benches, market stalls, arena
	- Monster-friendly gate alignment for wave pathing
]]

local WorldBuilder = {}

local V3 = Vector3.new
local CF = CFrame.new
local CA = CFrame.Angles
local RAD = math.rad
local PI = math.pi

-- === HELPER: Quick anchored Part ===
local function fp(parent, name, cframe, size, color, mat)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cframe
	p.Anchored = true
	p.Material = mat or Enum.Material.Wood
	p.BrickColor = BrickColor.new(color or "Brown")
	p.Parent = parent
	return p
end

-- === CREATE TREE ===
local function createTree(parent, pos, treeType)
	local tree = Instance.new("Model")
	tree.Name = "Tree_" .. (treeType or "normal")
	local trunkH = treeType == "palm" and 10 or (treeType == "pine" and 12 or 8)
	local trunkW = treeType == "palm" and 0.8 or 1.2
	local trunk = Instance.new("Part")
	trunk.Name = "Trunk"
	trunk.Size = V3(trunkW, trunkH, trunkW)
	trunk.Position = pos + V3(0, trunkH / 2, 0)
	trunk.Anchored = true
	trunk.Material = Enum.Material.Wood
	trunk.BrickColor = BrickColor.new(treeType == "dark" and "Really black" or "Brown")
	trunk.Parent = tree
	if treeType == "pine" then
		for i = 1, 4 do
			local s = (5 - i) * 2.5
			local layer = fp(tree, "Foliage" .. i, CF(pos + V3(0, trunkH - 1 + i * 2.5, 0)), V3(s, 2, s), "Dark green", Enum.Material.Grass)
		end
	elseif treeType == "palm" then
		for i = 1, 5 do
			local leaf = fp(tree, "Leaf" .. i, CF(pos + V3(0, trunkH + 0.5, 0)) * CA(0, RAD(i * 72), 0) * CA(RAD(35), 0, 0) * CF(0, 0, -3), V3(1, 0.3, 6), "Bright green", Enum.Material.Grass)
		end
	elseif treeType == "dark" then
		for i = 1, 3 do
			fp(tree, "Branch" .. i, CF(pos + V3(0, trunkH * 0.5 + i * 1.5, 0)) * CA(0, RAD(i * 120), 0) * CA(RAD(25), 0, 0) * CF(0, 0, -2), V3(0.4, 0.4, 4), "Really black")
		end
	else
		local canopy = Instance.new("Part")
		canopy.Name = "Canopy"
		canopy.Shape = Enum.PartType.Ball
		canopy.Size = V3(8, 6, 8)
		canopy.Position = pos + V3(0, trunkH + 2, 0)
		canopy.Anchored = true
		canopy.Material = Enum.Material.Grass
		canopy.BrickColor = BrickColor.new("Earth green")
		canopy.Parent = tree
	end
	tree.Parent = parent
	return tree
end

-- === CREATE LAMP ===
local function createLamp(parent, pos)
	fp(parent, "LampPole", CF(pos + V3(0, 3, 0)), V3(0.5, 6, 0.5), "Dark stone grey", Enum.Material.Metal)
	fp(parent, "LampArm", CF(pos + V3(0.8, 5.5, 0)), V3(2, 0.3, 0.3), "Dark stone grey", Enum.Material.Metal)
	local lantern = fp(parent, "Lantern", CF(pos + V3(1.5, 5, 0)), V3(1, 1.5, 1), "Bright yellow", Enum.Material.Neon)
	lantern.Transparency = 0.3
	local light = Instance.new("PointLight")
	light.Brightness = 0.5
	light.Range = 18
	light.Color = Color3.fromRGB(255, 200, 130)
	light.Parent = lantern
end

-- === CREATE WATCH TOWER ===
local function createWatchTower(parent, pos, name)
	local tower = Instance.new("Model")
	tower.Name = name or "WatchTower"
	fp(tower, "Base", CF(pos + V3(0, 8, 0)), V3(5, 16, 5), "Medium stone grey", Enum.Material.Brick)
	fp(tower, "Platform", CF(pos + V3(0, 16.5, 0)), V3(7, 1, 7), "Dark stone grey", Enum.Material.Brick)
	for side = -1, 1, 2 do
		fp(tower, "Battlement_" .. side, CF(pos + V3(side * 3, 17.5, 0)), V3(1, 2, 7), "Medium stone grey", Enum.Material.Brick)
		fp(tower, "Battlement2_" .. side, CF(pos + V3(0, 17.5, side * 3)), V3(7, 2, 1), "Medium stone grey", Enum.Material.Brick)
	end
	local tLight = Instance.new("PointLight")
	tLight.Brightness = 0.6
	tLight.Range = 25
	tLight.Color = Color3.fromRGB(255, 200, 130)
	tLight.Parent = tower:FindFirstChild("Platform")
	tower.Parent = parent
end

-- ============================================================
-- CRYSTAL
-- ============================================================
function WorldBuilder.CreateCrystal()
	local ws = game.Workspace
	local old = ws:FindFirstChild("Crystal")
	if old then old:Destroy() end

	local crystal = Instance.new("Model")
	crystal.Name = "Crystal"

	local base = fp(crystal, "Base", CF(0, 1, 0), V3(8, 2, 8), "Institutional white", Enum.Material.Marble)
	local core = Instance.new("Part")
	core.Name = "Core"
	core.Size = V3(3, 8, 3)
	core.Position = V3(0, 7, 0)
	core.Anchored = true
	core.Material = Enum.Material.Neon
	core.BrickColor = BrickColor.new("Cyan")
	core.Transparency = 0.2
	core.Parent = crystal

	for i = 1, 4 do
		local angle = (i / 4) * PI * 2
		local side = fp(crystal, "SideCrystal" .. i, CF(math.cos(angle) * 3, 5, math.sin(angle) * 3) * CA(0, 0, RAD(math.random(-15, 15))), V3(1.5, 5, 1.5), "Teal", Enum.Material.Neon)
		side.Transparency = 0.25
	end

	for i = 1, 6 do
		local angle = (i / 6) * PI * 2
		local mini = fp(crystal, "MiniCrystal" .. i, CF(math.cos(angle) * 6, 1.5, math.sin(angle) * 6) * CA(RAD(math.random(-15, 15)), 0, RAD(math.random(-15, 15))), V3(0.8, 3, 0.8), "Teal", Enum.Material.Neon)
		mini.Transparency = 0.3
	end

	local light = Instance.new("PointLight")
	light.Brightness = 1.5
	light.Range = 40
	light.Color = Color3.fromRGB(100, 200, 255)
	light.Parent = core

	local particles = Instance.new("ParticleEmitter")
	particles.Color = ColorSequence.new(Color3.fromRGB(100, 200, 255), Color3.fromRGB(200, 220, 255))
	particles.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(0.5, 0.8), NumberSequenceKeypoint.new(1, 0)})
	particles.Lifetime = NumberRange.new(2, 5)
	particles.Rate = 10
	particles.Speed = NumberRange.new(1, 3)
	particles.SpreadAngle = Vector2.new(360, 360)
	particles.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 1)})
	particles.LightEmission = 1
	particles.Parent = core

	local rotate = Instance.new("BodyAngularVelocity")
	rotate.AngularVelocity = V3(0, 0.3, 0)
	rotate.MaxTorque = V3(0, math.huge, 0)
	rotate.Parent = core

	crystal.PrimaryPart = core
	crystal:SetAttribute("CrystalHP", 500)
	crystal:SetAttribute("MaxHP", 500)
	crystal.Parent = ws

	print("[WorldBuilder V35] Crystal created")
	return crystal
end

-- ============================================================
-- TOWN - 600x600 avec murailles droites
-- ============================================================
function WorldBuilder.CreateTown()
	local ws = game.Workspace
	local old = ws:FindFirstChild("Town")
	if old then old:Destroy() end

	local town = Instance.new("Folder")
	town.Name = "Town"
	town.Parent = ws

	-- ======== SOL 600x600 ========
	fp(town, "Ground", CF(0, -0.5, 0), V3(600, 1, 600), "Dark green", Enum.Material.Grass)

	-- ======== PLACE CENTRALE PAVEE (rayon 42) ========
	local plaza = Instance.new("Part")
	plaza.Name = "CentralPlaza"
	plaza.Shape = Enum.PartType.Cylinder
	plaza.Size = V3(0.2, 84, 84)
	plaza.CFrame = CF(0, 0.1, 0) * CA(0, 0, RAD(90))
	plaza.Anchored = true
	plaza.CanCollide = false
	plaza.Material = Enum.Material.Cobblestone
	plaza.BrickColor = BrickColor.new("Sand red")
	plaza.Parent = town

	-- Anneau decoratif
	for i = 1, 20 do
		local a = (i / 20) * PI * 2
		local tile = fp(town, "PlazaRing" .. i, CF(math.cos(a) * 40, 0.05, math.sin(a) * 40), V3(5, 0.08, 5), "Institutional white", Enum.Material.Marble)
		tile.CanCollide = false
	end

	-- ======== FONTAINE CENTRALE ========
	local fPos = V3(0, 0, -25)
	local basin = Instance.new("Part")
	basin.Name = "FountainBasin"
	basin.Shape = Enum.PartType.Cylinder
	basin.Size = V3(1, 14, 14)
	basin.CFrame = CF(fPos + V3(0, 0.5, 0)) * CA(0, 0, RAD(90))
	basin.Anchored = true
	basin.Material = Enum.Material.Marble
	basin.BrickColor = BrickColor.new("Institutional white")
	basin.Parent = town

	local water = Instance.new("Part")
	water.Name = "FountainWater"
	water.Shape = Enum.PartType.Cylinder
	water.Size = V3(0.3, 12, 12)
	water.CFrame = CF(fPos + V3(0, 0.8, 0)) * CA(0, 0, RAD(90))
	water.Anchored = true
	water.Material = Enum.Material.Glass
	water.BrickColor = BrickColor.new("Bright blue")
	water.Transparency = 0.3
	water.Parent = town

	fp(town, "FountainCol", CF(fPos + V3(0, 4, 0)), V3(2, 7, 2), "Institutional white", Enum.Material.Marble)
	fp(town, "FountainStatue", CF(fPos + V3(0, 8.5, 0)), V3(1.5, 3, 1.5), "Medium stone grey", Enum.Material.Marble)

	local jet = Instance.new("ParticleEmitter")
	jet.Color = ColorSequence.new(Color3.fromRGB(150, 200, 255))
	jet.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(0.5, 0.7), NumberSequenceKeypoint.new(1, 0.1)})
	jet.Lifetime = NumberRange.new(1, 2)
	jet.Rate = 20
	jet.Speed = NumberRange.new(4, 7)
	jet.SpreadAngle = Vector2.new(12, 12)
	jet.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 0.8)})
	jet.Parent = town:FindFirstChild("FountainCol")

	-- ======== MURAILLES DROITES (rayon 140) avec portes cardinales ========
	-- 4 murs droits + 4 portes alignees N/S/E/W
	local wallR = 140
	local wallH = 16
	local wallThick = 3.5
	local gateWidth = 16 -- Large pour que les monstres passent!

	-- Mur NORD (Z negatif) : X de -wallR a +wallR, Z = -wallR
	-- Porte au centre (X=0)
	local halfWallLen = (wallR * 2 - gateWidth) / 2
	-- Nord - cote gauche
	fp(town, "WallN_L", CF(-wallR/2 - gateWidth/4, wallH/2, -wallR), V3(halfWallLen, wallH, wallThick), "Medium stone grey", Enum.Material.Brick)
	-- Nord - cote droit
	fp(town, "WallN_R", CF(wallR/2 + gateWidth/4, wallH/2, -wallR), V3(halfWallLen, wallH, wallThick), "Medium stone grey", Enum.Material.Brick)
	-- Nord - arche
	fp(town, "GateN_Arch", CF(0, wallH - 2, -wallR), V3(gateWidth + 2, 4, wallThick), "Dark stone grey", Enum.Material.Brick)

	-- SUD (Z positif)
	fp(town, "WallS_L", CF(-wallR/2 - gateWidth/4, wallH/2, wallR), V3(halfWallLen, wallH, wallThick), "Medium stone grey", Enum.Material.Brick)
	fp(town, "WallS_R", CF(wallR/2 + gateWidth/4, wallH/2, wallR), V3(halfWallLen, wallH, wallThick), "Medium stone grey", Enum.Material.Brick)
	fp(town, "GateS_Arch", CF(0, wallH - 2, wallR), V3(gateWidth + 2, 4, wallThick), "Dark stone grey", Enum.Material.Brick)

	-- EST (X positif)
	fp(town, "WallE_L", CF(wallR, wallH/2, -wallR/2 - gateWidth/4), V3(wallThick, wallH, halfWallLen), "Medium stone grey", Enum.Material.Brick)
	fp(town, "WallE_R", CF(wallR, wallH/2, wallR/2 + gateWidth/4), V3(wallThick, wallH, halfWallLen), "Medium stone grey", Enum.Material.Brick)
	fp(town, "GateE_Arch", CF(wallR, wallH - 2, 0), V3(wallThick, 4, gateWidth + 2), "Dark stone grey", Enum.Material.Brick)

	-- OUEST (X negatif)
	fp(town, "WallW_L", CF(-wallR, wallH/2, -wallR/2 - gateWidth/4), V3(wallThick, wallH, halfWallLen), "Medium stone grey", Enum.Material.Brick)
	fp(town, "WallW_R", CF(-wallR, wallH/2, wallR/2 + gateWidth/4), V3(wallThick, wallH, halfWallLen), "Medium stone grey", Enum.Material.Brick)
	fp(town, "GateW_Arch", CF(-wallR, wallH - 2, 0), V3(wallThick, 4, gateWidth + 2), "Dark stone grey", Enum.Material.Brick)

	-- Creneaux sur les murs (decoratifs)
	for _, wallInfo in ipairs({
		{V3(-wallR, wallH + 1, -wallR), V3(halfWallLen, 2, 4), "N_L"},
		{V3(wallR, wallH + 1, -wallR), V3(halfWallLen, 2, 4), "N_R"},
		{V3(-wallR, wallH + 1, wallR), V3(halfWallLen, 2, 4), "S_L"},
		{V3(wallR, wallH + 1, wallR), V3(halfWallLen, 2, 4), "S_R"},
	}) do
		for b = -2, 2 do
			fp(town, "Battlement_" .. wallInfo[3] .. "_" .. b,
				CF(wallInfo[1] + V3(b * halfWallLen/5, 0, 0)),
				V3(4, 2, 3.5), "Dark stone grey", Enum.Material.Brick)
		end
	end

	-- Torches aux 4 portes
	local gatePositions = {
		{V3(0, 0, -wallR), "N", "🌲 Forêt"},
		{V3(0, 0, wallR), "S", "🌊 Mer"},
		{V3(wallR, 0, 0), "E", "⛰️ Montagne"},
		{V3(-wallR, 0, 0), "W", "🌑 Zone Sombre"},
	}
	for _, gp in ipairs(gatePositions) do
		-- Torches
		for side = -1, 1, 2 do
			local torchOffset
			if gp[2] == "N" or gp[2] == "S" then
				torchOffset = V3(side * (gateWidth/2 + 2), wallH/2, 0)
			else
				torchOffset = V3(0, wallH/2, side * (gateWidth/2 + 2))
			end
			local torch = fp(town, "GateTorch_" .. gp[2], CF(gp[1] + torchOffset), V3(0.5, 2, 0.5), "Bright orange", Enum.Material.Neon)
			local tL = Instance.new("PointLight")
			tL.Brightness = 0.4
			tL.Range = 12
			tL.Color = Color3.fromRGB(255, 160, 60)
			tL.Parent = torch
		end
		-- Zone sign above gate (NOT AlwaysOnTop, with MaxDistance)
		local signOffset
		if gp[2] == "N" or gp[2] == "S" then
			signOffset = V3(0, wallH + 4, 0)
		else
			signOffset = V3(0, wallH + 4, 0)
		end
		local gateSign = fp(town, "GateSign_" .. gp[2], CF(gp[1] + signOffset), V3(12, 4, 0.5), "Really black", Enum.Material.SmoothPlastic)
		local sGui = Instance.new("SurfaceGui")
		sGui.Face = Enum.NormalId.Front
		sGui.Parent = gateSign
		local sLbl = Instance.new("TextLabel")
		sLbl.Size = UDim2.new(1, 0, 1, 0)
		sLbl.BackgroundTransparency = 1
		sLbl.Text = gp[3]
		sLbl.TextScaled = true
		sLbl.TextColor3 = Color3.new(1, 1, 1)
		sLbl.Font = Enum.Font.GothamBold
		sLbl.Parent = sGui
		-- Also back
		local sGui2 = Instance.new("SurfaceGui")
		sGui2.Face = Enum.NormalId.Back
		sGui2.Parent = gateSign
		sLbl:Clone().Parent = sGui2
	end

	-- ======== 4 TOURS DE GARDE (coins du mur) ========
	createWatchTower(town, V3(wallR, 0, wallR), "Tower_SE")
	createWatchTower(town, V3(-wallR, 0, wallR), "Tower_SW")
	createWatchTower(town, V3(wallR, 0, -wallR), "Tower_NE")
	createWatchTower(town, V3(-wallR, 0, -wallR), "Tower_NW")

	-- ======== ROUTES PAVEES (cristal -> portes) ========
	local roadDirs = {
		{V3(0, 0, -1), "N", V3(10, 0.08, 7)},
		{V3(0, 0, 1), "S", V3(10, 0.08, 7)},
		{V3(1, 0, 0), "E", V3(7, 0.08, 10)},
		{V3(-1, 0, 0), "W", V3(7, 0.08, 10)},
	}
	for _, rd in ipairs(roadDirs) do
		for i = 1, 25 do
			local dist = 42 + i * 4
			if dist < wallR - 5 then
				local rp = fp(town, "Road_" .. rd[2] .. "_" .. i, CF(rd[1].X * dist, 0.04, rd[1].Z * dist), rd[3], "Nougat", Enum.Material.Cobblestone)
				rp.CanCollide = false
			end
		end
	end

	-- Route circulaire (rayon 70, entre les batiments du BuildingSystem)
	for i = 1, 40 do
		local a = (i / 40) * PI * 2
		local rr = fp(town, "RingRoad" .. i, CF(math.cos(a) * 70, 0.04, math.sin(a) * 70), V3(6, 0.08, 6), "Nougat", Enum.Material.Cobblestone)
		rr.CanCollide = false
	end

	-- ======== PUITS (position claire, pas de conflit BuildingSystem) ========
	local wellPos = V3(25, 0, 25)
	local wellBase = Instance.new("Part")
	wellBase.Name = "WellBase"
	wellBase.Shape = Enum.PartType.Cylinder
	wellBase.Size = V3(3, 4, 4)
	wellBase.CFrame = CF(wellPos + V3(0, 1.5, 0)) * CA(0, 0, RAD(90))
	wellBase.Anchored = true
	wellBase.Material = Enum.Material.Brick
	wellBase.BrickColor = BrickColor.new("Medium stone grey")
	wellBase.Parent = town
	local wellW = Instance.new("Part")
	wellW.Name = "WellWater"
	wellW.Shape = Enum.PartType.Cylinder
	wellW.Size = V3(0.2, 3.5, 3.5)
	wellW.CFrame = CF(wellPos + V3(0, 0.5, 0)) * CA(0, 0, RAD(90))
	wellW.Anchored = true
	wellW.Material = Enum.Material.Glass
	wellW.BrickColor = BrickColor.new("Bright blue")
	wellW.Transparency = 0.4
	wellW.Parent = town
	fp(town, "WellPost1", CF(wellPos + V3(-2, 3, 0)), V3(0.3, 6, 0.3), "Brown")
	fp(town, "WellPost2", CF(wellPos + V3(2, 3, 0)), V3(0.3, 6, 0.3), "Brown")
	fp(town, "WellRoof", CF(wellPos + V3(0, 6.5, 0)), V3(5, 0.5, 3), "Dark red", Enum.Material.Slate)

	-- ======== BANCS (autour de la place, pas de conflit) ========
	for i = 1, 8 do
		local a = (i / 8) * PI * 2
		local bp = V3(math.cos(a) * 38, 0, math.sin(a) * 38)
		local bRot = math.atan2(-bp.X, -bp.Z)
		local bCF = CF(bp) * CA(0, bRot, 0)
		fp(town, "Bench" .. i, bCF * CF(0, 1.2, 0), V3(3, 0.3, 1.2), "Brown")
		fp(town, "BenchBack" .. i, bCF * CF(0, 1.8, -0.5), V3(3, 0.8, 0.2), "Brown")
		fp(town, "BenchLeg" .. i, bCF * CF(-1.2, 0.6, 0), V3(0.3, 1.2, 1), "Brown")
		fp(town, "BenchLeg2_" .. i, bCF * CF(1.2, 0.6, 0), V3(0.3, 1.2, 1), "Brown")
	end

	-- ======== ARENE D'ENTRAINEMENT (position libre: 30, 0, 35) ========
	local arenaPos = V3(30, 0, 35)
	local arenaFloor = Instance.new("Part")
	arenaFloor.Name = "ArenaFloor"
	arenaFloor.Shape = Enum.PartType.Cylinder
	arenaFloor.Size = V3(0.3, 18, 18)
	arenaFloor.CFrame = CF(arenaPos + V3(0, 0.15, 0)) * CA(0, 0, RAD(90))
	arenaFloor.Anchored = true
	arenaFloor.Material = Enum.Material.Sand
	arenaFloor.BrickColor = BrickColor.new("Brick yellow")
	arenaFloor.CanCollide = false
	arenaFloor.Parent = town
	for af = 1, 10 do
		local afa = (af / 10) * PI * 2
		fp(town, "ArenaPost" .. af, CF(arenaPos + V3(math.cos(afa) * 9, 1.5, math.sin(afa) * 9)), V3(0.5, 3, 0.5), "Brown")
	end

	-- ======== ECLAIRAGE VILLE (lampes) ========
	for i = 1, 12 do
		local a = (i / 12) * PI * 2
		createLamp(town, V3(math.cos(a) * 32, 0, math.sin(a) * 32))
	end
	for i = 1, 10 do
		local a = (i / 10) * PI * 2
		createLamp(town, V3(math.cos(a) * 70, 0, math.sin(a) * 70))
	end
	for i = 1, 8 do
		local a = (i / 8) * PI * 2
		createLamp(town, V3(math.cos(a) * 120, 0, math.sin(a) * 120))
	end

	-- ======== JARDINS (positions libres) ========
	local gardenSpots = {V3(-30, 0, -25), V3(30, 0, -25), V3(-25, 0, 10), V3(15, 0, 45), V3(-15, 0, 50)}
	local flowerColors = {"Bright red", "Bright yellow", "Bright violet", "Hot pink", "Bright orange"}
	for _, gp in ipairs(gardenSpots) do
		fp(town, "Hedge", CF(gp + V3(0, 1.2, 0)), V3(4, 2, 4), "Earth green", Enum.Material.Grass)
		local fl = fp(town, "Flowers", CF(gp + V3(0, 2.5, 0)), V3(3, 0.3, 3), flowerColors[math.random(#flowerColors)], Enum.Material.Grass)
		fl.CanCollide = false
	end

	-- Arbres interieur murs
	for i = 1, 16 do
		local a = (i / 16) * PI * 2 + 0.2
		local r = 120
		createTree(town, V3(math.cos(a) * r, 0, math.sin(a) * r), "normal")
	end

	-- ======== ZONE NORD: FORET (chemin plat, pas d'escalier!) ========
	for i = 1, 30 do
		local pth = fp(town, "ForestPath" .. i, CF(0, 0.03, -140 - i * 6), V3(12, 0.05, 7), "Nougat", Enum.Material.Sand)
		pth.CanCollide = false
		if i % 2 == 0 then
			for side = -1, 1, 2 do
				createTree(town, V3(side * math.random(12, 35), 0, -140 - i * 6), "pine")
				if math.random() > 0.5 then
					createTree(town, V3(side * math.random(20, 50), 0, -140 - i * 6 + math.random(-4, 4)), "normal")
				end
			end
		end
		if i % 4 == 0 then
			for side = -1, 1, 2 do
				fp(town, "Bush", CF(side * math.random(8, 18), 0.8, -140 - i * 6), V3(3, 1.5, 3), "Earth green", Enum.Material.Grass)
			end
		end
	end
	-- Mushroom clearing
	for m = 1, 6 do
		local ma = (m / 6) * PI * 2
		fp(town, "Mushroom" .. m, CF(math.cos(ma) * 8, 0.6, -250 + math.sin(ma) * 8), V3(1, 1.2, 1), "Bright red", Enum.Material.SmoothPlastic)
		local cap = Instance.new("Part")
		cap.Name = "MushroomCap" .. m
		cap.Shape = Enum.PartType.Ball
		cap.Size = V3(2, 1, 2)
		cap.Position = V3(math.cos(ma) * 8, 1.6, -250 + math.sin(ma) * 8)
		cap.Anchored = true
		cap.Material = Enum.Material.SmoothPlastic
		cap.BrickColor = BrickColor.new("Bright red")
		cap.Parent = town
	end
	-- Forest treasure chest
	local fChest = fp(town, "TreasureChest_Forest", CF(18, 1, -230), V3(2.5, 2, 2), "Reddish brown")
	fp(town, "ChestLid_Forest", CF(18, 2.2, -230), V3(2.5, 0.5, 2), "Reddish brown")
	local fcp = Instance.new("ProximityPrompt")
	fcp.ActionText = "Ouvrir le coffre"
	fcp.ObjectText = "Coffre au trésor"
	fcp.MaxActivationDistance = 8
	fcp.HoldDuration = 1
	fcp.Parent = fChest
	fChest:SetAttribute("InteractiveType", "TreasureChest")
	fChest:SetAttribute("Reward", 50)

	-- ======== ZONE EST: MONTAGNE (rochers plats au sol, pas d'escalier!) ========
	for i = 1, 30 do
		local pth = fp(town, "MtnPath" .. i, CF(140 + i * 6, 0.03, 0), V3(7, 0.05, 12), "Medium stone grey", Enum.Material.Slate)
		pth.CanCollide = false
		if i % 2 == 0 then
			for side = -1, 1, 2 do
				local rh = math.random(4, 12)
				fp(town, "Rock", CF(140 + i * 6, rh / 2, side * math.random(12, 30)), V3(math.random(4, 10), rh, math.random(4, 10)), "Dark stone grey", Enum.Material.Slate)
			end
		end
		-- PAS d'elevation/escalier! Les rochers decoratifs seulement
	end
	-- Mining rocks (interactifs)
	for mr = 1, 3 do
		local mrk = fp(town, "MiningRock" .. mr, CF(200 + mr * 25, 2, math.random(-12, 12)), V3(4, 3.5, 4), "Medium stone grey", Enum.Material.Slate)
		local oreC = ({"Gold", "Bright blue", "Bright green"})[mr]
		local vein = fp(town, "OreVein" .. mr, CF(mrk.Position + V3(0, 0, -1.5)), V3(1.5, 1.5, 0.3), oreC, Enum.Material.Neon)
		vein.Transparency = 0.3
		local mp = Instance.new("ProximityPrompt")
		mp.ActionText = "Miner"
		mp.ObjectText = "Minerai"
		mp.MaxActivationDistance = 8
		mp.HoldDuration = 2
		mp.Parent = mrk
		mrk:SetAttribute("InteractiveType", "MiningRock")
		mrk:SetAttribute("Reward", 20 + mr * 10)
	end

	-- ======== ZONE SUD: MER / PLAGE (plat, pas d'escalier!) ========
	for i = 1, 30 do
		local pth = fp(town, "BeachPath" .. i, CF(0, 0.03, 140 + i * 6), V3(12, 0.05, 7), "Brick yellow", Enum.Material.Sand)
		pth.CanCollide = false
		-- Sable etendu (plat!)
		if i > 3 then
			for side = -1, 1, 2 do
				local sand = fp(town, "Sand", CF(side * 20, 0.15, 140 + i * 6), V3(28, 0.3, 8), "Brick yellow", Enum.Material.Sand)
			end
		end
		if i > 3 and i % 3 == 0 then
			createTree(town, V3(math.random(-25, 25), 0, 140 + i * 6), "palm")
		end
		-- Eau (plane, CanCollide false, pas de blocage!)
		if i > 14 then
			local wp = fp(town, "SeaWater", CF(0, 0.2, 140 + i * 6), V3(60, 0.5, 8), "Bright blue", Enum.Material.Glass)
			wp.Transparency = 0.35
			wp.CanCollide = false
		end
	end
	-- Pier
	fp(town, "PierBase", CF(0, 1.2, 255), V3(6, 0.5, 20), "Brown", Enum.Material.WoodPlanks)
	for side = -1, 1, 2 do
		fp(town, "PierRail" .. side, CF(side * 3, 2, 255), V3(0.3, 1.5, 20), "Dark orange")
	end
	-- Fishing spots
	for fs = 1, 2 do
		local fsp = fp(town, "FishingSpot" .. fs, CF((fs * 2 - 3) * 8, 0.2, 270), V3(4, 0.3, 4), "Bright blue", Enum.Material.Neon)
		fsp.Transparency = 0.6
		fsp.CanCollide = false
		local fishP = Instance.new("ProximityPrompt")
		fishP.ActionText = "Pêcher"
		fishP.ObjectText = "Spot de pêche"
		fishP.MaxActivationDistance = 10
		fishP.HoldDuration = 3
		fishP.Parent = fsp
		fsp:SetAttribute("InteractiveType", "FishingSpot")
	end
	-- Bridge (plat, au ras du sol)
	fp(town, "BridgeDeck", CF(0, 1, 240), V3(10, 0.5, 20), "Brown", Enum.Material.WoodPlanks)
	for side = -1, 1, 2 do
		fp(town, "BridgeRail" .. side, CF(side * 5, 2, 240), V3(0.4, 2, 20), "Dark orange")
	end

	-- ======== ZONE OUEST: FORET SOMBRE ========
	for i = 1, 30 do
		local pth = fp(town, "DarkPath" .. i, CF(-140 - i * 6, 0.03, 0), V3(7, 0.05, 12), "Really black", Enum.Material.Cobblestone)
		pth.CanCollide = false
		if i % 2 == 0 then
			for side = -1, 1, 2 do
				createTree(town, V3(-140 - i * 6, 0, side * math.random(10, 25)), "dark")
			end
		end
		if i > 5 then
			local fog = fp(town, "Fog", CF(-140 - i * 6, 3, math.random(-10, 10)), V3(16, 6, 16), "Dark indigo", Enum.Material.Neon)
			fog.Transparency = 0.9
			fog.CanCollide = false
		end
	end
	-- Ancient ruins
	local ruinPos = V3(-250, 0, 0)
	for rp = 1, 6 do
		local rpa = (rp / 6) * PI * 2
		fp(town, "RuinPillar" .. rp, CF(ruinPos + V3(math.cos(rpa) * 12, math.random(2, 5), math.sin(rpa) * 12)), V3(3, math.random(4, 10), 3), "Medium stone grey", Enum.Material.Concrete)
	end
	fp(town, "RuinAltar", CF(ruinPos + V3(0, 1, 0)), V3(6, 2, 4), "Dark stone grey", Enum.Material.Concrete)
	local ruinGlow = fp(town, "RuinGlow", CF(ruinPos + V3(0, 2.5, 0)), V3(2, 1, 2), "Bright violet", Enum.Material.Neon)
	ruinGlow.Transparency = 0.4
	local rl = Instance.new("PointLight")
	rl.Brightness = 0.4
	rl.Range = 12
	rl.Color = Color3.fromRGB(150, 50, 255)
	rl.Parent = ruinGlow
	-- Glowing mushrooms
	for gm = 1, 6 do
		local gmp = V3(-200 - math.random(0, 30), 0.5, math.random(-20, 20))
		local gMush = fp(town, "GlowMush" .. gm, CF(gmp), V3(0.5, 0.8, 0.5), "Bright violet", Enum.Material.Neon)
		gMush.Transparency = 0.3
	end

	print("[WorldBuilder V35] Town created (600x600, straight walls, aligned gates, no building overlap)")
	return town
end

-- ============================================================
-- PNJ GUIDE (Aldric)
-- ============================================================
function WorldBuilder.CreateNPC()
	local ws = game.Workspace
	local npcPos = V3(12, 1, -18)

	local npc = Instance.new("Model")
	npc.Name = "GuideNPC"
	npc.Parent = ws

	local torso = Instance.new("Part")
	torso.Name = "Torso"
	torso.Size = V3(2, 2, 1)
	torso.Position = npcPos + V3(0, 3, 0)
	torso.Anchored = true
	torso.BrickColor = BrickColor.new("Bright blue")
	torso.Parent = npc

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = V3(2, 1, 1)
	head.Position = torso.Position + V3(0, 1.5, 0)
	head.Anchored = true
	head.BrickColor = BrickColor.new("Light orange")
	head.Parent = npc

	local face = Instance.new("Decal")
	face.Texture = "rbxasset://textures/face.png"
	face.Face = Enum.NormalId.Front
	face.Parent = head

	fp(npc, "Hat", CF(head.Position + V3(0, 2, 0)), V3(2.5, 3, 2.5), "Navy blue", Enum.Material.Fabric)
	fp(npc, "HatBrim", CF(head.Position + V3(0, 1, 0)), V3(4, 0.3, 4), "Navy blue", Enum.Material.Fabric)

	for i = -1, 1, 2 do
		fp(npc, "Leg", CF(torso.Position + V3(i * 0.5, -2, 0)), V3(1, 2, 1), "Dark green")
		fp(npc, "Arm", CF(torso.Position + V3(i * 1.5, 0, 0)), V3(1, 2, 1), "Bright blue")
	end

	local staff = fp(npc, "Staff", CF(torso.Position + V3(2, 0, 0)), V3(0.4, 7, 0.4), "Brown")
	local staffOrb = Instance.new("Part")
	staffOrb.Name = "StaffOrb"
	staffOrb.Shape = Enum.PartType.Ball
	staffOrb.Size = V3(1.2, 1.2, 1.2)
	staffOrb.Position = staff.Position + V3(0, 3.8, 0)
	staffOrb.Anchored = true
	staffOrb.Material = Enum.Material.Neon
	staffOrb.BrickColor = BrickColor.new("Cyan")
	staffOrb.Parent = npc
	local sL = Instance.new("PointLight")
	sL.Brightness = 0.6
	sL.Range = 10
	sL.Color = Color3.fromRGB(100, 200, 255)
	sL.Parent = staffOrb

	npc.PrimaryPart = torso

	-- Billboard (MaxDistance, NOT AlwaysOnTop from far!)
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.fromOffset(220, 60)
	billboard.StudsOffset = V3(0, 5, 0)
	billboard.AlwaysOnTop = false
	billboard.MaxDistance = 60
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
	Instance.new("UICorner", nameLabel).CornerRadius = UDim.new(0, 8)

	local detector = Instance.new("ClickDetector")
	detector.MaxActivationDistance = 25
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
	print("[WorldBuilder V35] NPC Aldric created")
	return npc, detector, prompt
end

-- ============================================================
-- SPAWN POINTS (300 studs, SUR LES AXES des portes)
-- ============================================================
function WorldBuilder.CreateSpawnPoints()
	local ws = game.Workspace
	local old = ws:FindFirstChild("WildSpawnPoints")
	if old then old:Destroy() end

	local folder = Instance.new("Folder")
	folder.Name = "WildSpawnPoints"
	folder.Parent = ws

	-- Spawn directement dans l'axe des portes!
	local spawnData = {
		{name = "SP_Foret", pos = V3(0, 0.5, -300), color = "Earth green"},
		{name = "SP_Montagne", pos = V3(300, 0.5, 0), color = "Medium stone grey"},
		{name = "SP_Mer", pos = V3(0, 0.5, 300), color = "Bright blue"},
		{name = "SP_Sombre", pos = V3(-300, 0.5, 0), color = "Really black"},
	}

	for _, data in ipairs(spawnData) do
		local sp = Instance.new("Part")
		sp.Name = data.name
		sp.Size = V3(14, 1, 14)
		sp.Position = data.pos
		sp.Anchored = true
		sp.CanCollide = false
		sp.Transparency = 0.6
		sp.BrickColor = BrickColor.new(data.color)
		sp.Material = Enum.Material.Neon
		sp.Parent = folder

		local beacon = Instance.new("Part")
		beacon.Size = V3(1, 25, 1)
		beacon.Position = data.pos + V3(0, 12, 0)
		beacon.Anchored = true
		beacon.CanCollide = false
		beacon.Transparency = 0.7
		beacon.BrickColor = BrickColor.new(data.color)
		beacon.Material = Enum.Material.Neon
		beacon.Parent = folder
	end
	print("[WorldBuilder V35] 4 spawn points at 300 studs (aligned with gates)")
	return folder
end

-- ============================================================
-- PLAYER SPAWN
-- ============================================================
function WorldBuilder.CreatePlayerSpawn()
	local ws = game.Workspace
	for _, obj in pairs(ws:GetDescendants()) do
		if obj:IsA("SpawnLocation") then obj:Destroy() end
	end
	local spawn = Instance.new("Part")
	spawn.Name = "PlayerSpawn"
	spawn.Size = V3(15, 1, 15)
	spawn.Position = V3(0, 0.5, -40)
	spawn.Anchored = true
	spawn.CanCollide = false
	spawn.Transparency = 0.8
	spawn.BrickColor = BrickColor.new("Bright green")
	spawn.Material = Enum.Material.Grass
	spawn.Parent = ws
	print("[WorldBuilder V35] Player spawn at (0, 0, -40)")
	return spawn
end

-- ============================================================
-- HALL DES CLASSES (au sol, pas de conflit)
-- ============================================================
function WorldBuilder.CreateClassHall()
	local ws = game.Workspace
	local hallPos = V3(0, 0, 30)

	local hall = Instance.new("Model")
	hall.Name = "ClassHall"

	fp(hall, "Floor", CF(hallPos + V3(0, 0.5, 0)), V3(50, 1, 40), "Institutional white", Enum.Material.Marble)
	fp(hall, "Wall_Back", CF(hallPos + V3(0, 9.5, -19)), V3(50, 18, 2), "Sand red", Enum.Material.Brick)
	fp(hall, "Wall_L", CF(hallPos + V3(-24, 9.5, 0)), V3(2, 18, 40), "Sand red", Enum.Material.Brick)
	fp(hall, "Wall_R", CF(hallPos + V3(24, 9.5, 0)), V3(2, 18, 40), "Sand red", Enum.Material.Brick)
	fp(hall, "Roof", CF(hallPos + V3(0, 19, 0)), V3(55, 2, 45), "Dark red", Enum.Material.Slate)

	-- 6 colonnes
	for _, cx in ipairs({-18, -10, -2, 6, 14, 22}) do
		fp(hall, "Column", CF(hallPos + V3(cx, 9.5, 18)), V3(3, 17, 3), "Institutional white", Enum.Material.Marble)
	end

	-- Enseigne (BillboardGui avec MaxDistance)
	local mainSign = fp(hall, "MainSign", CF(hallPos + V3(0, 21, 18)), V3(35, 5, 1), "Really black", Enum.Material.SmoothPlastic)
	local signBB = Instance.new("BillboardGui")
	signBB.Size = UDim2.fromOffset(300, 80)
	signBB.StudsOffset = V3(0, 2, 0)
	signBB.AlwaysOnTop = false
	signBB.MaxDistance = 80
	signBB.Parent = mainSign
	local signLbl = Instance.new("TextLabel")
	signLbl.Size = UDim2.new(1, 0, 1, 0)
	signLbl.BackgroundTransparency = 1
	signLbl.Text = "⚔️ HALL DES CLASSES ⚔️"
	signLbl.TextScaled = true
	signLbl.TextColor3 = Color3.fromRGB(255, 220, 100)
	signLbl.Font = Enum.Font.GothamBold
	signLbl.Parent = signBB

	local hallLight = Instance.new("PointLight")
	hallLight.Brightness = 0.8
	hallLight.Range = 35
	hallLight.Color = Color3.fromRGB(255, 200, 150)
	hallLight.Parent = hall:FindFirstChild("Floor")

	-- 4 podiums de classe
	local classes = {
		{name = "Guerrier", color = Color3.fromRGB(200, 50, 50), emoji = "⚔️", offset = V3(-14, 0, -5), desc = "Force brute\nATK +5, DEF +3", starterMonster = "flameguard"},
		{name = "Mage", color = Color3.fromRGB(100, 50, 200), emoji = "🔮", offset = V3(-4, 0, -5), desc = "Puissance arcane\nMagie, AoE", starterMonster = "voltsprite"},
		{name = "Archer", color = Color3.fromRGB(40, 160, 40), emoji = "🏹", offset = V3(6, 0, -5), desc = "Distance, Précision\nFlèches infinies", starterMonster = "shadeveil"},
		{name = "Moine", color = Color3.fromRGB(255, 220, 50), emoji = "🙏", offset = V3(16, 0, -5), desc = "Sustain, Support\nSoins, Buffs", starterMonster = "aquashell"},
	}

	for _, cls in ipairs(classes) do
		local pBase = Instance.new("Part")
		pBase.Name = "PodiumBase_" .. cls.name
		pBase.Size = V3(9, 1, 9)
		pBase.Position = hallPos + cls.offset + V3(0, 1, 0)
		pBase.Anchored = true
		pBase.Color = cls.color
		pBase.Material = Enum.Material.Marble
		pBase.Transparency = 0.1
		pBase.Parent = hall

		local podium = Instance.new("Part")
		podium.Name = "Podium_" .. cls.name
		podium.Size = V3(7, 2, 7)
		podium.Position = hallPos + cls.offset + V3(0, 2.5, 0)
		podium.Anchored = true
		podium.Color = cls.color
		podium.Material = Enum.Material.Marble
		podium.Parent = hall

		local statue = Instance.new("Part")
		statue.Name = "Statue_" .. cls.name
		statue.Size = V3(2, 6, 2)
		statue.Position = hallPos + cls.offset + V3(0, 6.5, 0)
		statue.Anchored = true
		statue.Color = cls.color
		statue.Material = Enum.Material.Neon
		statue.Transparency = 0.2
		statue.Parent = hall

		local aura = Instance.new("ParticleEmitter")
		aura.Color = ColorSequence.new(cls.color)
		aura.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 0)})
		aura.Lifetime = NumberRange.new(1, 2)
		aura.Rate = 6
		aura.Speed = NumberRange.new(1, 2)
		aura.SpreadAngle = Vector2.new(360, 360)
		aura.LightEmission = 0.8
		aura.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1)})
		aura.Parent = statue

		-- Billboard (MaxDistance)
		local cBB = Instance.new("BillboardGui")
		cBB.Size = UDim2.new(0, 150, 0, 70)
		cBB.StudsOffset = V3(0, 5, 0)
		cBB.AlwaysOnTop = false
		cBB.MaxDistance = 40
		cBB.Parent = statue

		local cLabel = Instance.new("TextLabel")
		cLabel.Size = UDim2.new(1, 0, 0.5, 0)
		cLabel.BackgroundColor3 = Color3.new(0, 0, 0)
		cLabel.BackgroundTransparency = 0.3
		cLabel.Text = cls.emoji .. " " .. cls.name
		cLabel.TextScaled = true
		cLabel.TextColor3 = Color3.new(1, 1, 1)
		cLabel.Font = Enum.Font.GothamBold
		cLabel.Parent = cBB

		local dLabel = Instance.new("TextLabel")
		dLabel.Size = UDim2.new(1, 0, 0.5, 0)
		dLabel.Position = UDim2.new(0, 0, 0.5, 0)
		dLabel.BackgroundTransparency = 1
		dLabel.Text = cls.desc
		dLabel.TextScaled = true
		dLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		dLabel.Font = Enum.Font.Gotham
		dLabel.Parent = cBB

		local classPrompt = Instance.new("ProximityPrompt")
		classPrompt.ActionText = "Choisir " .. cls.name
		classPrompt.ObjectText = cls.name
		classPrompt.KeyboardKeyCode = Enum.KeyCode.F
		classPrompt.MaxActivationDistance = 10
		classPrompt.HoldDuration = 1.5
		classPrompt.RequiresLineOfSight = false
		classPrompt.Parent = podium

		podium:SetAttribute("ClassName", cls.name)
		podium:SetAttribute("StarterMonster", cls.starterMonster)
	end

	hall.Parent = ws
	print("[WorldBuilder V35] Class Hall at center plaza")
	return hall
end

-- ============================================================
-- ECLAIRAGE CORRIGE (moins brillant!)
-- ============================================================
function WorldBuilder.SetupLighting()
	local Lighting = game:GetService("Lighting")

	local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
	if not atmo then atmo = Instance.new("Atmosphere"); atmo.Parent = Lighting end
	atmo.Density = 0.35
	atmo.Offset = 0.1
	atmo.Color = Color3.fromRGB(190, 210, 245)
	atmo.Decay = Color3.fromRGB(140, 160, 200)
	atmo.Glare = 0
	atmo.Haze = 1.5

	local bloom = Lighting:FindFirstChild("Bloom")
	if not bloom then bloom = Instance.new("BloomEffect"); bloom.Name = "Bloom"; bloom.Parent = Lighting end
	bloom.Intensity = 0.06
	bloom.Size = 18
	bloom.Threshold = 1.8

	local cc = Lighting:FindFirstChild("ColorCorrection")
	if not cc then cc = Instance.new("ColorCorrectionEffect"); cc.Name = "ColorCorrection"; cc.Parent = Lighting end
	cc.Brightness = 0
	cc.Contrast = 0.06
	cc.Saturation = 0.12
	cc.TintColor = Color3.fromRGB(255, 250, 248)

	local rays = Lighting:FindFirstChild("SunRays")
	if not rays then rays = Instance.new("SunRaysEffect"); rays.Name = "SunRays"; rays.Parent = Lighting end
	rays.Intensity = 0.025
	rays.Spread = 0.5

	Lighting.Ambient = Color3.fromRGB(55, 60, 70)
	Lighting.OutdoorAmbient = Color3.fromRGB(85, 95, 115)
	Lighting.Brightness = 1.2
	Lighting.ClockTime = 14
	Lighting.GeographicLatitude = 35
	Lighting.EnvironmentDiffuseScale = 0.45
	Lighting.EnvironmentSpecularScale = 0.25
	Lighting.GlobalShadows = true
	Lighting.ShadowSoftness = 0.2
	Lighting.ExposureCompensation = -0.3

	local sky = Lighting:FindFirstChildOfClass("Sky")
	if not sky then sky = Instance.new("Sky"); sky.Parent = Lighting end
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

	local dof = Lighting:FindFirstChild("DepthOfField")
	if not dof then dof = Instance.new("DepthOfFieldEffect"); dof.Name = "DepthOfField"; dof.Parent = Lighting end
	dof.FarIntensity = 0.05
	dof.FocusDistance = 80
	dof.InFocusRadius = 50
	dof.NearIntensity = 0

	print("[WorldBuilder V35] Lighting reduced! Brightness=1.2, Exposure=-0.3")
end

return WorldBuilder
