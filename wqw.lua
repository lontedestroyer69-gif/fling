local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Fungsi utama pengelabuan jalur (Bypass Server-Side Check)
local function pathTeleport(targetCFrame)
    local char = localPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    
    local startFrame = root.CFrame
    local distance = (startFrame.Position - targetCFrame.Position).Magnitude
    
    -- Mengubah state ke Seating/Physics agar server melonggarkan pengecekan kecepatan
    hum:ChangeState(Enum.HumanoidStateType.Seated)
    
    -- Menghitung jumlah langkah. Semakin besar angka pembagi (misal 4), semakin mulus & aman dari rubberband
    local steps = math.floor(distance / 4) 
    
    for i = 1, steps do
        if not root or not char then break end
        
        -- Interpolasi posisi secara bertahap (tidak instan)
        local alpha = i / steps
        root.CFrame = startFrame:Lerp(targetCFrame * CFrame.new(0, 3, 0), alpha)
        
        -- Mematikan gaya sentak fisik per langkah
        root.Velocity = Vector3.new(0,0,0)
        root.AssemblyLinearVelocity = Vector3.new(0,0,0)
        
        -- Jeda sangat tipis (1 frame) agar server sempat memproses pergerakan legal
        RunService.Heartbeat:Wait()
    end
    
    -- Kembalikan state ke normal setelah sampai
    task.wait(0.1)
    hum:ChangeState(Enum.HumanoidStateType.Running)
    root.Velocity = Vector3.new(0,0,0)
end

-- CARA INTEGRASI:
-- Panggil fungsi `pathTeleport(targetRoot.CFrame)` saat tombol hijau di-klik.
