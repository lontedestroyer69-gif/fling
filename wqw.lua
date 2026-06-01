local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- ==========================================
-- 1. MEMBUAT GUI (OTOMATIS MUNCUL DI LAYAR)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
-- Menggunakan CoreGui agar GUI tidak hilang saat karakter mati/respawn
ScreenGui.Name = "SafeTP_GUI"
ScreenGui.Parent = CoreGui

-- Frame Utama
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 130)
MainFrame.Position = UDim2.new(0.5, -125, 0.4, -65)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- GUI bisa digeser/drag pakai mouse
MainFrame.Parent = ScreenGui

-- Efek Sudut Melengkung Frame
local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 8)
FrameCorner.Parent = MainFrame

-- Judul GUI
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.Text = "BYPASS TELEPORT"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 16
TitleLabel.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleLabel

-- Kotak Ketik Nama (TextBox)
local NameInput = Instance.new("TextBox")
NameInput.Size = UDim2.new(0, 210, 0, 35)
NameInput.Position = UDim2.new(0.5, -105, 0, 45)
NameInput.PlaceholderText = "Ketik Nama / Singkatan..."
NameInput.Text = ""
NameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
NameInput.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
NameInput.Font = Enum.Font.SourceSans
NameInput.TextSize = 16
NameInput.Parent = MainFrame

-- Tombol Teleport
local TPButton = Instance.new("TextButton")
TPButton.Size = UDim2.new(0, 210, 0, 35)
TPButton.Position = UDim2.new(0.5, -105, 0, 85)
TPButton.Text = "TELEPORT"
TPButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TPButton.BackgroundColor3 = Color3.fromRGB(0, 150, 70)
TPButton.Font = Enum.Font.SourceSansBold
TPButton.TextSize = 16
TPButton.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 5)
ButtonCorner.Parent = TPButton


-- ==========================================
-- 2. FUNGSI TELEPORT BYPASS ADONIS
-- ==========================================
local function safeTeleport(targetCFrame)
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    rootPart.Velocity = Vector3.new(0, 0, 0)
    rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    
    local distance = (rootPart.Position - targetCFrame.Position).Magnitude
    -- Pembagi 15 agar sangat aman dari deteksi rubberband Adonis terbaru
    local duration = math.clamp(distance / 15, 0.2, 4) 
    
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.QuadIn, Enum.EasingDirection.Out)
    local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = targetCFrame})
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Physics) end
    
    tween:Play()
    tween.Completed:Wait()
    
    task.wait(0.2) -- Jeda sinkronisasi server
    
    if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Running) end
    rootPart.Velocity = Vector3.new(0, 0, 0)
    rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
end

-- Fungsi mencari pemain
local function findTarget(name)
    for _, p in pairs(Players:GetPlayers()) do
        if string.lower(p.Name):match("^" .. string.lower(name)) or string.lower(p.DisplayName):match("^" .. string.lower(name)) then
            return p
        end
    end
    return nil
end


-- ==========================================
-- 3. LOGIKA TOMBOL SAAT DIKLIK
-- ==========================================
TPButton.MouseButton1Click:Connect(function()
    local text = NameInput.Text
    if text == "" then 
        TPButton.Text = "Isi nama dulu!"
        task.wait(1)
        TPButton.Text = "TELEPORT"
        return 
    end
    
    local targetPlayer = findTarget(text)
    
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetCFrame = targetPlayer.Character.HumanoidRootPart.CFrame
        TPButton.Text = "Teleporting..."
        TPButton.BackgroundColor3 = Color3.fromRGB(200, 120, 0)
        
        safeTeleport(targetCFrame)
        
        TPButton.Text = "Sukses!"
        TPButton.BackgroundColor3 = Color3.fromRGB(0, 150, 70)
        task.wait(1)
        TPButton.Text = "TELEPORT"
    else
        TPButton.Text = "Tidak ditemukan / Mati"
        TPButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        task.wait(1.5)
        TPButton.Text = "TELEPORT"
        TPButton.BackgroundColor3 = Color3.fromRGB(0, 150, 70)
    end
end)
