-- Script Full Executor (Bypass CFrame Method)

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- KONFIGURASI BYPASS SPEED
-- Semakin besar angka ini, semakin cepat jalannya (tapi makin rawan tersendat)
-- Kisaran aman: 0.1 sampai 0.4
local BOOST_POWER = 1.25 

local isSpeedEnabled = false

-- 1. MEMBUAT GUI SECARA OTOMATIS
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BypassSpeedGui"

local success, err = pcall(function()
	screenGui.Parent = CoreGui
end)
if not success then
	screenGui.Parent = player:WaitForChild("PlayerGui")
end

-- 2. MEMBUAT TOMBOL GUI
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 150, 0, 50)
button.Position = UDim2.new(0.05, 0, 0.4, 0) -- Di sebelah kiri layar
button.TextSize = 18
button.Font = Enum.Font.SourceSansBold
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Parent = screenGui

-- Fungsi update warna tombol
local function updateButtonDisplay()
	if isSpeedEnabled then
		button.Text = "CFrame Speed: ON"
		button.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Hijau
	else
		button.Text = "CFrame Speed: OFF"
		button.BackgroundColor3 = Color3.fromRGB(231, 76, 60) -- Merah
	end
end

updateButtonDisplay()

-- Deteksi klik tombol GUI untuk On/Off
button.MouseButton1Click:Connect(function()
	isSpeedEnabled = not isSpeedEnabled
	updateButtonDisplay()
end)

-- 3. LOOP PROSES BYPASS (KODE YANG KAMU MAKSUD)
task.spawn(function()
	while task.wait() do -- Loop secepat mungkin mengikuti frame game
		if isSpeedEnabled then
			local character = player.Character
			local rootPart = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			
			-- Hanya mendorong jika kamu sedang menekan tombol WASD / Analog (MoveDirection > 0)
			if rootPart and humanoid and humanoid.MoveDirection.Magnitude > 0 then
				-- Memindahkan koordinat karakter sedikit demi sedikit ke depan secara instan
				rootPart.CFrame = rootPart.CFrame + (humanoid.MoveDirection * BOOST_POWER)
			end
		end
	end
end)
