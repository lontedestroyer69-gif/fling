-- =============================================================================
-- INVISIBLE CONTROLLER - VERSION 5.0 (100% MATCH ORIGINAL LOGIC)
-- =============================================================================
local SCRIPT_VERSION = "v5.0"
print("=========================================")
print("Invisible Controller " .. SCRIPT_VERSION .. " successfully executed!")
print("Logika 100% disesuaikan dengan script awal.")
print("=========================================")

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- State Management (Sesuai variabel script asli)
local invisRunning = false
local originalChar = nil
local invisibleChar = nil
local steppedConn = nil
local deathConn = nil

-- Fungsi Respawn/OFF (Salinan persis dari logika script asli)
local function Respawn()
    if not invisRunning then return end
    invisRunning = false
    
    if steppedConn then steppedConn:Disconnect(); steppedConn = nil end
    if deathConn   then deathConn:Disconnect(); deathConn = nil end

    if originalChar then
        player.Character = originalChar
        originalChar.Parent = workspace
        local clonedHum = originalChar:FindFirstChildWhichIsA("Humanoid")
        if clonedHum then clonedHum:Destroy() end
    end
    if invisibleChar then invisibleChar.Parent = nil; invisibleChar = nil end
    print("[Invisible System]: Status turned OFF")
end

-- Fungsi Mengaktifkan Invisible (ON)
local function toggleInvisibility()
    if invisRunning then return end
    invisRunning = true

    -- Tunggu karakter sampai siap
    repeat task.wait(0.1) until player.Character
    originalChar = player.Character
    originalChar.Archivable = true

    -- 1. Kloning Karakter (Karakter Transparan di Layarmu, Invisible di Server)
    invisibleChar = originalChar:Clone()
    invisibleChar.Name   = ""
    invisibleChar.Parent = Lighting

    for _, part in ipairs(invisibleChar:GetDescendants()) do
        if part:IsA("BasePart") then
            -- RootPart tetap 1 (transparan penuh), part tubuh lain 0.5 (setengah transparan)
            part.Transparency = (part.Name == "HumanoidRootPart") and 1 or 0.5
        end
    end

    -- 2. Setup Deteksi Void & Kematian (Urutan script asli)
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

    -- 3. Trik Desync Instan & Switch Player Subject (Copied from your script)
    local hrpCF = originalChar.HumanoidRootPart.CFrame
    originalChar:MoveTo(Vector3.new(0, math.pi*1e6, 0)) -- Kirim ke atas sesaat untuk desync server
    workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
    task.wait(0.2)
    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom

    invisibleChar.Parent = workspace
    invisibleChar.HumanoidRootPart.CFrame = hrpCF
    player.Character = invisibleChar

    -- Mengaktifkan ulang script animasi bawaan game
    for _, a in ipairs(player.Character:GetDescendants()) do
        if a.Name == "Animate" and a:IsA("Model") then
            a.Disabled = true; a.Disabled = false
        end
    end
    
    -- 4. Kamera Fix & Re-Bind (Mengikuti bypass script aslimu)
    pcall(function() workspace.CurrentCamera:Destroy() end)
    task.wait(.1)
    repeat task.wait() until player.Character ~= nil
    
    workspace.CurrentCamera.CameraSubject = player.Character:FindFirstChildWhichIsA('Humanoid')
    workspace.CurrentCamera.CameraType = "Custom"
    player.CameraMinZoomDistance = 0.5
    player.CameraMaxZoomDistance = 400
    player.CameraMode = "Classic"
    player.Character.Head.Anchored = false
    player.Character.Animate.Enabled = false
    player.Character.Animate.Enabled = true
    
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

-- Reset state otomatis jika mati normal karena game
player.CharacterRemoving:Connect(function(char)
    if char == originalChar then
        if steppedConn then steppedConn:Disconnect(); steppedConn = nil end
        if deathConn   then deathConn:Disconnect(); deathConn = nil end
        if invisibleChar then invisibleChar:Destroy(); invisibleChar = nil end
        invisRunning = false
        toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        toggleBtn.Text = "STATUS: OFF"
    end
end)
