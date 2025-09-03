-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
-- Data
local LocalPlayer = Players.LocalPlayer
local PlayerName = LocalPlayer.Name
local character = LocalPlayer.Character
local humanoid = character.Humanoid
local currentblock = nil
local hitdelay = 0.2
local tools = {
    pickaxe = "Stone Pickaxe",
    axe = "Stone Axe",
    shovel = "Stone Shovel"
} 
local backpackfolder = LocalPlayer.Backpack
-- Toggles
local mining = false
local looting = false
-- Connections
local workspaceconnection
-- Functions
local function holditem(tool)
    humanoid:EquipTool(tool)
end
local function getbackpackitem()
    local names = {}
    for _, i in ipairs(backpackfolder:GetChildren()) do
        table.insert(names, i.Name)
    end
    return names
end
local backpack = getbackpackitem()
local function getrighttool(model)
    return ({
        ["rbxassetid://128935722146837"] = "shovel",
        ["rbxassetid://113939170676272"] = "pickaxe",
        ["rbxassetid://96101344191937"] = "axe"
    })[model.HealthBar.Frame.ImageLabel.Image] or "Unknown"
end
local function isblock(obj)
    if obj:IsA("Model") and obj:FindFirstChild("BlockInfo") then return true end
    return false
end
local function isdrop(obj)
    if obj:IsA("Model") and obj:FindFirstChild("INFO") and obj:GetAttribute("UUID") then return true end
    return false
end
local function mine(block)
    print("[mine] Called with block:", block.Name)
    currentblock = block
    task.spawn(function()
        print("[mine] Task started for block:", block.Name)

        local toolname = tools[getrighttool(block)]
        local tool = backpackfolder[toolname]
        print("[mine] Tool selected:", toolname, tool and "Tool exists" or "Tool is nil")

        local blockinfo = block.BlockInfo
        local maxhealth = blockinfo.MaxHealth
        local health = blockinfo.Health
        local position = block.WorldPivot.Position
        local maxhealthvalue = maxhealth.Value
        local healthbar = block.HealthBar
        local hardness = blockinfo.BlockHardness.Value

        print("[mine] Block info loaded. MaxHealth:", maxhealthvalue, "Hardness:", hardness)

        while block and block.Parent == workspace do
            if not mining then
                print("[mine] Mining stopped, exiting loop")
                return
            end

            holditem(tool)
            print("[mine] Holding tool:", toolname, "Hitting block:", block.Name, "Health:", health.Value)

            Workspace[PlayerName][toolname].ToolHit:FireServer({{
                ["healthValue"]    = health,
                ["blockInfoFolder"] = blockinfo,
                ["position"]        = position,
                ["object"]          = block,
                ["maxHealthValue"]  = maxhealth,
                ["maxHealth"]       = maxhealthvalue,
                ["healthBarGui"]    = healthbar,
                ["hardness"]        = hardness,
                ["health"]          = health.Value
            }}, toolname)

            task.wait(hitdelay)
        end

        print("[mine] Block destroyed or removed:", block.Name)
        currentblock = nil
    end)
end
local function automine(state)
    print("[automine] Called with state =", state)
    mining = state
    if mining then
        print("[automine] Mining started")
        if currentblock then
            print("[automine] Current block exists, mining it:", currentblock.Name)
            mine(currentblock)
        else
            print("[automine] No current block, searching in Workspace...")
            for _, obj in ipairs(Workspace:GetChildren()) do
                if isblock(obj) then
                    print("[automine] Found block:", obj.Name)
                    mine(obj)
                    break
                end
            end
        end
    else
        print("[automine] Mining stopped")
    end
    updateconnection()
    print("[automine] Finished function")
end
local function mmine(block)
    currentblock = block
    task.spawn(function()
        local toolname = tools[getrighttool(block)]
        local tool = backpackfolder[toolname]
        local blockinfo = block.BlockInfo
        local maxhealth = blockinfo.MaxHealth
        local health = blockinfo.Health
        local position = block.WorldPivot.Position
        local maxhealthvalue = maxhealth.Value
        local healthbar = block.HealthBar
        local hardness = blockinfo.BlockHardness.Value
        while block and block.Parent == workspace do
            if not mining then return end
            holditem(tool)
            Workspace[PlayerName][toolname].ToolHit:FireServer({{
                ["healthValue"]    = health,
                ["blockInfoFolder"] = blockinfo,
                ["position"]        = position,
                ["object"]          = block,
                ["maxHealthValue"]  = maxhealth,
                ["maxHealth"]       = maxhealthvalue,
                ["healthBarGui"]    = healthbar,
                ["hardness"]        = hardness,
                ["health"]          = health.Value
            }}, toolname)
            task.wait(hitdelay)
        end
        currentblock = nil
    end)
end
local function loot(drop)
    local uuid = drop:GetAttribute("UUID")
    ReplicatedStorage.LootDestroyed:FireServer(uuid)
    ReplicatedStorage.RequestLootPickup:InvokeServer(uuid)
end
local function updateconnection()
    if (mining or looting) and not workspaceconnection then
        print("addconnect")
        workspaceconnection = Workspace.ChildAdded:Connect(function(obj)
            if mining and isblock(obj) then
                print("newblock added")
                mine(obj)
            elseif looting and isdrop(obj) then
                loot(obj)
            end
        end)
    elseif not mining and not looting and workspaceconnection then
        print("remove connect")
        workspaceconnection:Disconnect()
        workspaceconnection = nil
    end
end
local function mautomine(state)
    mining = state
    if mining then
        if currentblock then
            mine(currentblock)
        else
            for _, obj in ipairs(Workspace:GetChildren()) do
                if isblock(obj) then
                    mine(obj)
                    break
                end
            end
        end
    end
    updateconnection()
end
local function autoloot(state)
    looting = state
    if looting then
        for _, drop in ipairs(Workspace:GetChildren()) do
            if isdrop(drop) then
                loot(drop)
            end
        end
    end
    updateconnection()
end
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Simple Hub",
    LoadingTitle = "Welcome!",
    LoadingSubtitle = "by BaoBao",
    ShowText = "UI",
    Theme = "Bloom",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "SimpleHub_OneBlock Config"
    }
})
local FarmTab = Window:CreateTab("Farm", 0)
local AutoMineBlockToggle = FarmTab:CreateToggle({
    Name = "Auto Mine Block",
    Flag = "AutoMineBlockToggle",
    Callback = function(v)
        automine(v)
    end
})
local HitDelaySlider = FarmTab:CreateSlider({
    Name = "Hit Delay",
    Range = {0.1, 1},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = 0.2,
    Flag = "HitDelaySlider",
    Callback = function(v)
        hitdelay = v
    end
})
local PickaxeDropdown = FarmTab:CreateDropdown({
    Name = "Pickaxe To Use",
    Options = backpack,
    CurrentOption = "Stone Pickaxe",
    MultipleOptions = false,
    Flag = "PickaxeDropdown", 
    Callback = function(v)
        tools["pickaxe"] = v
    end
})
local AxeDropdown = FarmTab:CreateDropdown({
    Name = "Axe To Use",
    Options = backpack,
    CurrentOption = "Stone Axe",
    MultipleOptions = false,
    Flag = "AxeDropdown", 
    Callback = function(v)
        tools["axe"] = v
    end
})
local ShovelDropdown = FarmTab:CreateDropdown({
    Name = "Shovel To Use",
    Options = backpack,
    CurrentOption = "Stone Shovel",
    MultipleOptions = false,
    Flag = "ShovelDropdown", 
    Callback = function(v)
        tools["shovel"] = v
    end
})
local RefreshBackpackButton = FarmTab:CreateButton({
    Name = "Refresh Backpack",
    Callback = function()
        backpack = getbackpackitem()
        PickaxeDropdown:Refresh(backpack)
        AxeDropdown:Refresh(backpack)
        ShovelDropdown:Refresh(backpack)
    end
})
local AutoCollectDropToggle = FarmTab:CreateToggle({
    Name = "Auto Collect Drops",
    Flag = "AutoCollectDropToggle",
    Callback = function(v)
        autoloot(v)
    end
})
