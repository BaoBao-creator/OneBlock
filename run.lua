-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
-- Data
local LocalPlayer = Players.LocalPlayer
local PlayerName = LocalPlayer.Name
local toolname = nil
-- Toggles
local mining = false
local looting = false
-- Connections
local workspaceconnection
-- Functions
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
    local blockinfo = block.BlockInfo
    local maxhealth = blockIinfo.MaxHealth
    local health = blockinfo.Health
    local position = block.WorldPivot.Position
    local maxhealthvalue = maxhealth.Value
    local healthbar = block.HealthBar
    local hardness = blockinfo.BlockHardness.Value
    while block and block.Parent == workspace do
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
        task.wait(0.2)
    end
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
        for _, obj in ipairs(Workspace:GetChildren()) do
            if isblock(obj) then
                mine(obj)
            end
        end
    end
    updateconnection()
end
local function autoLoot(state)
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
