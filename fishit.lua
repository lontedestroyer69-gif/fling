-- Game: Fish It
-- Deskripsi: Permanent Auto-Scan (Anti Pindah Server / Anti Rejoin)
-- Kontrol: Tekan X untuk ON/OFF

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local NetFolder = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):FindFirstChild("sleitnick_net@0.2.0").net

local RF_Cast, RF_Land, RE_Catch

print("=========================================")
print("MENJALANKAN BYPASS AUTO-SCANNER...")
print("=========================================")

-- Sistem Scan Pintar: Memisahkan remote berdasarkan jenis dan struktur aslinya
for _, child in pairs(NetFolder:GetChildren()) do
    if child:IsA("RemoteFunction") then
        -- Game ini biasanya menyusun nama Cast secara alfabetis atau posisi indeks tertentu
        if not RF_Cast then
            RF_Cast = child
        else
            RF_Land = child
        end
    elseif child:IsA("RemoteEvent") then
        RE_Catch = child
    end
end

-- Validasi darurat: Jika urutan Cast/Land terbalik pada server tertentu, kita tukar posisinya
if RF_Cast and RF_Land then
    -- Memastikan RF_Cast adalah remote yang menerima argumen timestamp [3] saat digunakan
    -- Jika scanner terbalik mendeteksi, script akan otomatis menyeimbangkan posisinya
    if string.len(RF_Cast.Name) < string.len(RF_Land.Name) then
        local temp = RF_Cast
        RF_Cast = RF_Land
        RF_Land = temp
    end
end

if RF_Cast and RF_Land and RE_Catch then
    print("SUCCESS: Semua Remote Berhasil Dikunci Secara Otomatis!")
else
    warn("ERROR: Sistem gagal mendeteksi folder Net game. Coba reset karakter.")
end

-- ====================================================================
-- SETTING TIMING UTAMA UNTUK MENCARI "PERFECT"
-- ====================================================================
local jedaMelayang = 1.2    -- Waktu umpan melayang di udara
local jedaTungguIkan = 3.5  -- GANTI ANGKA INI (misal ke 3.0, 3.8, atau 4.0) jika belum Perfect terus
local jedaReset = 2.5       -- Jeda sebelum melempar ulang
-- ====================================================================

local isRunning = true -- Status awal aktif otomatis saat di-execute

local function doFullFishingCycle()
    while true do
        if isRunning and RF_Cast and RF_Land and RE_Catch then
            print("Memulai siklus memancing otomatis...")
            
            local currentTick = os.clock() 
            
            -- 1. Kirim Remote Lempar Pancingan
            local castArgs = {
                [3] = currentTick
            }
            RF_Cast:InvokeServer(unpack(castArgs))
            print("Pancingan otomatis dilempar...")
            
            task.wait(jedaMelayang)
            if not isRunning then continue end 
            
            -- 2. Kirim Remote Umpan Mendarat di Air
            local landArgs = {
                [1] = -1.233184814453125,
                [2] = 0.09342206053676161, 
                [3] = currentTick + jedaMelayang
            }
            RF_Land:InvokeServer(unpack(landArgs))
            print("Umpan mendarat. Menunggu ikan...")
            
            -- Jeda tunggu ikan menggigit
            task.wait(jedaTungguIkan)
            if not isRunning then continue end
            
            -- 3. Kirim Remote Tarik Ikan (Instant Catch)
            RE_Catch:FireServer()
            print("Ikan berhasil ditarik otomatis!")
            
            task.wait(jedaReset)
        else
            task.wait(0.5)
        end
    end
end

-- Jalankan Script Utama di background
task.spawn(doFullFishingCycle)

-- Fungsi Tombol ON/OFF (Tekan X pada Keyboard / Virtual Keyboard Emulator)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end 
    
    if input.KeyCode == Enum.KeyCode.X then
        isRunning = not isRunning 
        
        if isRunning then
            print("==== AUTO FISH DIKONDISIKAN: ON ====")
        else
            print("==== AUTO FISH DIKONDISIKAN: OFF (PAUSED) ====")
        end
    end
end)
