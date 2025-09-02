-- Services
local replicatedstorage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
-- Data
local localplayer = players.LocalPlayer
local playername = localplayer.Name
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
