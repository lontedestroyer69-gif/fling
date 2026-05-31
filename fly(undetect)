local Players = game:GetService("Players") 
local RunService = game:GetService("RunService") 
local UserInputService = game:GetService("UserInputService") 
local CoreGui = game:GetService("CoreGui") 

local player = Players.LocalPlayer 
local character = player.Character or player.CharacterAdded:Wait() 
local humanoidRootPart = character:WaitForChild("HumanoidRootPart") 
local humanoid = character:WaitForChild("Humanoid") 

-- Konfigurasi Awal 
local FLYING = false 
local FLY_SPEED = 50       -- Kecepatan default 
local MIN_SPEED = 10       -- Batas kecepatan paling lambat 
local MAX_SPEED = 150      -- Batas aman maksimum agar tidak mudah auto-kick 
local BYPASS_INTERVAL = 4.5  
local lastBypass = tick() 

-- Membuat UI Indikator Kecepatan di Pojok Layar 
local screenGui = Instance.new("ScreenGui") 
screenGui.Name = "FlySpeedIndicator" 
-- Menggunakan CoreGui agar tidak sengaja terhapus oleh sistem game biasa 
if syn and syn.protect_gui then syn.protect_gui(screenGui) end  
screenGui.Parent = CoreGui 

local textLabel = Instance.new("TextLabel") 
textLabel.Size = UDim2.new(0, 200, 0, 50) 
textLabel.Position = UDim2.new(0, 20, 1, -70) -- Posisi kiri bawah 
textLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0) 
textLabel.BackgroundTransparency = 0.5 
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255) 
textLabel.TextSize = 18 
textLabel.Font = Enum.Font.SourceSansBold 
textLabel.Text = "Status: OFF | Speed: " .. FLY_SPEED 
textLabel.Parent = screenGui 

-- Membuat instance Velocity untuk pergerakan 
local linearVelocity = Instance.new("LinearVelocity") 
linearVelocity.MaxForce = math.huge 
linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector 
linearVelocity.Parent = humanoidRootPart 
linearVelocity.Enabled = false 

local attachments = humanoidRootPart:FindFirstChildOfClass("Attachment") or Instance.new("Attachment", humanoidRootPart) 
linearVelocity.Attachment0 = attachments 

-- Fungsi mendeteksi arah input pergerakan 
local function getDirection() 
	local direction = Vector3.new(0, 0, 0) 
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then 
		direction = direction + workspace.CurrentCamera.CFrame.LookVector 
	end 
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then 
		direction = direction - workspace.CurrentCamera.CFrame.LookVector 
	end 
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then 
		direction = direction - workspace.CurrentCamera.CFrame.RightVector 
	end 
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then 
		direction = direction + workspace.CurrentCamera.CFrame.RightVector 
	end 
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then 
		direction = direction + Vector3.new(0, 1, 0) 
	end 
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then 
		direction = direction - Vector3.new(0, 1, 0) 
	end 
	return direction.Unit 
end 

-- Fungsi memperbarui teks indikator UI 
local function updateUI() 
	local status = FLYING and "ON" or "OFF" 
	textLabel.Text = "Status: " .. status .. " | Speed: " .. FLY_SPEED 
	if FLYING then 
		textLabel.TextColor3 = Color3.fromRGB(0, 255, 128) -- Hijau kalau aktif 
	else 
		textLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- Putih kalau mati 
	end 
end 

-- Loop utama pergerakan 
RunService.RenderStepped:Connect(function() 
	if FLYING then 
		humanoid:ChangeState(Enum.HumanoidStateType.Physics) 
		 
		-- Fitur Anti-Detection otomatis (bypass berkala) 
		if tick() - lastBypass > BYPASS_INTERVAL then 
			linearVelocity.Enabled = false 
			task.wait(0.12)  
			linearVelocity.Enabled = true 
			lastBypass = tick() 
		end 

		local dir = getDirection() 
		if dir.Magnitude > 0 then 
			linearVelocity.VectorVelocity = dir * FLY_SPEED 
		else 
			linearVelocity.VectorVelocity = Vector3.new(0, 0, 0) 
		end 
	else 
		linearVelocity.Enabled = false 
	end 
end) 

-- Deteksi Tombol (Aktivasi & Atur Speed) 
UserInputService.InputBegan:Connect(function(input, gameProcessed) 
	if gameProcessed then return end 
	 
	-- E untuk On/Off Terbang 
	if input.KeyCode == Enum.KeyCode.E then 
		FLYING = not FLYING 
		if not FLYING then 
			humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) 
		end 
		updateUI() 
		 
	-- [ untuk Kurangi Speed 
	elseif input.KeyCode == Enum.KeyCode.LeftBracket then 
		FLY_SPEED = math.max(MIN_SPEED, FLY_SPEED - 10) 
		updateUI() 
		 
	-- ] untuk Tambah Speed 
	elseif input.KeyCode == Enum.KeyCode.RightBracket then 
		FLY_SPEED = math.min(MAX_SPEED, FLY_SPEED + 10) 
		updateUI() 
	end 
end) 

-- Deteksi jika karakter respawn/mati agar UI tidak hilang 
player.CharacterAdded:Connect(function(newChar) 
	character = newChar 
	humanoidRootPart = character:WaitForChild("HumanoidRootPart") 
	humanoid = character:WaitForChild("Humanoid") 
	attachments = humanoidRootPart:FindFirstChildOfClass("Attachment") or Instance.new("Attachment", humanoidRootPart) 
	linearVelocity.Parent = humanoidRootPart 
	linearVelocity.Attachment0 = attachments 
	FLYING = false 
	updateUI() 
end)
