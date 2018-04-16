-- Copyright (C) 2018  The Dota IMBA Development Team
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
-- Editors:
--     Earth Salamander #42

-- Battlepass

if Battlepass == nil then Battlepass = class({}) end
BATTLEPASS_LEVEL_REWARD = {}
BATTLEPASS_LEVEL_REWARD[5] = "hook" -- Broilers Hook
BATTLEPASS_LEVEL_REWARD[10] = "streak_counter"
BATTLEPASS_LEVEL_REWARD[15] = "hook2" -- Blood Drainer Hook
BATTLEPASS_LEVEL_REWARD[25] = "hook3" -- Sorrowful Prey Hook
BATTLEPASS_LEVEL_REWARD[35] = "hook4" -- Ol'Choppers Hook
BATTLEPASS_LEVEL_REWARD[45] = "hook5" -- Force Hook
BATTLEPASS_LEVEL_REWARD[50] = "pudge_arcana" -- (Red)
BATTLEPASS_LEVEL_REWARD[55] = "hook6" -- Harpoon
BATTLEPASS_LEVEL_REWARD[65] = "hook7" -- Whale Hook
BATTLEPASS_LEVEL_REWARD[75] = "hook8" -- Dragonclaw Hook
BATTLEPASS_LEVEL_REWARD[100] = "pudge_arcana2" -- (Green)

CustomNetTables:SetTableValue("game_options", "battlepass", {battlepass = BATTLEPASS_LEVEL_REWARD})

function Battlepass:Init()
	BATTLEPASS_PUDGE = {}
	BATTLEPASS_HOOK = {}
	BATTLEPASS_HOOK_STREAK_COUNTER = {}

	for k, v in pairs(BATTLEPASS_LEVEL_REWARD) do
		if string.find(v, "pudge_arcana") then
			BATTLEPASS_PUDGE[v] = k
		elseif string.find(v, "hook") then
			BATTLEPASS_HOOK[v] = k
		elseif string.find(v, "streak_counter") then
			BATTLEPASS_HOOK_STREAK_COUNTER[v] = k
		end
	end
end

function Battlepass:AddItemEffects(hero)
	GetPudgeHook(hero)
	HasPudgeHookStreakCounter(hero)
	GetPudgeArcanaEffect(hero)
end

function Battlepass:GetRewardUnlocked(ID)
	if CustomNetTables:GetTableValue("player_table", tostring(ID)) then
		return CustomNetTables:GetTableValue("player_table", tostring(ID)).Lvl
	end

	return 1
end

function GetPudgeHook(hero)
	local hook_model = "models/heroes/pudge/righthook.vmdl"
	local hook_pfx = "particles/pw/ref_pudge_meathook_chain.vpcf"

	-- List of Hooks upgrades
	--[[
		"models/items/pudge/harpoon_hook/mesh/harpoon_hook.vmdl" (default, witness, gold)
	--]]

	-- List of Hooks Effects
	--[[
		"particles/econ/items/pudge/pudge_arcana/pudge_arcana_back_ambient_hook_fire.vpcf"
	--]]

	if Battlepass:GetRewardUnlocked(hero:GetPlayerID()) >= BATTLEPASS_HOOK["hook8"] then
		hook_model = "models/items/pudge/pudge_skeleton_hook_body.vmdl"
		hook_pfx = "particles/pw/ref_pudge_meathook_chain_skeleton.vpcf"
	elseif Battlepass:GetRewardUnlocked(hero:GetPlayerID()) >= BATTLEPASS_HOOK["hook7"] then
		hook_model = "models/items/pudge/whale_hook.vmdl"
--		hook_pfx = ""
	elseif Battlepass:GetRewardUnlocked(hero:GetPlayerID()) >= BATTLEPASS_HOOK["hook6"] then
		hook_model = "models/items/pudge/harpoon_hook/mesh/harpoon_hook.vmdl"
--		hook_pfx = ""
	elseif Battlepass:GetRewardUnlocked(hero:GetPlayerID()) >= BATTLEPASS_HOOK["hook5"] then
		hook_model = "models/items/pudge/force_hook/force_hook.vmdl"
--		hook_pfx = ""
	elseif Battlepass:GetRewardUnlocked(hero:GetPlayerID()) >= BATTLEPASS_HOOK["hook4"] then
		hook_model = "models/items/pudge/the_ol_choppers_hook/the_ol_choppers_hook.vmdl"
--		hook_pfx = ""
	elseif Battlepass:GetRewardUnlocked(hero:GetPlayerID()) >= BATTLEPASS_HOOK["hook3"] then
		hook_model = "models/items/pudge/hook_of_the_sorrowful_prey/hook_of_the_sorrowful_prey.vmdl"
--		hook_pfx = ""
	elseif Battlepass:GetRewardUnlocked(hero:GetPlayerID()) >= BATTLEPASS_HOOK["hook2"] then
		hook_model = "models/items/pudge/blood_drainer_hook/blood_drainer_hook.vmdl"
--		hook_pfx = ""
	elseif Battlepass:GetRewardUnlocked(hero:GetPlayerID()) >= BATTLEPASS_HOOK["hook"] then
		hook_model = "models/items/pudge/butchersbroilers_hook/butchersbroilers_hook.vmdl"
--		hook_pfx = ""
	end

	local hHook = hero:GetTogglableWearable( DOTA_LOADOUT_TYPE_WEAPON )

	if hHook then
		hero.hook = SpawnEntityFromTableSynchronous("prop_dynamic", {model = hook_model})
		hero.hook:FollowEntity(hero, true)

		Timers:CreateTimer(1.0, function()
			hHook:AddEffects(EF_NODRAW)
			return 1.0
		end)
	end

	hero.hook_model = hook_model
end

function GetPudgeArcanaEffect(hero)
	local has_arcana = HasPudgeArcana(hero:GetPlayerID())

	if has_arcana then
		if has_arcana == true then has_arcana = 1 end
		hero:SetModel("models/items/pudge/arcana/pudge_arcana_base.vmdl")
		hero:SetOriginalModel("models/items/pudge/arcana/pudge_arcana_base.vmdl")
		hero:SetMaterialGroup(tostring(has_arcana))
		hero.pudge_arcana = has_arcana

		local wearable = hero:GetTogglableWearable(DOTA_LOADOUT_TYPE_BACK)

		if wearable then
			wearable:AddEffects(EF_NODRAW)
		end

		hero.back = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/pudge/arcana/pudge_arcana_back.vmdl"})
		hero.back:FollowEntity(hero, true)
		hero.back:SetMaterialGroup(tostring(has_arcana))

		local particle = "particles/econ/items/pudge/pudge_arcana/pudge_arcana_red_back_ambient.vpcf"	
		local particle2 = "particles/econ/items/pudge/pudge_arcana/pudge_arcana_red_back_ambient_beam.vpcf"
		if has_arcana >= 1 then
			particle = "particles/econ/items/pudge/pudge_arcana/pudge_arcana_back_ambient.vpcf"
			particle2 = "particles/econ/items/pudge/pudge_arcana/pudge_arcana_back_ambient_beam.vpcf"
		end

		ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, hero.back)
		ParticleManager:CreateParticle(particle2, PATTACH_ABSORIGIN_FOLLOW, hero.back)
		ParticleManager:CreateParticle("particles/econ/items/pudge/pudge_arcana/pudge_arcana_ambient_flies.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)

		if has_arcana > 1 then has_arcana = 1 end
		CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "override_hero_image", {arcana = has_arcana})
	end
end

function HasPudgeArcana(ID)
	if Battlepass:GetRewardUnlocked(ID) >= BATTLEPASS_PUDGE["pudge_arcana2"] then
		return 1
	elseif Battlepass:GetRewardUnlocked(ID) >= BATTLEPASS_PUDGE["pudge_arcana"] then
		return 0
	else
		return false
	end
end

function HasPudgeHookStreakCounter(ID)
	if Battlepass:GetRewardUnlocked(ID) >= BATTLEPASS_HOOK_STREAK_COUNTER["streak_counter"] then
		return true
	end

	return false
end
