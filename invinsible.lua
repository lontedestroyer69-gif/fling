-- =============================================================================
-- INVISIBLE CONTROLLER - VERSION 4.0 (STABLE)
-- =============================================================================
local SCRIPT_VERSION = "v4.0"
print("=========================================")
print("Invisible Controller " .. SCRIPT_VERSION .. " successfully executed!")
print("Created by: AI Assistant")
print("=========================================")

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- State Management
local isInvis = false
local originalChar = nil
local invisibleChar = nil
local steppedConn = nil
local deathConn = nil
local originalCFrame = nil

-- Fungsi membersihkan koneksi & objek palsu
local function cleanup()
    if steppedConn then steppedConn:Disconnect(); steppedConn = nil end
    if deathConn then deathConn:Disconnect(); deathConn = nil end
    if invisibleChar then invisibleChar:Destroy(); invisibleChar = nil end
end

-- Fungsi Mematikan Invisible (OFF)
local function turnOff()
    if not isInvis then return end
    isInvis = false
    cleanup()

    if originalChar and originalChar.Parent then
        -- Ambil posisi terakhir dari karakter palsu sebelum dimatikan
        local currentCF = workspace.CurrentCamera.CFrame
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            currentCF = player.Character.HumanoidRootPart.CFrame
        end

        -- Kembalikan Karakter Asli
        player.Character = originalChar
        originalChar.Parent = workspace
        
        local hrp = originalChar:WaitForChild("HumanoidRootPart", 5)
        if hrp then 
            hrp.Anchored = false
            hrp.CFrame = currentCF 
        end

        -- Paksa Reset Kamera dengan menghancurkannya agar mengikat kembali ke karakter asli
        pcall(function() workspace.CurrentCamera:Destroy() end)
        task.wait(0.1)
        
        repeat task.wait() until player.Character == originalChar and workspace.CurrentCamera
        
        local hum = originalChar:FindFirstChildWhichIsA("Humanoid")
        if hum then 
            workspace.CurrentCamera.CameraSubject = hum
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end
    print("[Invisible System]: Status turned OFF")
end

-- Fungsi Mengaktifkan Invisible (ON)
local function turnOn()
    if isInvis then return end
    
    -- PERBAIKAN: Memastikan karakter benar-benar siap dan menunggu jika belum ada
    originalChar = player.Character or player.CharacterAdded:Wait()
    local hrpCheck = originalChar:WaitForChild("HumanoidRootPart", 5)
    
    if not originalChar or not hrpCheck then 
        warn("[Invisible System]: Karakter asli belum siap sepenuhnya di Workspace! Silakan coba lagi dalam beberapa detik.")
        return 
    end
    
    isInvis = true
    originalChar.Archivable = true
    originalCFrame = hrpCheck.CFrame

    -- 1. Kloning Karakter
    invisibleChar = originalChar:Clone()
    invisibleChar.Name = "InvisPlayer"
    
    for _, part in ipairs(invisibleChar:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = false
            part.Transparency = (part.Name == "HumanoidRootPart") and 1 or 0.5
        end
    end

    -- 2. Handler Auto-Respawn jika mati atau jatuh ke Void saat ON
    local function autoRespawn()
        if not isInvis then return end
        isInvis = false
        cleanup()
        player.Character = originalChar
        originalChar.Parent = workspace
        local hum = originalChar:FindFirstChildWhichIsA("Humanoid")
        if hum then hum:Destroy() end -- Memicu respawn bawaan game
    end

    local voidY = workspace.FallenPartsDestroyHeight
    steppedConn = RunService.Stepped:Connect(function()
        if not isInvis or not player.Character then return end
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp and hrp.Position.Y <= voidY then autoRespawn() end
    end)

    local fakeHum = invisibleChar:FindFirstChildWhichIsA("Humanoid")
    if fakeHum then deathConn = fakeHum.Died:Connect(autoRespawn) end

    -- 3. Singkronisasi & Pemindahan Karakter Asli (Desync)
    originalChar:MoveTo(Vector3.new(0, math.pi * 1e6, 0))
    
    -- Hancurkan Kamera untuk Reset CoreScripts Kontroler Roblox
    pcall(function() workspace.CurrentCamera:Destroy() end)
    task.wait(0.1)

    -- Masukkan clone ke workspace dan set posisi awal
    invisibleChar.Parent = workspace
    invisibleChar.HumanoidRootPart.CFrame = originalCFrame
    
    -- Alihkan Karakter Utama Player ke Model Clone
    player.Character = invisibleChar

    -- Tunggu sampai karakter teregistrasi oleh engine
    repeat task.wait() until player.Character == invisibleChar and workspace.CurrentCamera

    -- 4. Pengikatan Ulang Kamera dan Kontrol Input ke Karakter Baru
    workspace.CurrentCamera.CameraSubject = fakeHum
    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    
    player.CameraMinZoomDistance = 0.5
    player.CameraMaxZoomDistance = 400
    player.CameraMode = Enum.CameraMode.Classic

    -- Jalankan kembali script animasi bawaan pada clone
    for _, anim in ipairs(invisibleChar:GetDescendants()) do
        if anim.Name == "Animate" and anim:IsA("LocalScript") then
            anim.Disabled = true; anim.Disabled = false
        end
    end

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
    if not isInvis then
        turnOn()
        if isInvis then
            toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            toggleBtn.Text = "STATUS: ON"
        end
    else
        turnOff()
        if not isInvis then
            toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
            toggleBtn.Text = "STATUS: OFF"
        end
    end
end)

-- Reset state jika dari menu roblox player sengaja memilih 'Reset Character'
player.CharacterRemoving:Connect(function(char)
    if char == originalChar then
        cleanup()
        isInvis = false
        toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        toggleBtn.Text = "STATUS: OFF"
    end
end)
