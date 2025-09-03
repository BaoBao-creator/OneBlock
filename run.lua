-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
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
local function click()
    VirtualUser:ClickButton1(Vector2.new())
end
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
local function isequip(name)
    return character:FindFirstChild(name) ~= nil
end
local function isblock(obj)
    return obj:FindFirstChild("BlockInfo") ~= nil
end
local function isdrop(obj)
    if obj:IsA("Model") and obj:FindFirstChild("INFO") and obj:GetAttribute("UUID") then return true end
    return false
end
local function mine(block)
    currentblock = block
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
        if not isequip(toolname) then 
            holditem(tool)
        end
        click()
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
end
local function loot(drop)
    local uuid = drop:GetAttribute("UUID")
    ReplicatedStorage.RequestLootPickup:InvokeServer(uuid)
    task.wait(0.1)
    ReplicatedStorage.LootDestroyed:FireServer(uuid)
end
local function updateconnection()
    if looting and not workspaceconnection then
        workspaceconnection = Workspace.ChildAdded:Connect(function(obj)
            if looting and isdrop(obj) then
                loot(obj)
            end
        end)
    elseif not looting and workspaceconnection then
        workspaceconnection:Disconnect()
        workspaceconnection = nil
    end
end
local function automine(state)
    mining = state
    if mining then
        task.spawn(function()
            if currentblock then
                mine(currentblock)
            end
            while mining do
                for _, obj in ipairs(Workspace:GetChildren()) do
                    if isblock(obj) then
                        mine(obj)
                        break
                    end
                end
                task.wait(0.2)
            end
        end)
    end
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
