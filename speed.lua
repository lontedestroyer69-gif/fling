local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- KONFIGURASI AWAL
local BOOST_POWER = 1.25 
local SPEED_STEP = 0.05 -- Jumlah kenaikan/penurunan setiap kali tombol ditekan
local MAX_SPEED = 3.0   -- Batas maksimum kecepatan agar tidak terlalu sering crash/glitch
local MIN_SPEED = 0.1   -- Batas minimum kecepatan

-- KONFIGURASI TOMBOL (KEYBINDS)
local INCREASE_KEY = Enum.KeyCode.RightBracket -- Tombol " ] " untuk menambah kecepatan
local DECREASE_KEY = Enum.KeyCode.LeftBracket  -- Tombol " [ " untuk mengurangi kecepatan

local isSpeedEnabled = false

-- 1. MEMBUAT GUI SECARA OTOMATIS
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BypassSpeedGui"

local success, err = pcall(function()
    screenGui.Parent = CoreGui
end)
if not success then
    screenGui.Parent = player:WaitForChild("PlayerGui")
end

-- 2. MEMBUAT TOMBOL GUI
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 180, 0, 50)
button.Position = UDim2.new(0.05, 0, 0.4, 0) -- Di sebelah kiri layar
button.TextSize = 16
button.Font = Enum.Font.SourceSansBold
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Parent = screenGui

-- Fungsi update teks dan warna tombol
local function updateButtonDisplay()
    -- Membulatkan angka desimal agar tampilan GUI tetap rapi (misal: 1.25)
    local formattedSpeed = string.format("%.2f", BOOST_POWER)
    
    if isSpeedEnabled then
        button.Text = "CFrame Speed: ON\n(Speed: " .. formattedSpeed .. ")"
        button.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Hijau
    else
        button.Text = "CFrame Speed: OFF\n(Speed: " .. formattedSpeed .. ")"
        button.BackgroundColor3 = Color3.fromRGB(231, 76, 60) -- Merah
    end
end

updateButtonDisplay()

-- Deteksi klik tombol GUI untuk On/Off
button.MouseButton1Click:Connect(function()
    isSpeedEnabled = not isSpeedEnabled
    updateButtonDisplay()
end)

-- 3. DETEKSI TOMBOL KEYBOARD UNTUK MENGATUR SPEED
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- Jika pemain sedang mengetik di chat, abaikan input agar tidak sengaja terganti
    if gameProcessed then return end
    
    -- Tombol untuk MENAMBAH kecepatan
    if input.KeyCode == INCREASE_KEY then
        if BOOST_POWER < MAX_SPEED then
            BOOST_POWER = BOOST_POWER + SPEED_STEP
            updateButtonDisplay()
        end
    -- Tombol untuk MENGURANGI kecepatan
    elseif input.KeyCode == DECREASE_KEY then
        if BOOST_POWER > MIN_SPEED then
            BOOST_POWER = BOOST_POWER - SPEED_STEP
            updateButtonDisplay()
        end
    end
end)

-- 4. LOOP PROSES BYPASS CFrame
task.spawn(function()
    while task.wait() do -- Loop secepat mungkin mengikuti frame game
        if isSpeedEnabled then
            local character = player.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            
            -- Hanya mendorong jika kamu sedang menekan tombol WASD / Analog (MoveDirection > 0)
            if rootPart and humanoid and humanoid.MoveDirection.Magnitude > 0 then
                -- Memindahkan koordinat karakter sedikit demi sedikit ke depan secara instan
                rootPart.CFrame = rootPart.CFrame + (humanoid.MoveDirection * BOOST_POWER)
            end
        end
    end
end)
