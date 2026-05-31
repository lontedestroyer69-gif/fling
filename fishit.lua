-- Game: Fish It
-- Fitur: Pasif Remote Recorder + Auto Fishing (Anti-Hook Block)
-- Kontrol: Pancing manual 1x -> Tunggu tulisan READY -> Tekan X untuk ON/OFF

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local NetFolder = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):FindFirstChild("sleitnick_net@0.2.0").net

-- Variabel penampung remote
local RF_Cast, RF_Land, RE_Catch
local isRunning = false
local recordingDone = false

print("====================================================")
print("RECORDING MODE: SILAKAN MEMANCING MANUAL 1 KALI!")
print("====================================================")

-- ====================================================================
-- BAGIAN 1: PEREKAM OTOMATIS BERBASIS EVENT (Bypass Hook Block Delta)
-- ====================================================================
local connections = {}

-- Fungsi untuk mendaftarkan nama remote saat kamu memicu mereka secara manual
local function startRecording()
    for _, child in pairs(NetFolder:GetChildren()) do
        if child:IsA("RemoteFunction") then
            -- Pantau saat fungsi dipanggil oleh pancingan manualmu
            table.insert(connections, child.OnClientInvoke == nil and child.Changed:Connect(function()
                -- Menggunakan urutan logis pemicuan
                if not RF_Cast then
                    RF_Cast = child
                    print("[RECORDED] -> Remote Cast (Lempar) Didapat:", child.Name)
                elseif RF_Cast and child ~= RF_Cast and not RF_Land then
                    RF_Land = child
                    print("[RECORDED] -> Remote Land (Mendarat) Didapat:", child.Name)
                end
            end))
        elseif child:IsA("RemoteEvent") then
            -- Pantau saat kamu berhasil ngeklik/menarik ikan
            table.insert(connections, child.OnClientEvent:Connect(function()
                if not RE_Catch then
                    RE_Catch = child
                    print("[RECORDED] -> Remote Catch (Tarik) Didapat:", child.Name)
                    print("====================================================")
                    print("STATUS: READY! SILAKAN TEKAN 'X' UNTUK FULL AUTO!")
                    print("====================================================")
                    recordingDone = true
                    
                    -- Putus semua koneksi perekam agar hemat memori
                    for _, conn in pairs(connections) do conn:Disconnect() end
                end
            end))
        end
    end
end

startRecording()

-- ====================================================================
-- BAGIAN 2: LOGIKA TIMING PERFECT (Sesuaikan angka ini nanti)
-- ====================================================================
local jedaMelayang = 1.2    
local jedaTungguIkan = 3.5  -- Ubah ke 3.0 atau 3.8 jika kebanyakan dapat 'Ok'
local jedaReset = 2.5       
-- ====================================================================

-- ====================================================================
-- BAGIAN 3: LOOPING AUTO FISHING
-- ====================================================================
local function doFullFishingCycle()
    while true do
        if isRunning and recordingDone then
            print("Siklus memancing otomatis berjalan...")
            local currentTick = os.clock() 
            
            -- 1. Lempar Pancingan
            local castArgs = { [3] = currentTick }
            RF_Cast:InvokeServer(unpack(castArgs))
            
            task.wait(jedaMelayang)
            if not isRunning then continue end 
            
            -- 2. Umpan Mendarat
            local landArgs = {
                [1] = -1.233184814453125,
                [2] = 0.09342206053676161, 
                [3] = currentTick + jedaMelayang
            }
            RF_Land:InvokeServer(unpack(landArgs))
            
            task.wait(jedaTungguIkan)
            if not isRunning then continue end
            
            -- 3. Tarik Ikan (Instant Perfect)
            RE_Catch:FireServer()
            print("Ikan berhasil ditarik otomatis!")
            
            task.wait(jedaReset)
        else
            task.wait(0.5)
        end
    end
end

task.spawn(doFullFishingCycle)

-- ====================================================================
-- BAGIAN 4: SAKLAR TOMBOL ON/OFF (Tombol X)
-- ====================================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end 
    
    if input.KeyCode == Enum.KeyCode.X then
        if recordingDone then
            isRunning = not isRunning 
            if isRunning then
                print("==== AUTO FISH: ON ====")
            else
                print("==== AUTO FISH: OFF (PAUSED) ====")
            end
        else
            warn("Gagal! Kamu harus mancing manual 1x dulu sampai muncul tulisan READY.")
        end
    end
end)
