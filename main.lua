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
    AutoRoll = false, AntiAFK = true
}

local TargetSeeds = {}
local DeleteSeeds = {}

local Tier1Seeds = {"Strawberry Seeds", "Carrot Seeds", "Tomato Seeds", "Corn Seeds", "Blueberry Seeds", "Potato Seeds"}
local Tier2Seeds = {"Sugarcane Seeds", "Watermelon Seeds", "Blackberry Seeds", "Beet Seeds", "Kiwi Seeds", "Pineapple Seeds", "Prickly Pear Seeds"}
local AllSeeds = {"Strawberry Seeds", "Carrot Seeds", "Tomato Seeds", "Corn Seeds", "Blueberry Seeds", "Potato Seeds", "Sugarcane Seeds", "Watermelon Seeds", "Blackberry Seeds", "Beet Seeds", "Kiwi Seeds", "Pineapple Seeds", "Prickly Pear Seeds"}
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

    local function checkAndEquip(parent)
        for _, tool in ipairs(parent:GetChildren()) do
            if tool:IsA("Tool") then
                local toolName = string.lower(tool.Name)
                for _, name in ipairs(lowerList) do
                    if string.find(toolName, name) then
                        humanoid:EquipTool(tool)
                        return true
                    end
                end
            end
        end
        return false
    end

    return checkAndEquip(backpack) or checkAndEquip(char)
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
   LoadingSubtitle = "Premium Automation",
   ConfigurationSaving = {Enabled = false},
   KeySystem = false,
   Keybind = Enum.KeyCode.LessThan
})

local TabFarm = Window:CreateTab("Auto-Farming", 4483362458)
local TabPlant = Window:CreateTab("Auto-Plant", 4483362458)
local TabUpgrades = Window:CreateTab("Upgrades", 4483362458)
local TabRolling = Window:CreateTab("Seed Rolling", 4483362458)
local TabInventory = Window:CreateTab("Auto-Sell", 4483362458)
local TabSettings = Window:CreateTab("Settings", 4483362458)

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
                          task.wait(0.03)
                      end
                  end
              end)
              task.wait(0.1)
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
                  if plot and EquipToolFromList(Tier1Seeds) then
                      for _, tile in ipairs(plot.Tiles:GetChildren()) do
                          if #tile:GetChildren() == 0 then Comm.Plant:FireServer(tile) end
                      end
                  end
              end)
              task.wait(1)
          end
      end)
   end,
})

TabPlant:CreateToggle({
   Name = "Auto Plant Epic to Secret Seeds",
   CurrentValue = false,
   Flag = "t_plant2",
   Callback = function(Value)
      _T.AutoPlantTier2 = Value
      task.spawn(function()
          while _T.AutoPlantTier2 do
              pcall(function()
                  local plot = PlotsFolder:FindFirstChild(playerName)
                  if plot and EquipToolFromList(Tier2Seeds) then
                      for _, tile in ipairs(plot.Tiles:GetChildren()) do
                          if #tile:GetChildren() == 0 then Comm.Plant:FireServer(tile) end
                      end
                  end
              end)
              task.wait(1)
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
                  if plot and EquipToolFromList(AllSeeds) then
                      for _, tile in ipairs(plot.Tiles:GetChildren()) do
                          if #tile:GetChildren() == 0 then Comm.Plant:FireServer(tile) end
                      end
                  end
              end)
              task.wait(1)
          end
      end)
   end,
})

TabPlant:CreateParagraph({
   Title = "ℹ️ Auto Plant Details",
   Content = "Auto Plant Common to Rare Seeds: Auto equips and plants your tier one seeds onto empty tiles.\n\nAuto Plant Epic to Secret Seeds: Auto equips and plants your tier two seeds onto empty tiles.\n\nAuto Plant All Seeds: Auto equips and plants any available seeds onto empty tiles."
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
                  for i, v in pairs(result) do
                      if type(v) == "table" and v.Type then
                          local rolledName = tostring(v.Type)
                          for j = 1, #TargetSeeds do
                              if rolledName:find(TargetSeeds[j]) then
                                  Rayfield:Notify({Title = "Target Hit and Bought", Content = "Claimed " .. rolledName, Duration = 3})
                                  pcall(function() Comm.BuySeeds:FireServer(i) end) 
                                  task.wait(0.5)
                                  break
                              end
                          end
                      end
                  end
              end
              task.wait(0.5)
          end
      end)
   end,
})

TabRolling:CreateButton({ Name = "Reset Seed Selection", Callback = function() TargetSeeds = {}; DropdownSeeds:Set({}) end })

TabRolling:CreateSection("General Rolling")

TabRolling:CreateButton({ Name = "Manual Instant Roll Once", Callback = function() pcall(function() Comm.DoRoll:InvokeServer() end) end })

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
   Name = "Redeem All Promo Codes",
   Callback = function()
       pcall(function()
           Comm.RedeemCode:InvokeServer("BUZZ BUZZ")
           Rayfield:Notify({Title = "Codes Redeemed", Content = "Successfully triggered all current game codes", Duration = 3})
       end)
   end,
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

Players.LocalPlayer.Idled:Connect(function()
    if _T.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)
