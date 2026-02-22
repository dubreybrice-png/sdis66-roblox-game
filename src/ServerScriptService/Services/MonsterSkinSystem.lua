--[[
	MonsterSkinSystem V35.2 - Skins et textures pour monstres
	- Decals PNG pour monstres generiques
	- Support MeshPart pour modeles 3D importes (FBX)
	- Skin special araignee (Spider FBX)
	
	IMPORT FBX DANS ROBLOX STUDIO:
	1. Menu "Game" (ou "Home") > "Import 3D"
	2. Selectionner le fichier Spider.fbx
	3. Importer → ca cree un Model dans Workspace
	4. Selectionner le Model importe > clic droit > "Save to Roblox"
	5. Copier l'AssetID du mesh principal
	6. Coller l'ID dans SPIDER_MESH_ID ci-dessous
	7. Idem pour la texture → SPIDER_TEXTURE_ID
]]

local MonsterSkinSystem = {}

-- IDS DES IMAGES UPLOADÉES (decals generiques)
local MONSTER_SKINS = {
	"rbxassetid://75555966369836",
	"rbxassetid://74950508933506",
	"rbxassetid://88842105258488"
}

-- === SPIDER 3D MESH (a remplir apres import FBX dans Studio) ===
-- Apres avoir importe Spider.fbx dans Roblox Studio:
-- 1. Trouver le MeshPart dans le modele importe
-- 2. Copier son MeshId (rbxassetid://XXXXXXXXX)
-- 3. Copier son TextureID si disponible
local SPIDER_MESH_ID = nil -- Ex: "rbxassetid://123456789"
local SPIDER_TEXTURE_ID = nil -- Ex: "rbxassetid://987654321"

-- Appliquer une texture decal a un monstre generique
function MonsterSkinSystem:ApplySkin(monsterBody, skinIndex)
	if not monsterBody then return end
	
	skinIndex = skinIndex or math.random(1, #MONSTER_SKINS)
	local skinId = MONSTER_SKINS[skinIndex]
	
	print("[MonsterSkinSystem] Applying skin #" .. skinIndex .. " to", monsterBody.Parent.Name)
	
	-- Créer une Decal avec l'image
	local decal = Instance.new("Decal")
	decal.Texture = skinId
	decal.Face = Enum.NormalId.Front
	decal.Parent = monsterBody
	
	return true
end

-- Remplacer le corps d'un monstre araignee par un MeshPart FBX
-- Appeler UNIQUEMENT si SPIDER_MESH_ID est defini (apres import dans Studio)
function MonsterSkinSystem:ApplySpiderMesh(monsterModel)
	if not SPIDER_MESH_ID then
		print("[MonsterSkinSystem] Spider mesh not imported yet - using procedural model")
		return false
	end
	
	if not monsterModel or not monsterModel:IsA("Model") then return false end
	
	local body = monsterModel:FindFirstChild("Body")
	if not body then return false end
	
	print("[MonsterSkinSystem] Applying Spider 3D mesh to", monsterModel.Name)
	
	-- Creer un MeshPart pour remplacer le corps procedurale
	local meshPart = Instance.new("MeshPart")
	meshPart.Name = "SpiderMesh"
	meshPart.MeshId = SPIDER_MESH_ID
	if SPIDER_TEXTURE_ID then
		meshPart.TextureID = SPIDER_TEXTURE_ID
	end
	meshPart.Size = body.Size * 1.5
	meshPart.CFrame = body.CFrame
	meshPart.Anchored = false
	meshPart.CanCollide = true
	meshPart.Parent = monsterModel
	
	-- Weld le mesh au body
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = body
	weld.Part1 = meshPart
	weld.Parent = meshPart
	
	-- Cacher les parts procedurales (garder Body pour la physique)
	for _, child in ipairs(monsterModel:GetChildren()) do
		if child:IsA("BasePart") and child.Name ~= "Body" and child.Name ~= "SpiderMesh" then
			child.Transparency = 1
		end
	end
	body.Transparency = 1
	
	return true
end

-- Verifier si un monstre est de type araignee
function MonsterSkinSystem:IsSpider(speciesId)
	local spiderSpecies = {
		spiderling = true,
		shadowspider = true,
		arachnoqueen = true,
		venomweaver = true,
	}
	return spiderSpecies[speciesId] or false
end

-- Appliquer le bon skin selon le type de monstre
function MonsterSkinSystem:AutoApply(monsterModel, speciesId)
	if not monsterModel then return end
	
	if self:IsSpider(speciesId) then
		-- Essayer le mesh FBX, sinon le modele procedural est deja en place
		self:ApplySpiderMesh(monsterModel)
	else
		-- Skin decal generique
		local body = monsterModel:FindFirstChild("Body")
		if body then
			self:ApplySkin(body)
		end
	end
end

return MonsterSkinSystem
