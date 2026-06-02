-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- State Management
local isInvis = false
local originalChar = nil
local invisibleChar = nil
local steppedConn = nil
local deathConn = nil
local originalCFrame = nil

-- Fungsi bersihkan koneksi
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
        local currentCF = camera.Focus
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            currentCF = player.Character.HumanoidRootPart.CFrame
        end

        player.Character = originalChar
        originalChar.Parent = workspace
        
        local hrp = originalChar:FindFirstChild("HumanoidRootPart")
        if hrp then 
            hrp.Anchored = false
            hrp.CFrame = currentCF 
        end

        local hum = originalChar:FindFirstChildWhichIsA("Humanoid")
        if hum then 
            camera.CameraSubject = hum 
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end
    print("Invisible: OFF")
end

-- Fungsi Mengaktifkan Invisible (ON)
local function turnOn()
    if isInvis then return end
    
    originalChar = player.Character
    if not originalChar or not originalChar:FindFirstChild("HumanoidRootPart") then 
        warn("Karakter belum siap.")
        return 
    end
    
    isInvis = true
    originalChar.Archivable = true
    originalCFrame = originalChar.HumanoidRootPart.CFrame

    -- 1. Clone Karakter
    invisibleChar = originalChar:Clone()
    invisibleChar.Name = "InvisPlayer_" .. player.Name
    
    -- PERBAIKAN FISIK: Pastikan TIDAK ADA part yang terkunci (Anchored) agar bisa jalan
    for _, part in ipairs(invisibleChar:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = false
            part.CanCollide = (part.Name == "HumanoidRootPart") and false or true
            part.Transparency = (part.Name == "HumanoidRootPart") and 1 or 0.5
        end
    end

    -- 2. Sistem Reset Otomatis
    local function autoRespawn()
        if not isInvis then return end
        isInvis = false
        cleanup()
        player.Character = originalChar
        originalChar.Parent = workspace
        local hum = originalChar:FindFirstChildWhichIsA("Humanoid")
        if hum then hum:Destroy() end
    end

    local voidY = workspace.FallenPartsDestroyHeight
    steppedConn = RunService.Stepped:Connect(function()
        if not isInvis or not player.Character then return end
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp and hrp.Position.Y <= voidY then autoRespawn() end
    end)

    local fakeHum = invisibleChar:FindFirstChildWhichIsA("Humanoid")
    if fakeHum then deathConn = fakeHum.Died:Connect(autoRespawn) end

    -- 3. Eksekusi Desync (Pindahkan Karakter Asli ke Atas)
    originalChar:MoveTo(Vector3.new(0, math.pi * 1e6, 0))
    
    camera.CameraType = Enum.CameraType.Scriptable
    task.wait(0.1)
    camera.CameraType = Enum.CameraType.Custom

    -- Masukkan clone ke workspace
    invisibleChar.Parent = workspace
    invisibleChar.HumanoidRootPart.CFrame = originalCFrame
    
    -- Ganti subjek Karakter Player utama ke Clone
    player.Character = invisibleChar

    -- PERBAIKAN KONTROL: Refresh state humanoid clone agar mengenali input keyboard
    if fakeHum then
        fakeHum:ChangeState(Enum.HumanoidStateType.GettingUp)
        task.wait(0.05)
        fakeHum:ChangeState(Enum.HumanoidStateType.Running)
    end

    -- Refresh Animasi & Script Kontrol
    for _, anim in ipairs(invisibleChar:GetDescendants()) do
        if anim.Name == "Animate" and anim:IsA("LocalScript") then
            anim.Disabled = true; anim.Disabled = false
        end
    end

    -- Re-bind Kamera
    camera.CameraSubject = fakeHum
    camera.CameraType = Enum.CameraType.Custom
    
    -- Paksa core script kontrol Roblox untuk mengenali karakter baru
    pcall(function()
        local PlayerScripts = player:WaitForChild("PlayerScripts")
        local PlayerModule = require(PlayerScripts:WaitForChild("PlayerModule"))
        local Controls = PlayerModule:GetControls()
        Controls:Enable(true)
    end)

    print("Invisible: ON (Fixed Movement)")
end

-- =============================================================================
-- PEMBUATAN GUI
-- =============================================================================
local oldGui = CoreGui:FindFirstChild("InvisGui") or player.PlayerGui:FindFirstChild("InvisGui")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InvisGui"
local success, _ = pcall(function() screenGui.Parent = CoreGui end)
if not success then screenGui.Parent = player:WaitForChild("PlayerGui") end

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 150, 0, 60)
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
title.Text = "INVIS CONTROLLER v2"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 12
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
        toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        toggleBtn.Text = "STATUS: OFF"
    end
end)

player.CharacterRemoving:Connect(function(char)
    if char == originalChar then
        cleanup()
        isInvis = false
        toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        toggleBtn.Text = "STATUS: OFF"
    end
end)
