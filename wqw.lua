local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- ================== KONFIGURASI ==================
local BOOST_POWER = 1.8
local SPEED_STEP = 0.1
local MAX_SPEED = 4.0
local MIN_SPEED = 0.5

local isSpeedEnabled = false

-- ================== GUI ==================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CFrameSpeedGUI"
screenGui.ResetOnSpawn = false

pcall(function()
    screenGui.Parent = game:GetService("CoreGui")
end)
if not screenGui.Parent then
    screenGui.Parent = player:WaitForChild("PlayerGui")
end

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 200, 0, 60)
button.Position = UDim2.new(0.05, 0, 0.35, 0)
button.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 15
button.Font = Enum.Font.SourceSansBold
button.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = button

local function updateButton()
    local speedText = string.format("%.1f", BOOST_POWER)
    if isSpeedEnabled then
        button.Text = "CFrame Speed: ON\nSpeed: " .. speedText
        button.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    else
        button.Text = "CFrame Speed: OFF\nSpeed: " .. speedText
        button.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
    end
end
updateButton()

-- ================== KEYBINDS ==================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.RightBracket then      -- ]  = Tambah Speed
        if BOOST_POWER < MAX_SPEED then
            BOOST_POWER = BOOST_POWER + SPEED_STEP
            updateButton()
        end
    elseif input.KeyCode == Enum.KeyCode.LeftBracket then   -- [  = Kurangi Speed
        if BOOST_POWER > MIN_SPEED then
            BOOST_POWER = BOOST_POWER - SPEED_STEP
            updateButton()
        end
    end
end)

-- ================== TOGGLE GUI ==================
button.MouseButton1Click:Connect(function()
    isSpeedEnabled = not isSpeedEnabled
    updateButton()
end)

-- ================== MAIN LOOP (HEARTBEAT) ==================
RunService.Heartbeat:Connect(function()
    if not isSpeedEnabled then return end

    local character = player.Character
    if not character then return end

    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    if not root or not humanoid then return end
    if humanoid.Health <= 0 then return end

    -- Hanya jalan kalau sedang bergerak
    if humanoid.MoveDirection.Magnitude > 0 then
        local moveDir = humanoid.MoveDirection
        local camera = workspace.CurrentCamera
        
        -- Mengambil arah kamera (lebih natural)
        local cameraLook = camera.CFrame.LookVector
        cameraLook = Vector3.new(cameraLook.X, 0, cameraLook.Z).Unit
        
        -- Kombinasi antara MoveDirection dan arah kamera
        local boostVector = (moveDir * 0.6 + cameraLook * 0.4) * BOOST_POWER * 0.8
        
        root.CFrame = root.CFrame + boostVector
    end
end)

print("✅ CFrame Speed Improved telah di-load! Tekan [ ] untuk ubah speed")
