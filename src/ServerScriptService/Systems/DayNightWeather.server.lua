--[[
	DayNightWeather V30 - Cycle jour/nuit et météo dynamique
	- Cycle jour/nuit de 10 minutes (accéléré)
	- Météo aléatoire: Clair, Nuageux, Pluie, Orage, Brouillard
	- Effets visuels et gameplay (bonus/malus selon météo)
]]

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

print("[DayNightWeather V30] Loading...")

local remotes = ReplicatedStorage:WaitForChild("Remotes", 15)
if not remotes then
	warn("[DayNightWeather] Remotes not found!")
	return
end

-- Créer le remote météo s'il n'existe pas
local weatherRemote = remotes:FindFirstChild("WeatherUpdate")
if not weatherRemote then
	weatherRemote = Instance.new("RemoteEvent")
	weatherRemote.Name = "WeatherUpdate"
	weatherRemote.Parent = remotes
end

-- === CONFIG ===
local DAY_CYCLE_MINUTES = 10 -- Un cycle complet dure 10 minutes IRL
local WEATHER_CHANGE_INTERVAL = 120 -- Changement de météo toutes les 2 minutes

-- === MÉTÉO ===
local WEATHER_TYPES = {
	{
		name = "Clair",
		emoji = "☀️",
		weight = 35,
		atmosphere = {Density = 0.25, Haze = 1.5, Glare = 0},
		brightness = 2.5,
		fogEnd = 10000,
		ambient = Color3.fromRGB(100, 110, 130),
	},
	{
		name = "Nuageux",
		emoji = "☁️",
		weight = 25,
		atmosphere = {Density = 0.35, Haze = 3, Glare = 0},
		brightness = 1.8,
		fogEnd = 3000,
		ambient = Color3.fromRGB(80, 85, 100),
	},
	{
		name = "Pluie",
		emoji = "🌧️",
		weight = 20,
		atmosphere = {Density = 0.45, Haze = 5, Glare = 0},
		brightness = 1.2,
		fogEnd = 1500,
		ambient = Color3.fromRGB(60, 65, 80),
	},
	{
		name = "Orage",
		emoji = "⛈️",
		weight = 10,
		atmosphere = {Density = 0.5, Haze = 6, Glare = 0.1},
		brightness = 0.8,
		fogEnd = 800,
		ambient = Color3.fromRGB(40, 45, 60),
	},
	{
		name = "Brouillard",
		emoji = "🌫️",
		weight = 10,
		atmosphere = {Density = 0.6, Haze = 8, Glare = 0},
		brightness = 1.5,
		fogEnd = 400,
		ambient = Color3.fromRGB(90, 95, 100),
	},
}

local currentWeather = WEATHER_TYPES[1] -- Commence clair

-- Choisir une météo pondérée
local function pickRandomWeather()
	local totalWeight = 0
	for _, w in ipairs(WEATHER_TYPES) do
		totalWeight = totalWeight + w.weight
	end
	
	local roll = math.random() * totalWeight
	local cumulative = 0
	for _, w in ipairs(WEATHER_TYPES) do
		cumulative = cumulative + w.weight
		if roll <= cumulative then
			return w
		end
	end
	return WEATHER_TYPES[1]
end

-- Interpoler entre deux valeurs
local function lerp(a, b, t)
	return a + (b - a) * t
end

local function lerpColor(c1, c2, t)
	return Color3.new(
		lerp(c1.R, c2.R, t),
		lerp(c1.G, c2.G, t),
		lerp(c1.B, c2.B, t)
	)
end

-- Appliquer la météo avec transition douce
local function applyWeather(weather, duration)
	duration = duration or 5
	
	local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
	if not atmo then return end
	
	local startDensity = atmo.Density
	local startHaze = atmo.Haze
	local startBrightness = Lighting.Brightness
	local startAmbient = Lighting.OutdoorAmbient
	
	local targetDensity = weather.atmosphere.Density
	local targetHaze = weather.atmosphere.Haze
	local targetBrightness = weather.brightness
	local targetAmbient = weather.ambient
	
	-- Transition
	local steps = 50
	for i = 1, steps do
		local t = i / steps
		atmo.Density = lerp(startDensity, targetDensity, t)
		atmo.Haze = lerp(startHaze, targetHaze, t)
		Lighting.Brightness = lerp(startBrightness, targetBrightness, t)
		Lighting.OutdoorAmbient = lerpColor(startAmbient, targetAmbient, t)
		task.wait(duration / steps)
	end
end

-- === CYCLE JOUR/NUIT ===
task.spawn(function()
	-- Vitesse: 24h en jeu = DAY_CYCLE_MINUTES minutes IRL
	-- 1 heure en jeu = DAY_CYCLE_MINUTES/24 minutes IRL = DAY_CYCLE_MINUTES*60/24 secondes
	local secondsPerGameHour = (DAY_CYCLE_MINUTES * 60) / 24
	
	while true do
		-- Incrémenter le temps
		local increment = 24 / (DAY_CYCLE_MINUTES * 60) -- heures par seconde
		Lighting.ClockTime = (Lighting.ClockTime + increment) % 24
		
		-- Ajuster l'ambiance selon l'heure
		local hour = Lighting.ClockTime
		
		-- Nuit (20h-6h): réduire la luminosité
		if hour >= 20 or hour < 6 then
			-- Nuit
			local nightFactor = 0.3
			if hour >= 20 then
				nightFactor = lerp(1, 0.3, (hour - 20) / 4)
			elseif hour < 4 then
				nightFactor = 0.3
			else
				nightFactor = lerp(0.3, 1, (hour - 4) / 2)
			end
			
			Lighting.Brightness = currentWeather.brightness * nightFactor
			Lighting.OutdoorAmbient = lerpColor(
				Color3.fromRGB(20, 20, 40),
				currentWeather.ambient,
				nightFactor
			)
		end
		
		-- Notifier les joueurs du changement de période
		if math.abs(hour - 6) < 0.1 then
			-- Lever du soleil
			for _, player in ipairs(Players:GetPlayers()) do
				local notify = remotes:FindFirstChild("NotifyPlayer")
				if notify then
					notify:FireClient(player, "🌅 Le soleil se lève...")
				end
			end
		elseif math.abs(hour - 20) < 0.1 then
			-- Coucher du soleil
			for _, player in ipairs(Players:GetPlayers()) do
				local notify = remotes:FindFirstChild("NotifyPlayer")
				if notify then
					notify:FireClient(player, "🌙 La nuit tombe... Les monstres deviennent plus forts!")
				end
			end
		end
		
		task.wait(1)
	end
end)

-- === CYCLE MÉTÉO ===
task.spawn(function()
	task.wait(10) -- Attendre que le monde soit prêt
	
	while true do
		-- Changer la météo
		local newWeather = pickRandomWeather()
		
		-- Éviter de répéter la même météo 3 fois de suite
		if newWeather.name ~= currentWeather.name then
			currentWeather = newWeather
			
			print("[DayNightWeather] Weather changing to:", currentWeather.emoji, currentWeather.name)
			
			-- Notifier les joueurs
			for _, player in ipairs(Players:GetPlayers()) do
				local notify = remotes:FindFirstChild("NotifyPlayer")
				if notify then
					notify:FireClient(player, currentWeather.emoji .. " Météo: " .. currentWeather.name)
				end
				weatherRemote:FireClient(player, currentWeather.name)
			end
			
			-- Appliquer la transition
			applyWeather(currentWeather, 8)
			
			-- Effet spécial pour l'orage: éclairs
			if currentWeather.name == "Orage" then
				task.spawn(function()
					while currentWeather.name == "Orage" do
						-- Flash d'éclair
						local originalBrightness = Lighting.Brightness
						Lighting.Brightness = 5
						task.wait(0.1)
						Lighting.Brightness = originalBrightness
						task.wait(math.random(5, 15))
					end
				end)
			end
		end
		
		task.wait(WEATHER_CHANGE_INTERVAL)
	end
end)

print("[DayNightWeather V30] ✅ Day/Night cycle (" .. DAY_CYCLE_MINUTES .. " min) + Weather system active!")
