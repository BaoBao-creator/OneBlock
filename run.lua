-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VIM = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
-- Data
local LocalPlayer = Players.LocalPlayer
local PlayerName = LocalPlayer.Name
local character = LocalPlayer.Character
local humanoid = character.Humanoid
local hrp = character.HumanoidRootPart
local hitdelay = 0.2
local tools = {
    pickaxe = "Stone Pickaxe",
    axe = "Stone Axe",
    shovel = "Stone Shovel",
    weapon = "Stone Sword"
} 
local backpackfolder = LocalPlayer.Backpack
local islandlist = {"Spawn", "LargeIsland1", "LagerIsland2", "LargeIsland3", "LargeIsland4", "SmallIsland1", "SmallIsland2", "SmallIsland3", "SmallIsland4"}
-- Toggles
local mining = false
local looting = false
-- Connections
local workspaceconnection
-- Functions
local function hit(mob)
    local weaponname = tools[weapon]
-- workspace.luxurysigma["Stone Sword"].ToolHit:FireServer("Stone Sword",{{["isNPC"] = true,["character"] = workspace.Zombie1,["health"] = 100,["position"] = ,["maxHealth"] = 100,["humanoidRootPart"] = workspace.Zombie1.HumanoidRootPart,["humanoid"] = workspace.Zombie1.Humanoid}})
--workspace.luxurysigma["Stone Sword"].ToolHit:FireServer("Stone Sword",{{["isNPC"] = true,["character"] = workspace.AngryMiner1,["health"] = 100,["position"] = ,["maxHealth"] = 100,["humanoidRootPart"] = workspace.AngryMiner1.HumanoidRootPart,["humanoid"] = workspace.AngryMiner1.Humanoid},{["isNPC"] = true,["character"] = workspace.Zombie1,["health"] = 85,["position"] = ,["maxHealth"] = 100,["humanoidRootPart"] = workspace.Zombie1.HumanoidRootPart,["humanoid"] = workspace.Zombie1.Humanoid}})
--workspace[PlayerName][weaponname].ToolHit:FireServer(weaponname, {{["isNPC"] = true, ["character"] = mob, ["health"] = health
end
local function tweenTP(targetPos)
    local distance = (targetPos - hrp.Position).Magnitude
    local speed = 50
    local time = distance / speed
    local tween = TweenService:Create(
        hrp,
        TweenInfo.new(time, Enum.EasingStyle.Linear),
        {CFrame = CFrame.new(targetPos)}
    )
    tween:Play()
    tween.Completed:Wait()
end
local function tpis(name)
    if name == "Spawn" then
        tweenTP(Vector3.new(0, 20, 0))
        return
    end
    local island = workspace:FindFirstChild(name)
    if island and island:IsA("Model") then
        tweenTP(island.WorldPivot.Position + Vector3.new(0, 20, 0))
    end
end
local function click()
    VIM:SendMouseButtonEvent(9999, 9999, 0, true, game, 0)
    task.wait()
    VIM:SendMouseButtonEvent(9999, 9999, 0, false, game, 0)
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
    return workspace[PlayerName]:FindFirstChild(name) ~= nil
end
local function isblock(obj)
    return obj:FindFirstChild("BlockInfo") ~= nil
end
local function isdrop(obj)
    if obj:IsA("Model") and obj:FindFirstChild("INFO") and obj:GetAttribute("UUID") then return true end
    return false
end
local function mine(block)
    local tooltype = getrighttool(block)
    local toolname = tools[tooltype]
    local tool
    if isequip(toolname) then
        tool = character:FindFirstChild(toolname)
    else
        tool = backpackfolder:FindFirstChild(toolname)
    end
    local blockinfo = block.BlockInfo
    local maxhealth = blockinfo.MaxHealth
    local health = blockinfo.Health
    local hardness = blockinfo.BlockHardness.Value
    local position = block.WorldPivot.Position
    local maxhealthvalue = maxhealth.Value
    local healthbar = block.HealthBar
    while block and block.Parent == Workspace do
        if not mining then return end
        if not isequip(toolname) then
            holditem(tool)
        end
        click()
        Workspace[PlayerName][toolname].ToolHit:FireServer({{
            ["healthValue"] = health,
            ["blockInfoFolder"] = blockinfo,
            ["position"] = position,
            ["object"] = block,
            ["maxHealthValue"] = maxhealth,
            ["maxHealth"] = maxhealthvalue,
            ["healthBarGui"] = healthbar,
            ["hardness"] = hardness,
            ["health"] = health.Value
        }}, toolname)
        task.wait(hitdelay)
    end
end
local function loot(drop)
    local uuid = drop:GetAttribute("UUID")
    if uuid then
        local success = pcall(function()
            return ReplicatedStorage.RequestLootPickup:InvokeServer(uuid)
        end)
        if success then
            pcall(function()
                ReplicatedStorage.LootDestroyed:FireServer(uuid)
            end)
            task.delay(1, function()
                if drop and drop.Parent == Workspace then
                    drop:Destroy()
                end
            end)
        end
    end
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
local TeleportTab = Window:CreateTab("Teleport", 0)
local IslandToTeleportDropdown = TeleportTab:CreateDropdown({
    Name = "Island To Teleport",
    Options = islandlist,
    CurrentOption = "Spawn",
    MultipleOptions = false,
    Flag = "IslandDropdown", 
    Callback = function(v)
        tpis(v)
    end
})
