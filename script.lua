--[[
    KILASIK Multi Fling - Delta Optimized 2026
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer
local Character = LP.Character or LP.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

local Selected = {}
local FlingActive = false

-- GUI
local SG = Instance.new("ScreenGui")
SG.ResetOnSpawn = false
SG.Parent = game.CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 350, 0, 420)
Frame.Position = UDim2.new(0.5, -175, 0.5, -210)
Frame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = SG

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,45)
Title.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
Title.Text = "KILASIK MULTI FLING - DELTA"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 19
Title.Parent = Frame

local Status = Instance.new("TextLabel")
Status.Position = UDim2.new(0,15,0,55)
Status.Size = UDim2.new(1,-30,0,25)
Status.BackgroundTransparency = 1
Status.Text = "0 target selected"
Status.TextColor3 = Color3.fromRGB(180,180,180)
Status.Font = Enum.Font.Gotham
Status.TextSize = 15
Status.Parent = Frame

local Scrolling = Instance.new("ScrollingFrame")
Scrolling.Position = UDim2.new(0,15,0,90)
Scrolling.Size = UDim2.new(1,-30,0,230)
Scrolling.BackgroundColor3 = Color3.fromRGB(30,30,30)
Scrolling.ScrollBarThickness = 6
Scrolling.Parent = Frame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0,6)
UIList.Parent = Scrolling

-- Fling Function (Delta Optimized)
local function Fling(plr)
    local TargetChar = plr.Character
    if not TargetChar or not TargetChar:FindFirstChild("HumanoidRootPart") then return end

    local TRoot = TargetChar.HumanoidRootPart
    local OldCFrame = Root.CFrame

    Workspace.FallenPartsDestroyHeight = 9e9

    for i = 1, 25 do
        if not FlingActive then break end
        Root.CFrame = TRoot.CFrame * CFrame.new(0, 2.5, 0) * CFrame.Angles(math.rad(90), 0, math.rad(i*10))
        Root.Velocity = Vector3.new(0, 6500 + i*100, 0)
        Root.RotVelocity = Vector3.new(9e5, 9e5, 9e5)
        task.wait(0.025)
    end

    task.wait(0.2)
    Root.CFrame = OldCFrame
    Root.Velocity = Vector3.zero
    Root.RotVelocity = Vector3.zero
    Workspace.FallenPartsDestroyHeight = -500
end

-- Refresh Player List
local function Refresh()
    for _, v in pairs(Scrolling:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local Entry = Instance.new("Frame")
            Entry.Size = UDim2.new(1, -10, 0, 42)
            Entry.BackgroundColor3 = Color3.fromRGB(40,40,40)
            Entry.Parent = Scrolling

            local NameLabel = Instance.new("TextLabel")
            NameLabel.Size = UDim2.new(0.65,0,1,0)
            NameLabel.BackgroundTransparency = 1
            NameLabel.Text = "   "..plr.Name
            NameLabel.TextColor3 = Color3.new(1,1,1)
            NameLabel.TextXAlignment = Enum.TextXAlignment.Left
            NameLabel.Parent = Entry

            local ToggleBtn = Instance.new("TextButton")
            ToggleBtn.Size = UDim2.new(0.3,0,0.75,0)
            ToggleBtn.Position = UDim2.new(0.67,0,0.12,0)
            ToggleBtn.BackgroundColor3 = Selected[plr] and Color3.fromRGB(0,200,0) or Color3.fromRGB(70,70,70)
            ToggleBtn.Text = Selected[plr] and "SELECTED" or "SELECT"
            ToggleBtn.TextColor3 = Color3.new(1,1,1)
            ToggleBtn.Parent = Entry

            ToggleBtn.MouseButton1Click:Connect(function()
                if Selected[plr] then
                    Selected[plr] = nil
                    ToggleBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
                    ToggleBtn.Text = "SELECT"
                else
                    Selected[plr] = plr
                    ToggleBtn.BackgroundColor3 = Color3.fromRGB(0,200,0)
                    ToggleBtn.Text = "SELECTED"
                end
                Status.Text = #Selected .. " target selected"
            end)
        end
    end
end

-- Buttons
local StartButton = Instance.new("TextButton")
StartButton.Position = UDim2.new(0,15,0,335)
StartButton.Size = UDim2.new(0.47,0,0,55)
StartButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
StartButton.Text = "START FLING"
StartButton.TextColor3 = Color3.new(1
