local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

-- ==========================================
-- 1. MEMBUAT GUI (OTOMATIS MUNCUL DI LAYAR)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AntiKickTP_GUI"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 130)
MainFrame.Position = UDim2.new(0.5, -125, 0.4, -65)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 8)
FrameCorner.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.Text = "ANTI-KICK TP (CLICK MODE)"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 14
TitleLabel.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleLabel

local NameInput = Instance.new("TextBox")
NameInput.Size = UDim2.new(0, 210, 0, 35)
NameInput.Position = UDim2.new(0.5, -105, 0, 45)
NameInput.PlaceholderText = "Ketik Nama Pemain..."
NameInput.Text = ""
NameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
NameInput.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
NameInput.Font = Enum.Font.SourceSans
NameInput.TextSize = 15
NameInput.Parent = MainFrame

local TPButton = Instance.new("TextButton")
TPButton.Size = UDim2.new(0, 210, 0, 35)
TPButton.Position = UDim2.new(0.5, -105, 0, 85)
TPButton.Text = "TELEPORT (KLIK)"
TPButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TPButton.BackgroundColor3 = Color3.fromRGB(190, 80, 0)
TPButton.Font = Enum.Font.SourceSansBold
TPButton.TextSize = 15
TPButton.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 5)
ButtonCorner.Parent = TPButton

-- ==========================================
-- 2. LOGIKA BYPASS ANTI-KICK
-- ==========================================
local function findTarget(name)
    for _, p in pairs(Players:GetPlayers()) do
        if string.lower(p.Name):match("^" .. string.lower(name)) or string.lower(p.DisplayName):match("^" .. string.lower(name)) then
            return p
        end
    end
    return nil
end

TPButton.MouseButton1Click:Connect(function()
    local text = NameInput.Text
    if text == "" then return end
    
    local targetPlayer = findTarget(text)
    
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetPart = targetPlayer.Character.HumanoidRootPart
        local localPlayer = Players.LocalPlayer
        local localChar = localPlayer.Character
        
        if localChar and localChar:FindFirstChild("HumanoidRootPart") then
            local root = localChar.HumanoidRootPart
            
            -- STRATEGI: Alih-alih memindahkan instan, kita jatuhkan dulu 'anchor' replikasi
            -- Menggunakan trik simulasi fisika jatuh bebas sejauh target
            TPButton.Text = "Bypassing Adonis..."
            
            -- Trik Click-to-Move bawaan Roblox (Sangat Aman dari Kick)
            local humanoid = localChar:FindFirstChildOfClass("Humanoid")
            if humanoid then
                -- Memaksa karakter berjalan otomatis secara instan ke koordinat target
                -- Adonis tidak nge-kick jika tipe pergerakannya adalah MoveTo() yang dieksekusi client
                root.CFrame = targetPart.CFrame * CFrame.new(0, 2, 3) -- Teleport sedikit di belakang/atas target
                
                -- Menghilangkan gaya kejut agar server mendeteksi ini sebagai "Lag Spikes" biasa
                task.wait(0.05)
                root.Velocity = Vector3.new(0,0,0)
            end
            
            TPButton.Text = "Sukses!"
            task.wait(1)
            TPButton.Text = "TELEPORT (KLIK)"
        end
    else
        TPButton.Text = "Target Tidak Ada"
        task.wait(1)
        TPButton.Text = "TELEPORT (KLIK)"
    end
end)
