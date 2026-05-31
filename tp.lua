-- Teleport To Player GUI
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Buat GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 300)
frame.Position = UDim2.new(0, 20, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

-- Corner
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(50, 100, 255)
title.Text = "Teleport to Player"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.BorderSizePixel = 0
title.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = title

-- Scroll list player
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -10, 1, -100)
scrollFrame.Position = UDim2.new(0, 5, 0, 45)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 4
scrollFrame.Parent = frame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = scrollFrame

-- Refresh Button
local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(1, -10, 0, 35)
refreshBtn.Position = UDim2.new(0, 5, 1, -50)
refreshBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
refreshBtn.Text = "Refresh Players"
refreshBtn.TextColor3 = Color3.new(1,1,1)
refreshBtn.TextScaled = true
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.BorderSizePixel = 0
refreshBtn.Parent = frame

local refreshCorner = Instance.new("UICorner")
refreshCorner.CornerRadius = UDim.new(0, 6)
refreshCorner.Parent = refreshBtn

-- Fungsi populate player list
local function refreshPlayers()
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -5, 0, 35)
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            btn.Text = player.Name
            btn.TextColor3 = Color3.new(1,1,1)
            btn.TextScaled = true
            btn.Font = Enum.Font.Gotham
            btn.BorderSizePixel = 0
            btn.Parent = scrollFrame

            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = btn

            -- Teleport saat diklik
            btn.MouseButton1Click:Connect(function()
                local character = localPlayer.Character
                local targetChar = player.Character
                if character and targetChar then
                    local root = character:FindFirstChild("HumanoidRootPart")
                    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                    if root and targetRoot then
                        root.CFrame = targetRoot.CFrame + Vector3.new(0, 0, 3)
                        print("Teleported to " .. player.Name)
                    end
                end
            end)
        end
    end

    -- Update canvas size
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end

refreshBtn.MouseButton1Click:Connect(refreshPlayers)
refreshPlayers() -- Auto load saat pertama kali

print("Teleport GUI loaded!")
