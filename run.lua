workspace.luxurysigma["Stone Pickaxe"].ToolHit:FireServer({{["healthValue"] = workspace.CherryLog.BlockInfo.Health,["blockInfoFolder"] = workspace.CherryLog.BlockInfo,["position"] = ,["object"] = workspace.CherryLog,["maxHealthValue"] = workspace.CherryLog.BlockInfo.MaxHealth,["maxHealth"] = 15,["healthBarGui"] = workspace.CherryLog.HealthBar,["hardness"] = "Medium",["health"] = 15}},"Stone Pickaxe")
workspace.luxurysigma["Stone Axe"].ToolHit:FireServer({{["healthValue"] = workspace.BloodwoodLog.BlockInfo.Health,["blockInfoFolder"] = workspace.BloodwoodLog.BlockInfo,["position"] = ,["object"] = workspace.BloodwoodLog,["maxHealthValue"] = workspace.BloodwoodLog.BlockInfo.MaxHealth,["maxHealth"] = 15,["healthBarGui"] = workspace.BloodwoodLog.HealthBar,["hardness"] = "Medium",["health"] = 4}},"Stone Axe")
workspace.luxurysigma["Stone Shovel"].ToolHit:FireServer({{["healthValue"] = workspace.BloodwoodLog.BlockInfo.Health,["blockInfoFolder"] = workspace.BloodwoodLog.BlockInfo,["position"] = ,["object"] = workspace.BloodwoodLog,["maxHealthValue"] = workspace.BloodwoodLog.BlockInfo.MaxHealth,["maxHealth"] = 15,["healthBarGui"] = workspace.BloodwoodLog.HealthBar,["hardness"] = "Medium",["health"] = 6}},"Stone Shovel")
local players = game:GetService("Players")
local localplayer = players.LocalPlayer
local playername = localplayer.Name
local function mine(toolname, block)
  local blockinfo = block.BlockInfo
  local maxhealth = blockinfo.MaxHealth
  workspace[playername][toolname].ToolHit:FireServer({{["healthValue"] = blockinfo.Health, ["blockInfoFolder"] = blockinfo, ["position"] =, ["object"] = block, ["maxHealthValue"] = maxhealth, ["maxHealth"] = maxhealth.Value, ["healthBarGui"] = block.HealthBar, ["hardness"] = blockinfo.BlockHardness.Value, ["health"] = blockinfo.Health.Value}}, toolname)
end
