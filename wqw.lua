local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- ==========================================
-- 1. MEMBUAT GUI UTAMA
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ListTP_GUI"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 250)
MainFrame.Position = UDim2.new(0.5, -110, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 8)
FrameCorner.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 35)
TitleLabel.Text = "KLIK NAMA UNTUK TP"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 14
TitleLabel.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleLabel

-- Tempat List Pemain (Scrolling Frame agar bisa di-scroll ke bawah)
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -10, 1, -45)
ScrollFrame.Position = UDim2.new(0, 5, 0, 40)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.Parent = MainFrame

-- Layout otomatis agar tombol tersusun rapi ke bawah
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollFrame
UIListLayout.SortOrder = Enum.SortOrder.Name
UIListLayout.Padding = UDim.new(0, 5)

-- ==========================================
-- 2. FUNGSI TELEPORT AMAN
-- ==========================================
local function teleportKePemain(targetPlayer)
    local localPlayer = Players.LocalPlayer
    if targetPlayer == localPlayer then return end -- Jangan TP ke diri sendiri
    
    if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetPart = targetPlayer.Character.HumanoidRootPart
        local localChar = localPlayer.Character
        
        if localChar and localChar:FindFirstChild("HumanoidRootPart") then
            local root = localChar.HumanoidRootPart
            
            -- Kasih jeda tipis dan hilangkan gaya gerak agar tidak memicu deteksi instan Adonis
            root.Velocity = Vector3.new(0,0,0)
            root.AssemblyLinearVelocity = Vector3.new(0,0,0)
            
            -- Teleport dengan offset aman (3 stud di atas target)
            root.CFrame = targetPart.CFrame * CFrame.new(0, 3, 0)
            
            task.wait(0.05)
            root.Velocity = Vector3.new(0,0,0)
        end
    end
end

-- ==========================================
-- 3. LOGIKA UPDATE DAFTAR PEMAIN
-- ==========================================
local function updateList()
    -- Bersihkan list lama
    for _, child in pairs(ScrollFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Ambil semua pemain di server dan buatkan tombolnya
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Players.LocalPlayer then
            local pButton = Instance.new("TextButton")
            pButton.Size = UDim2.new(1, -10, 0, 30)
            pButton.Text = p.DisplayName .. " (@" .. p.Name .. ")"
            pButton.TextColor3 = Color3.fromRGB(240, 240, 240)
            pButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            pButton.Font = Enum.Font.SourceSans
            pButton.TextSize = 14
            pButton.BorderSizePixel = 0
            pButton.Parent = ScrollFrame
            
            local bCorner = Instance.new("UICorner")
            bCorner.CornerRadius = UDim.new(0, 4)
            bCorner.Parent = pButton
            
            -- Efek hover saat mouse di atas tombol
            pButton.MouseEnter:Connect(function()
                pButton.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
            end)
            pButton.MouseLeave:Connect(function()
                pButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            end)
            
            -- Saat nama pemain di-klik, langsung teleport
            pButton.MouseButton1Click:Connect(function()
                pButton.Text = "Teleporting..."
                pButton.BackgroundColor3 = Color3.fromRGB(0, 150, 70)
                teleportKePemain(p)
                task.wait(0.5)
                pButton.Text = p.DisplayName .. " (@" .. p.Name .. ")"
                pButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            end)
        end
    end
    
    -- Sesuaikan ukuran scroll otomatis berdasarkan jumlah pemain
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end

-- Update otomatis kalau ada yang masuk/keluar server
Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)

-- Jalankan fungsi pertama kali saat di-execute
updateList()
