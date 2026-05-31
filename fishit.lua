-- Game: Fish It
-- Taktik: SimpleSpy Hook Engine (100% Auto-Scan Tanpa Tertukar)
-- Kontrol: Pancing manual 1x sampai ikan ditarik -> Otomatis berubah jadi FULL AUTO!

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local NetFolder = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):FindFirstChild("sleitnick_net@0.2.0").net

local RF_Cast, RF_Land, RE_Catch
local isRunning = false
local readyToAuto = false

print("====================================================")
print("SYSTEM: MENGAKTIFKAN ENGINE SIMPLESPY...")
print("SILAKAN MEMANCING MANUAL 1 KALI UNTUK SINKRONISASI!")
print("====================================================")

-- ====================================================================
-- ENGINE UTAMA: Mencegat Remote Langsung dari Inti Game (Metatable Hook)
-- ====================================================================
local oldInvoke
oldInvoke = hookmetamethod(game, "__index", function(self, key)
    if not readyToAuto and self:IsDescendantOf(NetFolder) then
        if self:IsA("RemoteFunction") and key == "InvokeServer" then
            return function(obj, ...)
                local args = {...}
                
                -- SimpleSpy Logic: Membedakan Cast & Land berdasarkan jumlah argumen di dalamnya
                if args[1] and type(args[1]) == "table" then
                    local data = args[1]
                    if data[3] and not data[1] then
                        -- Jika hanya mengirim [3] (timestamp), ini adalah CAST (Lempar)
                        RF_Cast = obj
                        print("[SPY DETECTED] -> Remote Cast Terkunci!")
                    elseif data[1] and data[2] then
                        -- Jika mengirim [1] dan [2] (koordinat umpan), ini adalah LAND (Mendarat)
                        RF_Land = obj
                        print("[SPY DETECTED] -> Remote Land Terkunci!")
                    end
                end
                return oldInvoke(self, key)(obj, ...)
            end
        end
    end
    return oldInvoke(self, key)
end)

-- Mencegat RemoteEvent Tarik Ikan
local oldFire
oldFire = hookmetamethod(game, "__index", function(self, key)
    if not readyToAuto and self:IsDescendantOf(NetFolder) then
        if self:IsA("RemoteEvent") and key == "FireServer" then
            RE_Catch = self
            print("[SPY DETECTED] -> Remote Catch Terkunci!")
            print("====================================================")
            print("SINKRONISASI SELESAI! TEKAN 'X' UNTUK FULL AUTO!")
            print("====================================================")
            readyToAuto = true
        end
    end
    return oldFire(self, key)
end)

-- ====================================================================
-- LOGIKA TIMING PERFECT
-- ====================================================================
local jedaMelayang = 1.2    
local jedaTungguIkan = 3.5  -- Sesuai diskusi, setel ini jika kebanyakan dapat 'Ok'
local jedaReset = 2.5       

local function doFullFishingCycle()
    while true do
        if isRunning and readyToAuto then
            print("Siklus otomatis berjalan...")
            local currentTick = os.clock() 
            
            -- 1. Lempar
            RF_Cast:InvokeServer({[3] = currentTick})
            task.wait(jedaMelayang)
            if not isRunning then continue end 
            
            -- 2. Mendarat
            RF_Land:InvokeServer({
                [1] = -1.233184814453125,
                [2] = 0.09342206053676161, 
                [3] = currentTick + jedaMelayang
            })
            task.wait(jedaTungguIkan)
            if not isRunning then continue end
            
            -- 3. Tarik (Perfect)
            RE_Catch:FireServer()
            print("Ikan ditarik otomatis!")
            
            task.wait(jedaReset)
        else
            task.wait(0.5)
        end
    end
end
task.spawn(doFullFishingCycle)

-- Tombol Saklar X
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end 
    if input.KeyCode == Enum.KeyCode.X then
        if readyToAuto then
            isRunning = not isRunning 
            print(isRunning and "==== AUTO FISH: ON ====" or "==== AUTO FISH: OFF ====")
        else
            warn("Siklus belum siap! Kamu wajib mancing manual 1x dulu agar script bisa merekam kodenya.")
        end
    end
end)
