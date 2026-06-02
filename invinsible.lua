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

-- Properti posisi asli untuk restore
local originalCFrame = nil

-- Fungsi membersihkan koneksi & clone
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
        -- Kembalikan karakter asli ke posisi karakter palsu terakhir saat OFF ditekan
        local currentCF = camera.Focus
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            currentCF = player.Character.HumanoidRootPart.CFrame
        end

        player.Character = originalChar
        originalChar.Parent = workspace
        
        local hrp = originalChar:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = currentCF end

        local hum = originalChar:FindFirstChildWhichIsA("Humanoid")
        if hum then camera.CameraSubject = hum end
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
    invisibleChar.Name = "InvisPlayer"
    
    for _, part in ipairs(invisibleChar:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = (part.Name == "HumanoidRootPart") and 1 or 0.5
        end
    end

    -- 2. Sistem Reset otomatis jika mati/void saat mode ON
    local function autoRespawn()
        if not isInvis then return end
        isInvis = false
        cleanup()
        player.Character = originalChar
        originalChar.Parent = workspace
        local hum = originalChar:FindFirstChildWhichIsA("Humanoid")
        if hum then hum:Destroy() end -- Memicu respawn normal game
    end

    local voidY = workspace.FallenPartsDestroyHeight
    steppedConn = RunService.Stepped:Connect(function()
        if not isInvis or not player.Character then return end
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp and hrp.Position.Y <= voidY then autoRespawn() end
    end)

    local fakeHum = invisibleChar:FindFirstChildWhichIsA("Humanoid")
    if fakeHum then deathConn = fakeHum.Died:Connect(autoRespawn) end

    -- 3. Eksekusi Desync & Switch Character
    originalChar:MoveTo(Vector3.new(0, math.pi * 1e6, 0))
    
    camera.CameraType = Enum.CameraType.Scriptable
    task.wait(0.1)
    camera.CameraType = Enum.CameraType.Custom

    invisibleChar.Parent = workspace
    invisibleChar.HumanoidRootPart.CFrame = originalCFrame
    player.Character = invisibleChar

    -- Refresh Animasi
    for _, anim in ipairs(invisibleChar:GetDescendants()) do
        if anim.Name == "Animate" and anim:IsA("LocalScript") then
            anim.Disabled = true; anim.Disabled = false
        end
    end

    camera.CameraSubject = fakeHum
    print("Invisible: ON")
end

-- =============================================================================
-- PEMBUATAN GUI (UI MANAGER)
-- =============================================================================

-- Hapus GUI lama jika ada duplikasi script
local oldGui = CoreGui:FindFirstChild("InvisGui") or player.PlayerGui:FindFirstChild("InvisGui")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InvisGui"
-- Coba inject ke CoreGui (agar tidak hilang saat reset), jika fail pakai PlayerGui
local success, _ = pcall(function() screenGui.Parent = CoreGui end)
if not success then screenGui.Parent = player:WaitForChild("PlayerGui") end

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 150, 0, 60)
mainFrame.Position = UDim2.new(0.05, 0, 0.4, 0) -- Di sebelah kiri tengah layar
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(150, 0, 0)
mainFrame.Active = true
mainFrame.Draggable = true -- Membuat GUI bisa digeser di layar
mainFrame.Parent = screenGui

-- Title Label
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0.4, 0)
title.BackgroundTransparency = 1
title.Text = "INVISIBLE CONTROLLER"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 12
title.Parent = mainFrame

-- Toggle Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0.5, 0)
toggleBtn.Position = UDim2.new(0.05, 0, 0.45, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0) -- Merah (OFF)
toggleBtn.Text = "STATUS: OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 14
toggleBtn.Parent = mainFrame

-- Logika Klik Tombol
toggleBtn.MouseButton1Click:Connect(function()
    if not isInvis then
        turnOn()
        if isInvis then -- Pastikan berhasil ON
            toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0) -- Hijau
            toggleBtn.Text = "STATUS: ON"
        end
    else
        turnOff()
        toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0) -- Merah
        toggleBtn.Text = "STATUS: OFF"
    end
end)

-- Hubungkan fungsi clean up jika player keluar map
player.CharacterRemoving:Connect(function(char)
    if char == originalChar then
        cleanup()
        isInvis = false
        toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        toggleBtn.Text = "STATUS: OFF"
    end
end)
