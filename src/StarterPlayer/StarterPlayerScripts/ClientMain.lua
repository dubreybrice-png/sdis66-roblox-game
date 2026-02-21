--[[
	ClientMain V30
	Point d'entrée client - initialise le jeu côté client
	CAMERA NORMALE (3ème personne) pour jouer correctement
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer

print("[Client V30] Initializing for", player.Name)

-- Attendre que le personnage soit chargé
player.CharacterAdded:Connect(function(character)
	print("[Client] Character loaded")
	
	-- CAMERA NORMALE - 3ème personne (ne PAS mettre en Scriptable!)
	local camera = workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Custom
	camera.FieldOfView = 70
	
	-- Attendre le HumanoidRootPart
	local hrp = character:WaitForChild("HumanoidRootPart", 5)
	if hrp then
		camera.CameraSubject = character:WaitForChild("Humanoid")
	end
	
	print("[Client] Camera set to normal 3rd person")
end)

-- Configurer l'UI de base
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false) -- UI custom dans PlayerHUD

print("[Client V30] Ready!")
