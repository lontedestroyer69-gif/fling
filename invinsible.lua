-- =============================================================================
-- INVISIBLE CONTROLLER - VERSION 5.8 (FIXED RESPAWN & RESTORE)
-- =============================================================================
local SCRIPT_VERSION = "v5.8"
print("=========================================")
print("Invisible Controller " .. SCRIPT_VERSION .. " successfully executed!")
print("=========================================")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

local function Notify(text, title, duration)
    print("[" .. tostring(title or "Notice") .. "]: " .. tostring(text))
end

local globalRespawn = nil
local invisRunning = false

-- =============================================================================
-- FUNGSI UTAMA
-- =============================================================================
local function toggleInvisibility()
    if invisRunning then return end
    invisRunning = true

    repeat task.wait(0.1) until player.Character
    local originalChar = player.Character
    originalChar.Archivable = true

    -- Simpan CFrame sebelum semua perubahan
    local hrpCF = originalChar.HumanoidRootPart.CFrame

    -- Clone karakter untuk dijadikan "dummy invisible"
    local invisibleChar = originalChar:Clone()
    invisibleChar.Name = ""
    invisibleChar.Parent = Lighting

    -- Sembunyikan semua part di clone
    for _, part in ipairs(invisibleChar:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
        end
    end

    local voidConn, deathConn, steppedConn
    local hasRespawned = false -- FLAG anti double-call

    local function Respawn()
        -- Cegah dipanggil lebih dari sekali
        if hasRespawned then return end
        hasRespawned = true
        invisRunning = false

        -- Putus semua koneksi dulu
        if steppedConn then steppedConn:Disconnect() end
        if deathConn   then deathConn:Disconnect()   end
        globalRespawn = nil

        -- Pindahkan originalChar kembali ke workspace
        originalChar.Parent = workspace

        -- JANGAN hapus Humanoid! Cukup reset state-nya
        local hum = originalChar:FindFirstChildWhichIsA("Humanoid")
        if hum then
            hum.Health = hum.MaxHealth -- Pastikan tidak mati
        end

        -- Set ulang karakter ke originalChar
        player.Character = originalChar

        -- Teleport ke posisi terakhir
        local hrp = originalChar:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = invisibleChar.HumanoidRootPart.CFrame -- Ikuti posisi invisible char
        end

        -- Bersihkan invisible char
        invisibleChar:Destroy()

        -- Reset kamera
        task.wait(0.1)
        local newHum = originalChar:FindFirstChildWhichIsA("Humanoid")
        if newHum and workspace.CurrentCamera then
            workspace.CurrentCamera.CameraSubject = newHum
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        end

        -- Re-enable animasi
        local animate = originalChar:FindFirstChild("Animate")
        if animate then
            animate.Enabled = false
            task.wait(0.05)
            animate.Enabled = true
        end

        player.CameraMinZoomDistance = 0.5
        player.CameraMaxZoomDistance = 400
        player.CameraMode = "Classic"

        local head = originalChar:FindFirstChild("Head")
        if head then head.Anchored = false end

        Notify("You are now visible again!", "System", 3)
        print("[Invisible System]: Character safely restored.")
    end

    globalRespawn = Respawn

    -- Deteksi void
    local voidY = workspace.FallenPartsDestroyHeight
    steppedConn = RunService.Stepped:Connect(function()
        -- Cek posisi invisible char (yang jadi karakter aktif)
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local y = hrp.Position.Y
        if (voidY < 0 and y <= voidY) or (voidY >= 0 and y >= voidY) then
            Respawn()
        end
    end)

    -- Deteksi kematian dari invisible char
    local clonedHum = invisibleChar:FindFirstChildWhichIsA("Humanoid")
    if clonedHum then
        deathConn = clonedHum.Died:Connect(Respawn)
    else
        warn("[Invisible System Warning]: Humanoid tidak ditemukan di clone.")
    end

    -- Pindahkan originalChar ke "limbo"
    originalChar:MoveTo(Vector3.new(0, math.pi * 1e6, 0))
    originalChar.Parent = Lighting -- Sembunyikan dari workspace

    task.wait(0.2)

    -- Aktifkan invisible char
    invisibleChar.Parent = workspace
    invisibleChar.HumanoidRootPart.CFrame = hrpCF
    player.Character = invisibleChar

    -- Reset kamera
    pcall(function() workspace.CurrentCamera:Destroy() end)
    task.wait(0.1)
    repeat task.wait() until player.Character ~= nil

    local activeHum = player.Character:FindFirstChildWhichIsA("Humanoid")
    if workspace.CurrentCamera then
        workspace.CurrentCamera.CameraSubject = activeHum
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    end

    player.CameraMinZoomDistance = 0.5
    player.CameraMaxZoomDistance = 400
    player.CameraMode = "Classic"

    local head = player.Character:FindFirstChild("Head")
    if head then head.Anchored = false end

    local animate = player.Character:FindFirstChild("Animate")
    if animate then
        animate.Enabled = false
        animate.Enabled = true
    end

    Notify("You are now invisible!", "System", 3)
end

-- =============================================================================
-- GUI
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
            globalRespawn()
        end
    end
end)
