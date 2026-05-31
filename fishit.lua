-- Game: Fish It
-- Fitur: Auto-Record Remote dari Pancingan Manual + Auto Fishing (Tekan X)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local NetFolder = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):FindFirstChild("sleitnick_net@0.2.0").net

-- Variabel penampung objek remote asli
local RF_Cast, RF_Land, RE_Catch
local isRunning = false -- Set FALSE di awal supaya tidak mancing sebelum kodenya dapat

print("====================================================")
print("SCRIPT READY! Silakan MEMANCING MANUAL 1 KALI")
print("Untuk merekam data kode Remote terbaru dari game...")
print("====================================================")

-- ====================================================================
-- BAGIAN 1: PEREKAM OTOMATIS (Mendeteksi klik manual pertamamu)
-- ====================================================================

-- Memantau RemoteFunction (Cast dan Land)
local hookFunction
hookFunction = hookmetamethod(game, "__index", function(self, key)
    if not isRunning and self:IsDescendantOf(NetFolder) then
        if self:IsA("RemoteFunction") and key == "InvokeServer" then
            if not RF_Cast then
                RF_Cast = self
                print("-> BERHASIL MEREKAM REMOTE CAST (LEMPAR):", self.Name)
            elseif RF_Cast and self ~= RF_Cast and not RF_Land then
                RF_Land = self
                print("-> BERHASIL MEREKAM REMOTE LAND (MENDARAT):", self.Name)
            end
        end
    end
    return hookFunction(self, key)
end)

-- Memantau RemoteEvent (Catch/Tarik)
local hookEvent
hookEvent = hookmetamethod(game, "__index", function(self, key)
    if not isRunning and self:IsDescendantOf(NetFolder) then
        if self:IsA("RemoteEvent") and key == "FireServer" and not RE_Catch then
            RE_Catch = self
            print("-> BERHASIL MEREKAM REMOTE CATCH (TARIK):", self.Name)
            print("====================================================")
            print("SEMUA REMOTE BERHASIL DIREKAM! TEKAN 'X' UNTUK AUTO FISHING")
            print("====================================================")
        end
    end
    return hookEvent(self, key)
end)


-- ====================================================================
-- BAGIAN 2: LOGIKA TIMING PERFECT
-- ====================================================================
local jedaMelayang = 1.2    
local jedaTungguIkan = 3.5  -- Ganti angka 3.5 ini (ke 3.0 atau 3.8) jika nanti belum Perfect terus
local jedaReset = 2.5       
-- ====================================================================


-- ====================================================================
-- BAGIAN 3: LOOPING AUTO FISHING (Jalan setelah tombol X ditekan)
-- ====================================================================
local function doFullFishingCycle()
    while true do
        if isRunning then
            -- Pastikan semua kode remote sudah terkumpul sebelum melempar otomatis
            if RF_Cast and RF_Land and RE_Catch then
                print("Memulai siklus memancing otomatis...")
                
                local currentTick = os.clock() 
                
                -- 1. Kirim Remote Lempar Pancingan
                local castArgs = { [3] = currentTick }
                RF_Cast:InvokeServer(unpack(castArgs))
                print("Otomatis: Pancingan dilempar...")
                
                task.wait(jedaMelayang)
                if not isRunning then continue end 
                
                -- 2. Kirim Remote Umpan Mendarat di Air
                local landArgs = {
                    [1] = -1.233184814453125,
                    [2] = 0.09342206053676161, 
                    [3] = currentTick + jedaMelayang
                }
                RF_Land:InvokeServer(unpack(landArgs))
                print("Otomatis: Umpan mendarat di air. Menunggu ikan...")
                
                task.wait(jedaTungguIkan)
                if not isRunning then continue end
                
                -- 3. Kirim Remote Tarik Ikan (Instant Catch)
                RE_Catch:FireServer()
                print("Otomatis: Ikan berhasil ditarik!")
                
                task.wait(jedaReset)
            else
                warn("Data remote belum lengkap! Silakan pancing manual dulu 1 kali.")
                isRunning = false
            end
        else
            task.wait(0.5) -- Istirahat pasif kalau di-pause
        end
    end
end

-- Jalankan loop pancing otomatis di background thread
task.spawn(doFullFishingCycle)


-- ====================================================================
-- BAGIAN 4: SAKLAR TOMBOL ON/OFF (Tombol X)
-- ====================================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end 
    
    if input.KeyCode == Enum.KeyCode.X then
        if RF_Cast and RF_Land and RE_Catch then
            isRunning = not isRunning 
            if isRunning then
                print("==== AUTO FISH STATUS: ON (Siklus Berjalan) ====")
            else
                print("==== AUTO FISH STATUS: OFF (PAUSED) ====")
            end
        else
            warn("Gagal menyalakan! Kamu belum melakukan pancingan manual untuk merekam remote.")
        end
    end
end)
