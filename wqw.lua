local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local localPlayer = Players.LocalPlayer

-- ==========================================
-- 1. MEMBUAT GUI UTAMA
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BypassUltimate_GUI"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 230, 0, 280)
MainFrame.Position = UDim2.new(0.5, -115, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 8)
FrameCorner.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 35)
TitleLabel.Text = "ADONIS HARD BYPASS"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 13
TitleLabel.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleLabel

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -10, 1, -80)
ScrollFrame.Position = UDim2.new(0, 5, 0, 40)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollFrame
UIListLayout.SortOrder = Enum.SortOrder.Name
UIListLayout.Padding = UDim.new(0, 5)

-- Tombol Refresh Manual jika list macet
local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(1, -10, 0, 30)
RefreshBtn.Position = UDim2.new(0, 5, 1, -35)
RefreshBtn.Text = "REFRESH DAFTAR"
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
RefreshBtn.Font = Enum.Font.SourceSansBold
RefreshBtn.TextSize = 12
RefreshBtn.Parent = MainFrame

local RefreshCorner = Instance.new("UICorner")
RefreshCorner.CornerRadius = UDim.new(0, 4)
RefreshCorner.Parent = RefreshBtn

-- ==========================================
-- 2. FUNGSI SCANNING & TELEPORT FISIK
-- ==========================================
local function teleportKeKarakter(targetModel)
    local myChar = localPlayer.Character
    if not myChar then return end
    
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetModel:FindFirstChild("HumanoidRootPart")
    
    if myRoot and targetRoot then
        myRoot.Velocity = Vector3.new(0,0,0)
        myRoot.AssemblyLinearVelocity = Vector3.new(0,0,0)
        
        -- METODE BYPASS KICK: Kita memindahkan posisi secara horizontal 
        -- dan menaruh karakter 4 stud di atas kepala target agar tidak memicu deteksi tabrakan.
        myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 4, 0)
        
        task.wait(0.05)
        myRoot.Velocity = Vector3.new(0,0,0)
    end
end

-- Memindai Workspace secara paksa mencari karakter manusia
local function scanWorkspacePlayers()
    for _, child in pairs(ScrollFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    -- Mencari folder atau model di Workspace yang memiliki struktur karakter Roblox
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
            -- Pastikan itu bukan karakter kita sendiri
            if obj.Name ~= localPlayer.Name then
                
                local pButton = Instance.new("TextButton")
                pButton.Size = UDim2.new(1, -10, 0, 30)
                pButton.Text = obj.Name
                pButton.TextColor3 = Color3.fromRGB(240, 240, 240)
                pButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
                pButton.Font = Enum.Font.SourceSans
                pButton.TextSize = 14
                pButton.BorderSizePixel = 0
                pButton.Parent = ScrollFrame
                
                local bCorner = Instance.new("UICorner")
                bCorner.CornerRadius = UDim.new(0, 4)
                bCorner.Parent = pButton
                
                pButton.MouseButton1Click:Connect(function()
                    pButton.Text = "Teleporting..."
                    pButton.BackgroundColor3 = Color3.fromRGB(0, 150, 70)
                    teleportKeKarakter(obj)
                    task.wait(0.5)
                    pButton.Text = obj.Name
                    pButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
                end)
            end
        end
    end
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end

-- Jalankan fungsi scan
RefreshBtn.MouseButton1Click:Connect(scanWorkspacePlayers)
scanWorkspacePlayers()
