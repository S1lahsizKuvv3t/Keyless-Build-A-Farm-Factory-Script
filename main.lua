print("Zenith Hub Executed")

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local playerName = LocalPlayer.Name
local Comm = ReplicatedStorage:WaitForChild("Communication")
local PlotsFolder = workspace:WaitForChild("Plots") 

local _T = {
    AutoClick = false, AutoSellCrates = false, 
    AutoPlantTier1 = false, AutoPlantTier2 = false, AutoPlantAll = false,
    PrestigeLoop = false, BuyAll = false, AutoStar = false, 
    AutoRoll = false, AntiAFK = true, AutoRejoin = false
}

local HttpService = game:GetService("HttpService")
local configFileName = "ZewittHub_Hafiza.json"

-- OYUN AÇILDIĞINDA ESKİ AYARLARI OKU VE YÜKLE
if isfile and isfile(configFileName) and readfile then
    pcall(function()
        local savedData = HttpService:JSONDecode(readfile(configFileName))
        for ayarAdi, deger in pairs(savedData) do
            -- Hafızadaki değerleri tablomuzla eşleştir
            if _T[ayarAdi] ~= nil then
                _T[ayarAdi] = deger
            end
        end
    end)
end

-- ARKA PLANDA HER 5 SANİYEDE BİR AYARLARI BİLGİSAYARA KAYDET
task.spawn(function()
    if writefile then
        while task.wait(5) do
            pcall(function()
                writefile(configFileName, HttpService:JSONEncode(_T))
            end)
        end
    end
end)

-- CANLI İSTATİSTİK HAFIZASI
local sessionStats = {
    Rolls = 0,
    Planted = 0
}

local HttpService = game:GetService("HttpService")
local REPORT_URL = "https://ntfy.sh/zewitt_farm_report_45"
local COMMAND_URL = "https://ntfy.sh/zewitt_komut_45"

-- EXPLOIT İNTERNET MOTORU
local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

local TargetSeeds = {}
local DeleteSeeds = {}

local Tier1Seeds = {"Strawberry Seeds", "Carrot Seeds", "Tomato Seeds", "Corn Seeds", "Blueberry Seeds", "Potato Seeds"}
local Tier2Seeds = {"Sugarcane Seeds", "Watermelon Seeds", "Blackberry Seeds", "Beet Seeds", "Kiwi Seeds", "Pineapple Seeds", "Prickly Pear Seeds", "Dragon Fruit"}
local AllSeeds = {"Strawberry Seeds", "Carrot Seeds", "Tomato Seeds", "Corn Seeds", "Blueberry Seeds", "Potato Seeds", "Sugarcane Seeds", "Watermelon Seeds", "Blackberry Seeds", "Beet Seeds", "Kiwi Seeds", "Pineapple Seeds", "Prickly Pear Seeds", "Dragon Fruit"}
local BoardUpgrades = {"UpgradeCaps", "MutationMultiplier", "Click", "SeedLuck", "SprinkerPower", "Rolls"}
local HoneyUpgrades = {"PollinationBoost", "PollinationTime"}

local function EquipToolFromList(list)
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not char or not backpack then return false end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end

    local lowerList = {}
    for i, name in ipairs(list) do lowerList[i] = string.lower(name) end

    local foundTools = {}
    local toolCounts = {} 

    local function collectTools(parent)
        for _, tool in ipairs(parent:GetChildren()) do
            if tool:IsA("Tool") then
                local toolName = string.lower(tool.Name)
                for _, name in ipairs(lowerList) do
                    if string.find(toolName, name) then
                        table.insert(foundTools, tool)
                        toolCounts[tool.Name] = (toolCounts[tool.Name] or 0) + 1
                        break
                    end
                end
            end
        end
    end

    collectTools(backpack)
    collectTools(char)

    if #foundTools == 0 then return false end

    local toolWeights = {}
    for _, tool in ipairs(foundTools) do
        local explicitAmount = nil
        for _, v in ipairs(tool:GetChildren()) do
            if v:IsA("IntValue") or v:IsA("NumberValue") then
                local n = string.lower(v.Name)
                if n == "amount" or n == "quantity" or n == "count" or n == "stack" or n == "value" then
                    explicitAmount = v.Value
                    break
                end
            end
        end
        toolWeights[tool] = explicitAmount or toolCounts[tool.Name] or 0
    end

    table.sort(foundTools, function(a, b)
        return toolWeights[a] < toolWeights[b]
    end)

    local bestTool = foundTools[1]
    
    local currentTool = char:FindFirstChildOfClass("Tool")
    if currentTool and currentTool == bestTool then
        return true
    end

    humanoid:EquipTool(bestTool)
    return true
end

local function WipeSelectedItems(selectedList)
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not char or not backpack or not selectedList or #selectedList == 0 then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local lowerList = {}
    for i, name in ipairs(selectedList) do lowerList[i] = string.lower(name) end

    local toolsToDelete = {}
    local function checkAndAdd(tool)
        if tool:IsA("Tool") then
            local toolName = string.lower(tool.Name)
            for _, name in ipairs(lowerList) do
                if string.find(toolName, name) then
                    table.insert(toolsToDelete, tool)
                    break
                end
            end
        end
    end

    for _, t in ipairs(backpack:GetChildren()) do checkAndAdd(t) end
    for _, t in ipairs(char:GetChildren()) do checkAndAdd(t) end

    for _, tool in ipairs(toolsToDelete) do
        pcall(function()
            humanoid:EquipTool(tool)
            task.wait(0.1)
            Comm.DeleteHeldItem:FireServer()
            task.wait(0.1)
        end)
    end
end

local Window = Rayfield:CreateWindow({
   Name = "Zenith Hub",
   LoadingTitle = "Zenith Hub",
   LoadingSubtitle = "YGT Premium Automation",
   ConfigurationSaving = {Enabled = false},
   KeySystem = false,
   Keybind = Enum.KeyCode.LessThan
})

local TabStats = Window:CreateTab("Live Stats", 4483362458)
local TabFarm = Window:CreateTab("Auto-Farming", 4483362458)
local TabPlant = Window:CreateTab("Auto-Plant", 4483362458)
local TabUpgrades = Window:CreateTab("Upgrades", 4483362458)
local TabRolling = Window:CreateTab("Seed Rolling", 4483362458)
local TabInventory = Window:CreateTab("Auto-Sell", 4483362458)
local TabSettings = Window:CreateTab("Settings", 4483362458)

-- TAB 0 LIVE STATS (CANLI İSTATİSTİKLER)
TabStats:CreateSection("Zenith Session Tracker")

local LblTime = TabStats:CreateLabel("Session Time: 00:00:00")
local LblBalance = TabStats:CreateLabel("Current Balance: $0")
local LblPlants = TabStats:CreateLabel("Script Planted: 0")
local LblRolls = TabStats:CreateLabel("Script Rolls: 0")

task.spawn(function()
    while task.wait(1) do
        -- Süre Hesaplama
        local currentTime = os.time()
        local joinTime = LocalPlayer:GetAttribute("JoinTime") or currentTime
        local elapsed = math.floor(currentTime - joinTime)
        local hours = math.floor(elapsed / 3600)
        local mins = math.floor((elapsed % 3600) / 60)
        local secs = elapsed % 60
        LblTime:Set(string.format("Session Time: %02d:%02d:%02d", hours, mins, secs))

        -- Para Hesaplama
        local cashFolder = LocalPlayer:FindFirstChild("leaderstats")
        local cashVal = cashFolder and cashFolder:FindFirstChild("Cash")
        local cash = cashVal and cashVal.Value or 0
        
        -- Sayıyı virgülle ayırma formatı (Premium görünüm)
        local formattedCash = tostring(cash):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
        LblBalance:Set("Current Balance: $" .. formattedCash)

        -- Script Hafızası
        LblPlants:Set("Script Planted: " .. tostring(sessionStats.Planted))
        LblRolls:Set("Script Rolls: " .. tostring(sessionStats.Rolls))
    end
end)

-- TAB 1 AUTO-FARMING 
TabFarm:CreateSection("Primary Farming Actions")

TabFarm:CreateToggle({
   Name = "Auto Click Plants",
   CurrentValue = false,
   Flag = "t_click",
   Callback = function(Value)
      _T.AutoClick = Value
      task.spawn(function()
          while _T.AutoClick do
              pcall(function()
                  local plot = PlotsFolder:FindFirstChild(playerName)
                  if plot then
                      for _, tile in ipairs(plot.Tiles:GetChildren()) do
                          if not _T.AutoClick then break end
                          Comm.ClickPlant:FireServer(tile)
                          task.wait() -- LİMİT KALDIRILDI (FPS HIZI)
                      end
                  end
              end)
              task.wait() -- DÖNGÜ GECİKMESİ KALDIRILDI
          end
      end)
   end,
})

TabFarm:CreateToggle({
   Name = "Auto Sell Harvested Crates",
   CurrentValue = false,
   Flag = "t_sell",
   Callback = function(Value)
      _T.AutoSellCrates = Value
      task.spawn(function()
          while _T.AutoSellCrates do
              pcall(function() Comm.SellCrate:FireServer() end)
              task.wait(1.5)
          end
      end)
   end,
})

TabFarm:CreateParagraph({
   Title = "ℹ️ Farming Details",
   Content = "Auto Click Plants: Auto clicks all plants on your plot to harvest them instantly.\n\nAuto Sell Harvested Crates: Auto sells harvested plants for money."
})

-- TAB 2 AUTO-PLANT
TabPlant:CreateSection("Seed Planting")

TabPlant:CreateToggle({
   Name = "Auto Plant Common to Rare Seeds",
   CurrentValue = false,
   Flag = "t_plant1",
   Callback = function(Value)
      _T.AutoPlantTier1 = Value
      task.spawn(function()
          while _T.AutoPlantTier1 do
              pcall(function()
                  local plot = PlotsFolder:FindFirstChild(playerName)
                  if plot then
                      local emptyTiles = {}
                      for _, tile in ipairs(plot.Tiles:GetChildren()) do
                          if #tile:GetChildren() == 0 then table.insert(emptyTiles, tile) end
                      end

                      if #emptyTiles > 0 and EquipToolFromList(Tier1Seeds) then
                          for _, tile in ipairs(emptyTiles) do
                              if not _T.AutoPlantTier1 then break end
                              Comm.Plant:FireServer(tile)
                              sessionStats.Planted = sessionStats.Planted + 1
                              task.wait() -- LİMİT KALDIRILDI
                          end
                      end
                  end
              end)
              task.wait() -- DÖNGÜ GECİKMESİ KALDIRILDI
          end
      end)
   end,
})

TabPlant:CreateToggle({
   Name = "Auto Plant Epic to God Seeds",
   CurrentValue = false,
   Flag = "t_plant2",
   Callback = function(Value)
      _T.AutoPlantTier2 = Value
      task.spawn(function()
          while _T.AutoPlantTier2 do
              pcall(function()
                  local plot = PlotsFolder:FindFirstChild(playerName)
                  if plot then
                      local emptyTiles = {}
                      for _, tile in ipairs(plot.Tiles:GetChildren()) do
                          if #tile:GetChildren() == 0 then table.insert(emptyTiles, tile) end
                      end

                      if #emptyTiles > 0 and EquipToolFromList(Tier2Seeds) then
                          for _, tile in ipairs(emptyTiles) do
                              if not _T.AutoPlantTier2 then break end
                              Comm.Plant:FireServer(tile)
                              sessionStats.Planted = sessionStats.Planted + 1
                              task.wait() -- LİMİT KALDIRILDI
                          end
                      end
                  end
              end)
              task.wait() -- DÖNGÜ GECİKMESİ KALDIRILDI
          end
      end)
   end,
})

TabPlant:CreateToggle({
   Name = "Auto Plant All Seeds",
   CurrentValue = false,
   Flag = "t_plantall",
   Callback = function(Value)
      _T.AutoPlantAll = Value
      task.spawn(function()
          while _T.AutoPlantAll do
              pcall(function()
                  local plot = PlotsFolder:FindFirstChild(playerName)
                  if plot then
                      local emptyTiles = {}
                      for _, tile in ipairs(plot.Tiles:GetChildren()) do
                          if #tile:GetChildren() == 0 then table.insert(emptyTiles, tile) end
                      end

                      if #emptyTiles > 0 and EquipToolFromList(AllSeeds) then
                          for _, tile in ipairs(emptyTiles) do
                              if not _T.AutoPlantAll then break end
                              Comm.Plant:FireServer(tile)
                              sessionStats.Planted = sessionStats.Planted + 1
                              task.wait() -- LİMİT KALDIRILDI
                          end
                      end
                  end
              end)
              task.wait() -- DÖNGÜ GECİKMESİ KALDIRILDI
          end
      end)
   end,
})

TabPlant:CreateParagraph({
   Title = "ℹ️ Auto Plant Details",
   Content = "Auto Plant Common to Rare Seeds: Auto equips and plants your tier one seeds onto empty tiles.\n\nAuto Plant Epic to God Seeds: Auto equips and plants your tier two (including God) seeds onto empty tiles.\n\nAuto Plant All Seeds: Auto equips and plants any available seeds onto empty tiles."
})

-- TAB 3 UPGRADES 
TabUpgrades:CreateSection("Progression and Mastery")

TabUpgrades:CreateToggle({
   Name = "Infinite Prestige Loop",
   CurrentValue = false,
   Flag = "t_prestige",
   Callback = function(Value)
      _T.PrestigeLoop = Value
      task.spawn(function()
          while _T.PrestigeLoop do
              pcall(function()
                  Comm.BuyUpgrade:FireServer("UpgradeCaps")
                  task.wait(0.1)
                  Comm.BuyUpgrade:FireServer("MutationMultiplier")
                  task.wait(0.1)
                  Comm.BuyUpgrade:FireServer("Click")
                  Comm.BuyUpgrade:FireServer("SeedLuck")
                  Comm.BuyUpgrade:FireServer("SprinkerPower")
                  Comm.BuyUpgrade:FireServer("Rolls")
              end)
              task.wait(1.5)
          end
      end)
   end,
})

TabUpgrades:CreateToggle({
   Name = "Auto Buy All Upgrades",
   CurrentValue = false,
   Flag = "t_buyall",
   Callback = function(Value)
      _T.BuyAll = Value
      task.spawn(function()
          while _T.BuyAll do
              pcall(function()
                  for _, upg in ipairs(BoardUpgrades) do Comm.BuyUpgrade:FireServer(upg); task.wait(0.1) end
                  for _, upg in ipairs(HoneyUpgrades) do Comm.BuyHoneyUpgrade:FireServer(upg); task.wait(0.1) end
                  Comm.BuyHive:FireServer()
              end)
              task.wait(1.5)
          end
      end)
   end,
})

TabUpgrades:CreateToggle({
   Name = "Auto Claim Star Upgrades",
   CurrentValue = false,
   Flag = "t_autostar",
   Callback = function(Value)
      _T.AutoStar = Value
      task.spawn(function()
          while _T.AutoStar do
              pcall(function() for i = 1, 60 do Comm.ClaimStarUpgrade:FireServer(i); task.wait(0.05) end end)
              task.wait(5) 
          end
      end)
   end,
})

TabUpgrades:CreateParagraph({
   Title = "ℹ️ Upgrade Details",
   Content = "Infinite Prestige Loop: Auto breaks your level cap and instantly buys back all your core stats.\n\nAuto Buy All Upgrades: Auto purchases all board upgrades and honey boosts and auto buys new hives.\n\nAuto Claim Star Upgrades: Auto cycles through the menus and claims every single star mastery tier you have unlocked."
})

-- TAB 4 SEED ROLLING 
TabRolling:CreateSection("Targeted Rolling")

local DropdownSeeds = TabRolling:CreateDropdown({
   Name = "Target Seeds",
   Options = AllSeeds,
   CurrentOption = {},
   MultipleOptions = true,
   Flag = "d_seeds",
   Callback = function(Options) TargetSeeds = Options end,
})

TabRolling:CreateToggle({
   Name = "Target Auto Roll and Buy",
   CurrentValue = false,
   Flag = "t_roll",
   Callback = function(Value)
      _T.AutoRoll = Value
      task.spawn(function()
          while _T.AutoRoll do
              local success, result = pcall(function() return Comm.DoRoll:InvokeServer() end)
              if success and type(result) == "table" then
                  sessionStats.Rolls = sessionStats.Rolls + 1
                  for i, v in pairs(result) do
                      if type(v) == "table" and v.Type then
                          local rolledName = tostring(v.Type)
                          for j = 1, #TargetSeeds do
                              local cleanRolled = string.gsub(string.lower(rolledName), "%s+", "")
                              local cleanTarget = string.gsub(string.lower(TargetSeeds[j]), "%s+", "")

                              if string.find(cleanRolled, cleanTarget) then
                                  Rayfield:Notify({Title = "Target Hit and Bought", Content = "Claimed " .. rolledName, Duration = 3})
                                  pcall(function() Comm.BuySeeds:FireServer(i) end) 
                                  
                                  -- TURBO MOD: Satın aldıktan sonra 0.5 yerine 0.1 saniye bekle
                                  task.wait(0.1)
                                  break
                              end
                          end
                      end
                  end
              end
              
              -- TURBO MOD: Her çark çevirmede 0.5 yerine 0.05 saniye bekle (Işık hızı)
              task.wait(0.05)
          end
      end)
   end,
})

TabRolling:CreateButton({ Name = "Reset Seed Selection", Callback = function() TargetSeeds = {}; DropdownSeeds:Set({}) end })

TabRolling:CreateSection("General Rolling")

TabRolling:CreateButton({ Name = "Manual Instant Roll Once", Callback = function() 
    pcall(function() 
        Comm.DoRoll:InvokeServer() 
        sessionStats.Rolls = sessionStats.Rolls + 1 -- SAYAÇ EKLENDİ
    end) 
end })

TabRolling:CreateParagraph({
   Title = "ℹ️ Seed Details",
   Content = "Target Auto Roll and Buy: Auto spins the machine and attempts to purchase your specific selected seeds.\n\nManual Instant Roll Once: Auto bypasses the normal user interface timer for a fast single spin."
})

-- TAB 5 AUTO-SELL
TabInventory:CreateSection("Delete Seeds")

local DropdownDelSeeds = TabInventory:CreateDropdown({ Name = "Select Seeds to Delete", Options = AllSeeds, CurrentOption = {}, MultipleOptions = true, Flag = "del_seeds", Callback = function(Options) DeleteSeeds = Options end })
TabInventory:CreateButton({ Name = "Delete Selected Seeds", Callback = function() WipeSelectedItems(DeleteSeeds); Rayfield:Notify({Title="Cleared", Content="Seeds deleted", Duration=3}) end })
TabInventory:CreateButton({ Name = "Reset Selected Seeds", Callback = function() DeleteSeeds = {}; DropdownDelSeeds:Set({}) end })

TabInventory:CreateParagraph({ 
    Title = "ℹ️ Auto-Sell Details", 
    Content = "Delete Selected Items: Auto deletes your targeted items from your backpack to clear up space permanently. Do not use this tab if you just want to remove placed items from your physical plot." 
})

-- TAB 6 SETTINGS 
TabSettings:CreateSection("Security and Utilities")

TabSettings:CreateToggle({
   Name = "Anti AFK",
   CurrentValue = true, 
   Flag = "t_antiafk",
   Callback = function(Value) _T.AntiAFK = Value end,
})


TabSettings:CreateButton({
   Name = "Destroy Script and UI",
   Callback = function()
       _T = {}
       Rayfield:Destroy()
   end,
})

TabSettings:CreateParagraph({
   Title = "ℹ️ Security Details",
   Content = "Anti AFK: Auto captures inputs in the background to prevent Roblox from kicking you for idling.\n\nRedeem All Promo Codes: Auto redeems all active game promo codes for rewards instantly.\n\nDestroy Script and UI: Auto removes the entire cheat interface from your screen safely."
})

TabSettings:CreateSection("Premium PC Koruması")

local UserInputService = game:GetService("UserInputService")
local blackScreenGui = nil

-- Toggle'ı dışarıdan kontrol edebilmek için önce değişken olarak tanımlıyoruz
local cpuSaverToggle

cpuSaverToggle = TabSettings:CreateToggle({
   Name = "CPU/GPU Saver (Black Screen)",
   CurrentValue = false,
   Flag = "t_cpusaver",
   Callback = function(Value)
      if Value then
          -- Siyah ekran oluştur
          blackScreenGui = Instance.new("ScreenGui")
          blackScreenGui.Name = "ZewittBlackScreen"
          blackScreenGui.IgnoreGuiInset = true
          blackScreenGui.DisplayOrder = 99999
          
          local success = pcall(function() blackScreenGui.Parent = game:GetService("CoreGui") end)
          if not success then blackScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

          local bg = Instance.new("Frame")
          bg.Size = UDim2.new(1, 0, 1, 0)
          bg.BackgroundColor3 = Color3.new(0, 0, 0)
          bg.Parent = blackScreenGui

          local txt = Instance.new("TextLabel")
          txt.Size = UDim2.new(1, 0, 1, 0)
          txt.Position = UDim2.new(0, 0, -0.1, 0)
          txt.BackgroundTransparency = 1
          txt.TextColor3 = Color3.new(1, 1, 1)
          txt.TextSize = 24
          txt.Font = Enum.Font.Code
          txt.Text = "Zewitt Hub Premium - CPU/GPU Saver Active\n\nArka planda farm tam gaz devam ediyor...\nEkranı açmak için aşağıdaki butona tıkla veya 'F4' tuşuna bas."
          txt.Parent = bg

          -- Minimalist ve Şık Uyandırma Butonu
          local wakeBtn = Instance.new("TextButton")
          wakeBtn.Size = UDim2.new(0, 250, 0, 50)
          wakeBtn.Position = UDim2.new(0.5, -125, 0.6, 0)
          wakeBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
          wakeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
          wakeBtn.Font = Enum.Font.GothamBold
          wakeBtn.TextSize = 16
          wakeBtn.Text = "EKRANI UYANDIR (F4)"
          wakeBtn.Parent = bg

          local corner = Instance.new("UICorner")
          corner.CornerRadius = UDim.new(0, 6)
          corner.Parent = wakeBtn
          
          local stroke = Instance.new("UIStroke")
          stroke.Color = Color3.fromRGB(100, 100, 100)
          stroke.Thickness = 1
          stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
          stroke.Parent = wakeBtn

          -- Butona tıklama motoru (Sadece Toggle'ı kapatır, gerisini Toggle halleder)
          wakeBtn.MouseButton1Click:Connect(function()
              if cpuSaverToggle then
                  cpuSaverToggle:Set(false)
              end
          end)

          -- Grafikleri en düşüğe çek
          settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
          Rayfield:Notify({Title = "Saver Active", Content = "Screen disabled to save PC resources.", Duration = 3})
      else
          -- Toggle kapatıldığında (İster fareyle, ister butonla, ister F4 ile) temizliği burası yapar
          if blackScreenGui then blackScreenGui:Destroy() end
          settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
          Rayfield:Notify({Title = "Saver Disabled", Content = "Ekran başarıyla uyandırıldı.", Duration = 3})
      end
   end,
})

-- F4 TUŞU İLE EKRANI UYANDIRMA KISAYOLU
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.F4 then
        if blackScreenGui and blackScreenGui.Parent ~= nil then
            -- Siyah ekran açıksa, Toggle'a kapat sinyali gönder
            if cpuSaverToggle then
                cpuSaverToggle:Set(false)
            end
        end
    end
end)

local TeleportService = game:GetService("TeleportService")
TabSettings:CreateToggle({
   Name = "Auto Rejoin (Crash Recovery)",
   CurrentValue = false,
   Flag = "t_rejoin",
   Callback = function(Value)
       _T.AutoRejoin = Value
   end,
})

TabSettings:CreateButton({
   Name = "Manual Rejoin (Hemen Bağlan)",
   Callback = function()
       Rayfield:Notify({Title = "Yeniden Bağlanılıyor", Content = "Mevcut sunucuya tekrar giriş yapılıyor, lütfen bekle...", Duration = 5})
       
       -- Bağlantıyı koparıp aynı sunucuya (JobId) anında geri fırlatır
       task.spawn(function()
           task.wait(0.5)
           local TeleportService = game:GetService("TeleportService")
           TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
       end)
   end,
})

TabSettings:CreateParagraph({
   Title = "ℹ️ Premium Koruma Detayları",
   Content = "CPU/GPU Saver: Oyunu tamamen siyah bir ekrana çevirir ve grafikleri en düşüğe çeker. Ekran kartını dondurucu soğuklukta tutar.\n\nAuto Rejoin: İnternet veya sunucu koparsa 5 saniye bekleyip oyuna otomatik geri bağlanır."
})

-- OTOMATİK YENİDEN BAĞLANMA (AUTO REJOIN) MOTORU
task.spawn(function()
    local promptOverlay = game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui")
    if promptOverlay then
        local overlay = promptOverlay:FindFirstChild("promptOverlay")
        if overlay then
            overlay.ChildAdded:Connect(function(child)
                if _T.AutoRejoin and child.Name == 'ErrorPrompt' then
                    -- Ekranda bağlantı koptu hatası çıkarsa 5 saniye bekle ve aynı sunucuya tekrar zıpla
                    task.wait(5)
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                end
            end)
        end
    end
end)

-- 20 SANİYELİK KESİN ZIPLAMA VE ANTI-AFK MOTORU
task.spawn(function()
    local VirtualUser = game:GetService("VirtualUser")
    
    -- Oyunun AFK atmasını engelleyen sanal tıklama
    LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)

    -- Her 20 saniyede bir zorunlu zıplama döngüsü
    while task.wait(60) do 
        if _T.AntiAFK then
            pcall(function()
                -- Karakteri her döngüde yeniden bul (ölme veya rejoin durumunda bozulmaması için)
                local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        -- Hem normal komutu hem de fiziksel state komutunu aynı anda yolluyoruz
                        hum.Jump = true
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
        end
    end
end)

Players.LocalPlayer.Idled:Connect(function()
    if _T.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)
