-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
-- Data
local LocalPlayer = Players.LocalPlayer
local PlayerName = LocalPlayer.Name
local toolname = nil
local currentblock = nil
local hitdelay = 0.2
-- Toggles
local mining = false
local looting = false
-- Connections
local workspaceconnection
-- Functions
local function getrighttool(model)
    return ({
        ["rbxassetid://128935722146837"] = "Shovel",
        ["rbxassetid://113939170676272"] = "Pickaxe",
        ["rbxassetid://96101344191937"] = "Axe"
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
    if not toolname then return end
    currentblock = block
    local blockinfo = block.BlockInfo
    local maxhealth = blockinfo.MaxHealth
    local health = blockinfo.Health
    local position = block.WorldPivot.Position
    local maxhealthvalue = maxhealth.Value
    local healthbar = block.HealthBar
    local hardness = blockinfo.BlockHardness.Value
    while block and block.Parent == workspace do
        if not mining then return end
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
    ReplicatedStorage.LootDestroyed:FireServer(uuid)
end
local function updateconnection()
    if (mining or looting) and not workspaceconnection then
        workspaceconnection = Workspace.ChildAdded:Connect(function(obj)
            if mining and isblock(obj) then
                mine(obj)
            elseif looting and isdrop(obj) then
                loot(obj)
            end
        end)
    elseif not mining and not looting and workspaceconnection then
        workspaceconnection:Disconnect()
        workspaceconnection = nil
    end
end
local function automine(state)
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
local AutoCollectDropToggle = FarmTab:CreateToggle({
    Name = "Auto Collect Drops",
    Flag = "AutoCollectDropToggle",
    Callback = function(v)
        autoloot(v)
    end
})
