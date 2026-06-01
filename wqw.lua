local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- ==========================================
-- 1. MEMBUAT GUI KONTROL KAMERA
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CamBypass_GUI"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 150)
MainFrame.Position = UDim2.new(0.5, -120, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 8)
FrameCorner.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.Text = "CAMERA TP BYPASS (ADONIS)"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.BackgroundColor3 = Color3.fromRGB(70, 30, 120)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 13
TitleLabel.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleLabel

-- Tombol Mengintai (Next Player)
local NextBtn = Instance.new("TextButton")
NextBtn.Size = UDim2.new(0, 220, 0, 35)
NextBtn.Position = UDim2.new(0, 10, 0, 45)
NextBtn.Text = "INTIP PEMAIN (CARI TARGET)"
NextBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
NextBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
NextBtn.Font = Enum.Font.SourceSansBold
NextBtn.TextSize = 14
NextBtn.Parent = MainFrame

-- Tombol Teleport ke Kamera yang sedang mengintip
local TPBtn = Instance.new("TextButton")
TPBtn.Size = UDim2.new(0, 220, 0, 45)
TPBtn.Position = UDim2.new(0, 10, 0, 90)
TPBtn.Text = "TELEPORT KE SINI"
TPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TPBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 60)
TPBtn.Font = Enum.Font.SourceSansBold
TPBtn.TextSize = 16
TPBtn.Parent = MainFrame

-- ==========================================
-- 2. LOGIKA INTIP & REPLIKASI KAMERA
-- ==========================================
local currentTargetIndex = 1
local targetSubject = nil

local function getValidTargets()
    local targets = {}
    -- Memindai model apa pun di Workspace yang punya Humanoid (Aman dari isolasi Service)
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
            if obj.Name ~= localPlayer.Name then
                table.insert(targets, obj)
            end
        end
    end
    return targets
end

-- Fungsi Mengubah Kamera untuk Mengintip Target
NextBtn.MouseButton1Click:Connect(function()
    local availableTargets = getValidTargets()
    
    if #availableTargets == 0 then
        NextBtn.Text = "Tidak ada target fisik terdekat"
        task.wait(1)
        NextBtn.Text = "INTIP PEMAIN (CARI TARGET)"
        return
    end
    
    if currentTargetIndex > #availableTargets then
        currentTargetIndex = 1
    end
    
    local target = availableTargets[currentTargetIndex]
    if target and target:FindFirstChildOfClass("Humanoid") then
        camera.CameraSubject = target:FindFirstChildOfClass("Humanoid")
        targetSubject = target
        NextBtn.Text = "Mengintip: " .. target.Name
        currentTargetIndex = currentTargetIndex + 1
    end
end)

-- ==========================================
-- 3. LOGIKA TELEPORT AMAN (CLICK TO MOVE SIMULATION)
-- ==========================================
TPBtn.MouseButton1Click:Connect(function()
    local myChar = localPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    
    -- Jika kamera sedang mengintip seseorang
    if targetSubject and targetSubject:FindFirstChild("HumanoidRootPart") then
        local targetRoot = targetSubject.HumanoidRootPart
        local myRoot = myChar.HumanoidRootPart
        
        TPBtn.Text = "Sinkronisasi Posisi..."
        
        -- Bypass Trik: Menggunakan metode lerp instan tanpa mengubah state fisika berlebih
        -- Kita memindahkan karakter ke posisi kamera saat ini (yang berada di target)
        myRoot.Velocity = Vector3.new(0,0,0)
        
        -- Taruh 3 stud di atas target agar aman
        myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 3, 0)
        
        task.wait(0.05)
        myRoot.Velocity = Vector3.new(0,0,0)
        
        -- Kembalikan kamera ke karakter kita sendiri
        if myChar:FindFirstChildOfClass("Humanoid") then
            camera.CameraSubject = myChar:FindFirstChildOfClass("Humanoid")
        end
        
        TPBtn.Text = "TELEPORT KE SINI"
        NextBtn.Text = "INTIP PEMAIN (CARI TARGET)"
        targetSubject = nil
    else
        -- Jika tidak mengintip siapa-siapa, kembalikan kamera ke diri sendiri
        if myChar:FindFirstChildOfClass("Humanoid") then
            camera.CameraSubject = myChar:FindFirstChildOfClass("Humanoid")
        end
        TPBtn.Text = "Intip target dulu!"
        task.wait(1)
        TPBtn.Text = "TELEPORT KE SINI"
    end
end)
