-- =============================================================================
-- INVISIBLE CONTROLLER - VERSION 5.1 (STABLE & BUG FIXED)
-- =============================================================================
local SCRIPT_VERSION = "v5.1"
print("=========================================")
print("Invisible Controller " .. SCRIPT_VERSION .. " successfully executed!")
print("Fixing: Head/HRP nil member & Parent locked error.")
print("=========================================")

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- State Management
local invisRunning = false
local originalChar = nil
local invisibleChar = nil
local steppedConn = nil
local deathConn = nil

-- Fungsi Respawn/OFF
local function Respawn()
	if not invisRunning then return end
	invisRunning = false
	
	if steppedConn then steppedConn:Disconnect(); steppedConn = nil end
	if deathConn   then deathConn:Disconnect(); deathConn = nil end

	if originalChar then
		player.Character = originalChar
		pcall(function()
			originalChar.Parent = workspace
		end)
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

-- Fungsi Mengaktifkan Invisible (ON)
local function toggleInvisibility()
	if invisRunning then return end

	-- Pastikan karakter dasar ada
	originalChar = player.Character
	if not originalChar or not originalChar:FindFirstChild("HumanoidRootPart") or not originalChar:FindFirstChild("Head") then
		warn("[Invisible System]: Karakter asli belum siap sepenuhnya.")
		return
	end
	
	invisRunning = true
	originalChar.Archivable = true

	-- 1. Kloning Karakter dengan Nama Sementara (Mencegah error 'member of Model ""')
	invisibleChar = originalChar:Clone()
	invisibleChar.Name = "InvisCloneTemp"
	invisibleChar.Parent = Lighting

	-- Tunggu part vital pada clone siap
	local fakeHRP = invisibleChar:WaitForChild("HumanoidRootPart", 5)
	local fakeHead = invisibleChar:WaitForChild("Head", 5)
	local fakeHum = invisibleChar:FindFirstChildWhichIsA("Humanoid")

	if not fakeHRP or not fakeHead or not fakeHum then
		warn("[Invisible System]: Gagal memuat struktur objek kloning.")
		Respawn()
		return
	end

	-- Buat part tubuh menjadi transparan (0.5), RootPart tetap (1)
	for _, part in ipairs(invisibleChar:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Transparency = (part.Name == "HumanoidRootPart") and 1 or 0.5
		end
	end

	-- 2. Setup Deteksi Void & Kematian
	local voidY = workspace.FallenPartsDestroyHeight
	steppedConn = RunService.Stepped:Connect(function()
		if not invisRunning or not player.Character then return end
		local hrp = player.Character:FindFirstChild("HumanoidRootPart")
		if hrp and hrp.Position.Y <= voidY then 
			Respawn() 
		end
	end)

	deathConn = fakeHum.Died:Connect(Respawn)

	-- 3. Trik Desync Instan & Switch Player Subject
	local hrpCF = originalChar.HumanoidRootPart.CFrame
	originalChar:MoveTo(Vector3.new(0, math.pi*1e6, 0)) 
	
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	task.wait(0.2)
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom

	-- Amankan reparenting menggunakan pcall untuk mencegah error locked parent
	pcall(function()
		invisibleChar.Parent = workspace
	end)
	fakeHRP.CFrame = hrpCF
	player.Character = invisibleChar

	-- Jalankan ulang script animasi bawaan
	for _, a in ipairs(player.Character:GetDescendants()) do
		if a.Name == "Animate" and a:IsA("Model") then
			a.Disabled = true; a.Disabled = false
		end
	end
	
	-- 4. Kamera Fix & Re-Bind
	pcall(function() workspace.CurrentCamera:Destroy() end)
	task.wait(0.1)
	repeat task.wait() until player.Character ~= nil
	
	-- Pasang properti kamera kustom
	local currentCam = workspace.CurrentCamera
	currentCam.CameraSubject = player.Character:FindFirstChildWhichIsA('Humanoid')
	currentCam.CameraType = Enum.CameraType.Custom
	
	player.CameraMinZoomDistance = 0.5
	player.CameraMaxZoomDistance = 400
	player.CameraMode = Enum.CameraMode.Classic
	
	-- Amankan properti physics pasca init
	pcall(function()
		fakeHead.Anchored = false
		if player.Character:FindFirstChild("Animate") then
			player.Character.Animate.Enabled = false
			player.Character.Animate.Enabled = true
		end
	end)

	-- Kosongkan nama model di akhir agar server desync mengenalnya sebagai model tanpa nama
	invisibleChar.Name = ""
	
	if fakeHum then
		fakeHum:ChangeState(Enum.HumanoidStateType.Running)
	end
	
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
title.TextColor3 = Color3.fromRGB(255,
