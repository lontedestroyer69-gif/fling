--[[
    KILASIK Multi-Fling UPDATED 2026
    Lebih stabil + Anti-Crash + Better Reset
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local SelectedTargets = {}
local FlingActive = false

-- GUI (sama seperti sebelumnya, tapi lebih clean)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UpdatedKilasikFling"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 380)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Title.Text = "KILASIK MULTI FLING 2026"
Title.TextColor3 = Color3.fromRGB(255, 60, 60)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

-- Status
local Status = Instance.new("TextLabel")
Status.Position = UDim2.new(0, 10, 0, 40)
Status.Size = UDim2.new(1, -20, 0, 30)
Status.BackgroundTransparency = 1
Status.Text = "0 target selected"
Status.TextColor3 = Color3.fromRGB(200, 200, 200)
Status.Font = Enum.Font.Gotham
Status.TextSize = 15
Status.Parent = MainFrame

-- Scroll Frame
local Scroll = Instance.new("ScrollingFrame")
Scroll.Position = UDim2.new(0, 10, 0, 75)
Scroll.Size = UDim2.new(1, -20, 0, 220)
Scroll.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Scroll.ScrollBarThickness = 6
Scroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.Name
UIList.Padding = UDim.new(0, 4)
UIList.Parent = Scroll

-- Buttons
local StartBtn = Instance.new("TextButton")
StartBtn.Position = UDim2.new(0, 10, 0, 305)
StartBtn.Size = UDim2.new(0.48, 0, 0, 45)
StartBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
StartBtn.Text = "START FLING"
StartBtn.TextColor3 = Color3.new(1,1,1)
StartBtn.Font = Enum.Font.GothamBold
StartBtn.TextSize = 16
StartBtn.Parent = MainFrame

local StopBtn = Instance.new("TextButton")
StopBtn.Position = UDim2.new(0.5, 5, 0, 305)
StopBtn.Size = UDim2.new(0.48, 0, 0, 45)
StopBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
StopBtn.Text = "STOP"
StopBtn.TextColor3 = Color3.new(1,1,1)
StopBtn.Font = Enum.Font.GothamBold
StopBtn.TextSize = 16
StopBtn.Parent = MainFrame

-- Fungsi Update Player List
local function RefreshList()
    for _, v in pairs(Scroll:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player then
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -10, 0, 35)
            Frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            Frame.Parent = Scroll

            local Name = Instance.new("TextLabel")
            Name.Size = UDim2.new(0.7, 0, 1, 0)
            Name.BackgroundTransparency = 1
            Name.Text = plr.Name
            Name.TextColor3 = Color3.new(1,1,1)
            Name.TextXAlignment = Enum.TextXAlignment.Left
            Name.Parent = Frame

            local Toggle = Instance.new("TextButton")
            Toggle.Size = UDim2.new(0.25, 0, 0.8, 0)
            Toggle.Position = UDim2.new(0.72, 0, 0.1, 0)
            Toggle.BackgroundColor3 = SelectedTargets[plr] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(100, 100, 100)
            Toggle.Text = SelectedTargets[plr] and "SELECTED" or "SELECT"
            Toggle.TextColor3 = Color3.new(1,1,1)
            Toggle.Parent = Frame

            Toggle.MouseButton1Click:Connect(function()
                if SelectedTargets[plr] then
                    SelectedTargets[plr] = nil
                    Toggle.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                    Toggle.Text = "SELECT"
                else
                    SelectedTargets[plr] = plr
                    Toggle.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                    Toggle.Text = "SELECTED"
                end
                Status.Text = #SelectedTargets .. " target selected"
            end)
        end
    end
end

-- Improved Fling Function (2026 version)
local function FlingTarget(target)
    local tchar = target.Character
    if not tchar or not tchar:FindFirstChild("HumanoidRootPart") then return end

    local root = Character:FindFirstChild("HumanoidRootPart")
    local troot = tchar.HumanoidRootPart

    if not root then return end

    local oldcf = root.CFrame
    workspace.FallenPartsDestroyHeight = 0/0

    for i = 1, 15 do
        if not FlingActive then break end
        root.CFrame = troot.CFrame * CFrame.new(0, 2, 0) * CFrame.Angles(math.rad(90), 0, 0)
        root.Velocity = Vector3.new(0, 5000, 0)
        root.RotVelocity = Vector3.new(9e9, 9e9, 9e9)
        task.wait()
    end

    -- Reset
    task.wait(0.3)
    root.CFrame = oldcf
    root.Velocity = Vector3.new()
    root.RotVelocity = Vector3.new()
    workspace.FallenPartsDestroyHeight = -500
end

-- Start Fling
StartBtn.MouseButton1Click:Connect(function()
    if FlingActive then return end
    if next(SelectedTargets) == nil then
        Status.Text = "Pilih target dulu!"
        task.wait(1.5)
        RefreshList()
        return
    end

    FlingActive = true
    Status.Text = "FLINGING ACTIVE..."

    task.spawn(function()
        while FlingActive do
            for _, target in pairs(SelectedTargets) do
                if target and target.Character and FlingActive then
                    pcall(function()
                        FlingTarget(target)
                    end)
                end
                task.wait(0.4) -- Jeda antar target
            end
            task.wait(0.6)
        end
    end)
end)

StopBtn.MouseButton1Click:Connect(function()
    FlingActive = false
    Status.Text = "Fling Stopped"
    task.wait(1)
    RefreshList()
end)

-- Auto Refresh
Players.PlayerAdded:Connect(RefreshList)
Players.PlayerRemoving:Connect(RefreshList)

RefreshList()

print("✅ Updated Multi Fling 2026 Loaded!")
