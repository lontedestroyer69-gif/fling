local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Konfigurasi Kecepatan Tinggi
local FLYING = false
local FLY_SPEED = 100      -- Kecepatan dasar (Bisa dinaikkan lewat tombol ']')
local MIN_SPEED = 10       
local MAX_SPEED = 250      -- Batas atas dinaikkan untuk mode kencang
local BYPASS_INTERVAL = 3.5 -- Interval dipercepat untuk mengimbangi kecepatan tinggi
local lastBypass = tick()
local bypassActive = false
local bypassDuration = 0.08 

-- Membuat UI Indikator Kecepatan di Pojok Layar
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlySpeedIndicator"
if syn and syn.protect_gui then syn.protect_gui(screenGui) end 
screenGui.Parent = CoreGui

local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(0, 200, 0, 50)
textLabel.Position = UDim2.new(0, 20, 1, -70) 
textLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
textLabel.BackgroundTransparency = 0.5
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
textLabel.TextSize = 18
textLabel.Font = Enum.Font.SourceSansBold
textLabel.Text = "Status: OFF | Speed: " .. FLY_SPEED
textLabel.Parent = screenGui

-- Menggunakan BodyVelocity & BodyGyro untuk stabilitas CFrame tingkat tinggi
local bodyVelocity = Instance.new("BodyVelocity")
bodyVelocity.maxForce = Vector3.new(0, 0, 0) -- Dimatikan saat awal
bodyVelocity.velocity = Vector3.new(0, 0, 0)
bodyVelocity.Parent = humanoidRootPart

local bodyGyro = Instance.new("BodyGyro")
bodyGyro.maxTorque = Vector3.new(0, 0, 0)
bodyGyro.Parent = humanoidRootPart

-- Fungsi mendeteksi arah input pergerakan
local function getDirection()
	local direction = Vector3.new(0, 0, 0)
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + workspace.CurrentCamera.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - workspace.CurrentCamera.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - workspace.CurrentCamera.CFrame.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + workspace.CurrentCamera.CFrame.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direction = direction - Vector3.new(0, 1, 0) end
	return direction.Unit
end

local function updateUI()
	local status = FLYING and "ON" or "OFF"
	textLabel.Text = "Status: " .. status .. " | Speed: " .. FLY_SPEED
	textLabel.TextColor3 = FLYING and Color3.fromRGB(255, 85, 85) or Color3.fromRGB(255, 255, 255) -- Merah jika mode kencang aktif
end

-- Loop utama pergerakan (Optimasi Delta Posisi)
RunService.RenderStepped:Connect(function(deltaTime)
	if FLYING and humanoidRootPart then
		local currentTime = tick()
		
		-- Siklus bypass diperketat untuk meredam deteksi jarak jauh
		if not bypassActive and (currentTime - lastBypass > BYPASS_INTERVAL) then
			bypassActive = true
			lastBypass = currentTime
		end
		
		if bypassActive then
			if currentTime - lastBypass < bypassDuration then
				bodyVelocity.maxForce = Vector3.new(0, 0, 0)
				bodyGyro.maxTorque = Vector3.new(0, 0, 0)
				humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
				return
			else
				bypassActive = false
				lastBypass = currentTime
			end
		end

		-- Mode Aktif: Mengunci fisik gaya berat dan memanipulasi koordinat secara mikro
		bodyVelocity.maxForce = Vector3.new(9e4, 9e4, 9e4)
		bodyGyro.maxTorque = Vector3.new(9e4, 9e4, 9e4)
		bodyGyro.cframe = workspace.CurrentCamera.CFrame
		humanoid:ChangeState(Enum.HumanoidStateType.Climbing) 

		local dir = getDirection()
		if dir.Magnitude > 0 then
			-- Formula Delta: Menggerakkan karakter berdasarkan kalkulasi frame-rate independen (mencegah rubberband)
			local targetVelocity = dir * FLY_SPEED
			bodyVelocity.velocity = targetVelocity
			
			-- Tambahan dorongan CFrame halus agar tidak tertinggal oleh pemeriksaan server
			humanoidRootPart.CFrame = humanoidRootPart.CFrame + (targetVelocity * deltaTime * 0.1)
		else
			bodyVelocity.velocity = Vector3.new(0, -0.05, 0) -- Gaya gravitasi mikro semu
		end
	else
		bodyVelocity.maxForce = Vector3.new(0, 0, 0)
		bodyGyro.maxTorque = Vector3.new(0, 0, 0)
	end
end)

-- Deteksi Tombol
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.E then
		FLYING = not FLYING
		if not FLYING then
			humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
		updateUI()
		
	elseif input.KeyCode == Enum.KeyCode.LeftBracket then
		FLY_SPEED = math.max(MIN_SPEED, FLY_SPEED - 20) -- Lompatan speed diperbesar
		updateUI()
		
	elseif input.KeyCode == Enum.KeyCode.RightBracket then
		FLY_SPEED = math.min(MAX_SPEED, FLY_SPEED + 20)
		updateUI()
	end
end)

player.CharacterAdded:Connect(function(newChar)
	character = newChar
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	humanoid = character:WaitForChild("Humanoid")
	bodyVelocity.Parent = humanoidRootPart
	bodyGyro.Parent = humanoidRootPart
	FLYING = false
	bypassActive = false
	updateUI()
end)
