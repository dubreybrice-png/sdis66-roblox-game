-- POPUP VERSION SIMPLE
print("�🔴🔴 [VersionPopup] SCRIPT STARTING! 🔴🔴🔴")

local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("[VersionPopup] LocalPlayer:", player and player.Name or "NIL!")

if not player then
	print("[VersionPopup] 🔴 ERROR: LocalPlayer is nil!")
	return
end

local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then
	print("[VersionPopup] 🔴 ERROR: PlayerGui not found!")
	return
end

print("[VersionPopup] 🟢 Creating version popup...")

local popup = Instance.new("ScreenGui")
popup.Name = "VersionPopup"
popup.ResetOnSpawn = false
popup.Parent = playerGui

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 600, 0, 200)
label.Position = UDim2.new(0.5, -300, 0.5, -100)
label.BackgroundColor3 = Color3.fromRGB(40, 0, 60)
label.BorderSizePixel = 4
label.BorderColor3 = Color3.fromRGB(180, 50, 255)
label.Text = "🕷️ VERSION 35.2 🕷️\nAraignées, Fix Inventaire, Skins 3D!"
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextSize = 42
label.Font = Enum.Font.GothamBold
label.Parent = popup

Instance.new("UICorner", label).CornerRadius = UDim.new(0, 12)

print("🔵 POPUP V35.2 AFFICHÉE!")

task.delay(10, function()
	popup:Destroy()
	print("🔵 Popup supprimée")
end)
