-- =============================================================================
-- INVISIBLE CONTROLLER - VERSION 6.0 (SERVER-SIDE MOVEMENT SYNC)
-- =============================================================================
local SCRIPT_VERSION = "v6.0"
print("Invisible Controller " .. SCRIPT_VERSION .. " loaded!")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local invisActive = false
local savedProps = {} -- Simpan data asli tiap part

-- =============================================================================
-- CORE: Langsung modifikasi karakter asli (bukan clone)
-- =============================================================================
local function makeInvisible()
    local char = player.Character
    if not char then return end
    savedProps = {}

    for _, obj in ipairs(char:GetDescendants()) do
        -- Sembunyikan BasePart
        if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" then
            savedProps[obj] = {
                Transparency = obj.Transparency,
            }
            obj.Transparency = 1

        -- Sembunyikan Accessory/Hat mesh
        elseif obj:IsA("SpecialMesh") or obj:IsA("BlockMesh") then
            savedProps[obj] = {
                Scale = obj.Scale,
                MeshId = (obj:IsA("SpecialMesh") and obj.MeshId or nil),
                TextureId = (obj:IsA("SpecialMesh") and obj.TextureId or nil),
            }
            if obj:IsA("SpecialMesh") then
                obj.MeshId = ""
                obj.TextureId = ""
                obj.Scale = Vector3.new(0, 0, 0)
            else
                obj.Scale = Vector3.new(0, 0, 0)
            end

        -- Sembunyikan Decal/Texture (muka, dll)
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            savedProps[obj] = { Transparency = obj.Transparency }
            obj.Transparency = 1
        end
    end

    -- Sembunyikan HumanoidRootPart (sudah transparan default, pastikan)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Transparency = 1 end
end

local function makeVisible()
    local char = player.Character
    if not char then return end

    for obj, props in pairs(savedProps) do
        -- Cek apakah objek masih valid
        if typeof(obj) == "Instance" and obj.Parent then
            if props.Transparency ~= nil then
                obj.Transparency = props.Transparency
            end
            if props.Scale ~= nil then
                obj.Scale = props.Scale
            end
            if props.MeshId ~= nil then
                obj.MeshId = props.MeshId
            end
            if props.TextureId ~= nil then
                obj.TextureId = props.TextureId
            end
        end
    end

    savedProps = {}
end

-- =============================================================================
-- TOGGLE
-- =============================================================================
local function toggle()
    local char = player.Character
    if not char then
        warn("No character found!")
        return
    end

    invisActive = not invisActive

    if invisActive then
        makeInvisible()
        print("[Invis v6.0]: INVISIBLE ON - Movement tetap tersinkronisasi ke server.")
    else
        makeVisible()
        print("[Invis v6.0]: INVISIBLE OFF - Karakter dikembalikan normal.")
    end
end

-- Handle respawn: otomatis reapply kalau masih aktif
player.CharacterAdded:Connect(function(newChar)
    savedProps = {}
    if invisActive then
        task.wait(1) -- Tunggu karakter fully load
        makeInvisible()
    end
end)

-- =============================================================================
-- GUI
-- =============================================================================
local oldGui = CoreGui:FindFirstChild("InvisGui") or player.PlayerGui:FindFirstChild("InvisGui")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InvisGui"
screenGui.ResetOnSpawn = false
local ok = pcall(function() screenGui.Parent = CoreGui end)
if not ok then screenGui.Parent = player:WaitForChild("PlayerGui") end

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 160, 0, 65)
frame.Position = UDim2.new(0.05, 0, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(100, 0, 200)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(1, 0, 0.4, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "INVIS CONTROLLER " .. SCRIPT_VERSION
titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLbl.Font = Enum.Font.SourceSansBold
titleLbl.TextSize = 11
titleLbl.Parent = frame

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0.9, 0, 0.5, 0)
btn.Position = UDim2.new(0.05, 0, 0.45, 0)
btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
btn.Text = "STATUS: OFF"
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.Font = Enum.Font.SourceSansBold
btn.TextSize = 14
btn.Parent = frame

RunService.Heartbeat:Connect(function()
    if invisActive then
        btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        btn.Text = "STATUS: ON"
    else
        btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        btn.Text = "STATUS: OFF"
    end
end)

btn.MouseButton1Click:Connect(toggle)
