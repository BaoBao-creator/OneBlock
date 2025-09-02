-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- Data
local LocalPlayer = Players.LocalPlayer
local PlayerName = LocalPlayer.Name

-- Toggles
local mining = false
local looting = false
local toolName = ""

-- Connections
local workspaceConnection

-- Functions
local function mine(toolName, block)
    local blockInfo = block.BlockInfo
    local maxHealth = blockInfo.MaxHealth

    Workspace[PlayerName][toolName].ToolHit:FireServer({{
        ["healthValue"]    = blockInfo.Health,
        ["blockInfoFolder"] = blockInfo,
        ["position"]        = block.WorldPivot.Position,
        ["object"]          = block,
        ["maxHealthValue"]  = maxHealth,
        ["maxHealth"]       = maxHealth.Value,
        ["healthBarGui"]    = block.HealthBar,
        ["hardness"]        = blockInfo.BlockHardness.Value,
        ["health"]          = blockInfo.Health.Value
    }}, toolName)
end

local function loot(drop)
    local uuid = drop:GetAttribute("UUID")
    ReplicatedStorage.RequestLootPickup:InvokeServer(uuid)
    ReplicatedStorage.LootDestroyed:FireServer(uuid)
end

local function updateConnection()
    if (mining or looting) and not workspaceConnection then
        workspaceConnection = Workspace.ChildAdded:Connect(function(obj)
            if mining and obj:IsA("Model") and obj:FindFirstChild("BlockInfo") then
                mine(toolName, obj)
            elseif looting and obj:IsA("Model") and obj:FindFirstChild("Info") then
                loot(obj)
            end
        end)
    elseif not mining and not looting and workspaceConnection then
        workspaceConnection:Disconnect()
        workspaceConnection = nil
    end
end

local function autoMine(state)
    mining = state
    if mining then
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("Model") and obj:FindFirstChild("BlockInfo") then
                mine(toolName, obj)
            end
        end
    end
    updateConnection()
end

local function autoLoot(state)
    looting = state
    if looting then
        for _, drop in ipairs(Workspace:GetChildren()) do
            if drop:IsA("Model") and drop:FindFirstChild("Info") and drop:GetAttribute("UUID") then
                loot(drop)
            end
        end
    end
    updateConnection()
end
