-- Eksekusi script ini di Executor
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Berapa jarak maksimal per klik (Cari angka aman antara 15 sampai 25)
local BLINK_DISTANCE = 20 

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Tekan tombol "E" untuk Blink/Teleport ke arah kursor/kamera
    if input.KeyCode == Enum.KeyCode.E then
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            -- Ambil arah hadap kamera
            local lookDirection = camera.CFrame.LookVector
            
            -- Pindahkan karakter hanya sejauh toleransi server (20 stud)
            root.CFrame = root.CFrame + (lookDirection * BLINK_DISTANCE)
            
            -- Reset velocity instan agar tidak mental
            root.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)
