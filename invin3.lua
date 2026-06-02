-- =============================================================================
-- INVISIBLE CONTROLLER - VERSION 5.3 (FIXED COMPLETION)
-- =============================================================================
local SCRIPT_VERSION = "v5.3"
print("=========================================")
print("Invisible Controller " .. SCRIPT_VERSION .. " successfully executed!")
print("Logika 100% menggunakan script awal milikmu.")
print("=========================================")

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- State Management (Variabel asli dari potongan kodemu)
local invisRunning = false
local originalChar = nil
local invisibleChar = nil
local steppedConn = nil
local deathConn = nil

-- Fungsi Respawn/OFF (Mengikuti persis logika aslimu)
local function Respawn()
	if not invisRunning then return end
	invisRunning = false
	
	if steppedConn then steppedConn:Disconnect(); steppedConn = nil end
	if deathConn   then deathConn:Disconnect(); deathConn = nil end

	if originalChar and originalChar.Parent then
		player.Character = originalChar
		pcall(function() originalChar.Parent = workspace end)
		local clonedHum = originalChar:FindFirstChildWhichIsA("Humanoid")
		if clonedHum then 
			pcall(function() clonedHum:Destroy() end) 
		end
	end
	if invisibleChar then 
		pcall(function() invisibleChar:Destroy() end)
		invisibleChar = nil 
	end
	print("[Invisible System]: Status turned OFF")
end

-- Fungsi Mengaktifkan Invisible (Mengikuti persis logika aslimu)
local function toggleInvisibility()
	if invisRunning then return end
	invisRunning = true

	-- Ambil karakter asli
	repeat task.wait(0.1) until player.Character
	originalChar = player.Character
	originalChar.Archivable = true

	-- 1. Kloning Model
	invisibleChar = originalChar:Clone()
	invisibleChar.Name   = "InvisPlayer" -- Nama sementara agar part-nya tidak error saat diakses game
	invisibleChar.Parent = Lighting

	-- Set transparansi part tubuh (Di layarmu transparan 0.5, di server invisible total)
	for _, part in ipairs(invisibleChar:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Transparency = (part.Name == "HumanoidRootPart") and 1 or 0.5
		end
	end

	-- 2. Setup Handler Kematian & Void
	local voidY = workspace.FallenPartsDestroyHeight
	steppedConn = RunService.Stepped:Connect(function()
		local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		local y = hrp.Position.Y
		if (voidY < 0 and y <= voidY) or (voidY >= 0 and y >= voidY) then
			Respawn()
		end
	end)

	local clonedHum = invisibleChar:FindFirstChildWhichIsA("Humanoid")
	if clonedHum then
		deathConn = clonedHum.Died:Connect(Respawn)
	end

	-- 3. Eksekusi Desync & Tukar Subjek Karakter
	local hrpCF = originalChar.HumanoidRootPart.CFrame
	originalChar:MoveTo(Vector3.new(0, math.pi*1e6, 0)) -- Buang karakter asli ke atas langit
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	task.wait(0.2)
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom

	pcall(function() invisibleChar.Parent = workspace end)
	invisibleChar.HumanoidRootPart.CFrame = hrpCF
	player.Character = invisibleChar

	-- Refresh script animasi bawaan roblox
	for _, a in ipairs(player.Character:GetDescendants()) do
		if a.Name == "Animate" and a:IsA("Model") then
			a.Disabled = true; a.Disabled = false
		end
	end
	
	-- 4. Trik Reset Kamera (Kunci bypass agar karakter kloningan bisa jalan)
	pcall(function() workspace.CurrentCamera:Destroy() end)
	task.wait(.1)
	repeat task.wait() until player.Character ~= nil
	
	workspace.CurrentCamera.CameraSubject = player.Character:FindFirstChildWhichIsA('Humanoid')
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	player.CameraMinZoomDistance = 0.5
	player.CameraMaxZoomDistance = 400
	player.CameraMode = Enum.CameraMode.Classic
	player.Character.Head.Anchored = false
	player.Character.Animate.Enabled = false
	player.Character.Animate.Enabled = true

	-- Kosongkan nama model di akhir agar server desync mengenalnya sebagai model tanpa nama
	invisibleChar.Name = ""
	print("[Invisible System]: Status turned ON")
end

-- =============================================================================
-- PEMBUATAN GUI (UI CONTROLLER)
-- =============================================================================
local oldGui = CoreGui:FindFirstChild("InvisGui") or player.PlayerGui:FindFirstChild("InvisGui")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InvisGui"
screenGui.ResetOnSpawn = false 

local success, _ = pcall(function() screenGui.Parent = CoreGui end)
if not success then screenGui.Parent = player:WaitForChild("PlayerGui") end

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 160, 0, 65)
mainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(150, 0, 0)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0.4, 0)
title.BackgroundTransparency = 1
title.Text = "INVIS CONTROLLER " .. SCRIPT_VERSION
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 11
title.Parent = mainFrame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0.5, 0)
toggleBtn.Position = UDim2.new(0.05, 0, 0.45, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
toggleBtn.Text = "STATUS: OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 14
toggleBtn.Parent = mainFrame

toggleBtn.MouseButton1Click:Connect(function()
	if not invisRunning then
		toggleInvisibility()
		if invisRunning then
			toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
			toggleBtn.Text = "STATUS: ON"
		end
	else
		Respawn()
		if not invisRunning then
			toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
			toggleBtn.Text = "STATUS: OFF"
		end
	end
end)

-- Reset state otomatis jika karakter asli dihapus dari luar system
player.CharacterRemoving:Connect(function(char)
	if char == originalChar then
		if steppedConn then steppedConn:Disconnect(); steppedConn = nil end
		if deathConn   then deathConn:Disconnect(); deathConn = nil end
		if invisibleChar then pcall(function() invisibleChar:Destroy() end); invisibleChar = nil end
		invisRunning = false
		toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
		toggleBtn.Text = "STATUS: OFF"
	end
end)
