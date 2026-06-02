-- =============================================================================
-- INVISIBLE CONTROLLER - VERSION 5.7
-- =============================================================================
local SCRIPT_VERSION = "v5.7"
print("=========================================")
print("Invisible Controller " .. SCRIPT_VERSION .. " successfully executed!")
print("Fixing: Crash .Died nil & Stuck pada state OFF.")
print("=========================================")

-- Services Tambahan untuk GUI
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- Fungsi Notify bawaan script asli
local function Notify(text, title, duration)
	print("[" .. tostring(title or "Notice") .. "]: " .. tostring(text))
end

-- Variabel kontroler eksternal untuk GUI
local globalRespawn = nil 
local invisRunning = false 

-- =============================================================================
-- FUNGSI ASLI MILIKMU (DIBERI PROTEKSI ANTI-CRASH)
-- =============================================================================
local function toggleInvisibility()
	if invisRunning then return end
	invisRunning = true

	local player = Players.LocalPlayer
	repeat task.wait(0.1) until player.Character
	local originalChar = player.Character
	originalChar.Archivable = true

	local invisibleChar = originalChar:Clone()
	invisibleChar.Name   = ""
	invisibleChar.Parent = Lighting

	for _, part in ipairs(invisibleChar:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Transparency = (part.Name == "HumanoidRootPart") and 1 or 0.5
		end
	end

	local voidConn, deathConn, steppedConn

	local function Respawn()
		invisRunning = false
		if steppedConn then steppedConn:Disconnect() end
		if deathConn   then deathConn:Disconnect()   end

		player.Character = originalChar
		originalChar.Parent = workspace
		local clonedHum = originalChar:FindFirstChildWhichIsA("Humanoid")
		if clonedHum then clonedHum:Destroy() end
		invisibleChar.Parent = nil
		print("[Invisible System]: Character safely restored.")
	end
	
	-- Trik agar GUI luar bisa memicu fungsi Respawn lokal ini secara aman saat OFF
	globalRespawn = Respawn

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
	-- PERBAIKAN UTAMA: Proteksi if-statement agar tidak crash 'index nil with Died'
	if clonedHum then
		deathConn = clonedHum.Died:Connect(Respawn)
	else
		warn("[Invisible System Warning]: Humanoid kloning hilang/dihapus game, mengaktifkan bypass mode.")
	end

	local hrpCF = originalChar.HumanoidRootPart.CFrame
	originalChar:MoveTo(Vector3.new(0, math.pi*1e6, 0))
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	task.wait(0.2)
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom

	invisibleChar.Parent = workspace
	invisibleChar.HumanoidRootPart.CFrame = hrpCF
	player.Character = invisibleChar

	for _, a in ipairs(player.Character:GetDescendants()) do
		if a.Name == "Animate" and a:IsA("Model") then
			a.Disabled = true; a.Disabled = false
		end
	end
	
	pcall(function() workspace.CurrentCamera:Destroy() end)
	task.wait(.1)
	repeat task.wait() until player.Character ~= nil
	
	-- Jika clonedHum di atas hilang, cari kembali subjek humanoid di dalam model baru
	local activeHum = player.Character:FindFirstChildWhichIsA('Humanoid') or clonedHum
	workspace.CurrentCamera.CameraSubject = activeHum
	workspace.CurrentCamera.CameraType = "Custom"
	player.CameraMinZoomDistance = 0.5
	player.CameraMaxZoomDistance = 400
	player.CameraMode = "Classic"
	player.Character.Head.Anchored = false
	player.Character.Animate.Enabled = false
	player.Character.Animate.Enabled = true
	Notify("You are now invisible!", "System", 3)
end

-- =============================================================================
-- PEMBUATAN GUI CONTROLLER
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

-- Sinkronisasi tombol visual via Heartbeat
RunService.Heartbeat:Connect(function()
	if invisRunning then
		toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
		toggleBtn.Text = "STATUS: ON"
	else
		toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
		toggleBtn.Text = "STATUS: OFF"
	end
end)

toggleBtn.MouseButton1Click:Connect(function()
	if not invisRunning then
		toggleInvisibility()
	else
		if globalRespawn then
			globalRespawn() -- Mematikan state lewat fungsi internal aslimu
		end
	end
end)
