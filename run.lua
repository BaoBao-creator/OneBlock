-- Services
local replicatedstorage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
-- Data
local localplayer = players.LocalPlayer
local playername = localplayer.Name
-- Connections
local workspaceconnection = false
local function mine(toolname, block)
  local blockinfo = block.BlockInfo
  local maxhealth = blockinfo.MaxHealth
  workspace[playername][toolname].ToolHit:FireServer({{["healthValue"] = blockinfo.Health,["blockInfoFolder"] = blockinfo,["position"] = block.WorldPivot.Position,["object"] = block,["maxHealthValue"] = maxhealth,["maxHealth"] = maxhealth.Value,["healthBarGui"] = block.HealthBar,["hardness"] = blockinfo.BlockHardness.Value,["health"] = blockinfo.Health.Value}}, toolname)
end
local function loot(drop)
  local uuid = drop:GetAttribute("UUID")
  replicatedstorage.RequestLootPickup:InvokeServer(uuid)
  replicatedstorage.LootDestroyed:FireServer(uuid)
end
local function automine(v)
    collectingFairy = v
    if collectingFairy then
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:IsA("Model") and tonumber(obj.Name) then
                collectFairy(obj)
            end
        end
        fairyConnection = workspace.ChildAdded:Connect(function(obj)
            if obj:IsA("Model") and tonumber(obj.Name) then
                local prompt = obj:WaitForChild("ProximityPrompt", 5)
                if prompt and collectingFairy then
                    fireproximityprompt(prompt)
                end
            end
        end)
    else
        if fairyConnection then
            fairyConnection:Disconnect()
            fairyConnection = nil
        end
    end
end
local function autoloot()
end
