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
--     EarthSalamander #42
--

function PrintTable(t, indent, done)
	--print ( string.format ('PrintTable type %s', type(keys)) )
	if type(t) ~= "table" then return end

	done = done or {}
	done[t] = true
	indent = indent or 0

	local l = {}
	for k, v in pairs(t) do
	table.insert(l, k)
	end

	table.sort(l)
	for k, v in ipairs(l) do
	-- Ignore FDesc
	if v ~= 'FDesc' then
		local value = t[v]

		if type(value) == "table" and not done[value] then
		done [value] = true
		print(string.rep ("\t", indent)..tostring(v)..":")
		PrintTable (value, indent + 2, done)
		elseif type(value) == "userdata" and not done[value] then
		done [value] = true
		print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
		PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
		else
		if t.FDesc and t.FDesc[v] then
			print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
		else
			print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
		end
		end
	end
	end
end

-- Precaches an unit, or, if something else is being precached, enters it into the precache queue
function PrecacheUnitWithQueue( unit_name )
	Timers:CreateTimer(function()
		-- If something else is being precached, wait two seconds
		if UNIT_BEING_PRECACHED then
			return 2

		-- Otherwise, start precaching and block other calls from doing so
		else
			UNIT_BEING_PRECACHED = true
			PrecacheUnitByNameAsync(unit_name, function(...) end)

			-- Release the queue after one second
			Timers:CreateTimer(2, function()
				UNIT_BEING_PRECACHED = false
			end)
		end
	end)

--	print("Precached", unit_name)
end

-- Custom NetGraph. Creator: Cookies [Earth Salamander]
function ImbaNetGraph(tick)
	Timers:CreateTimer(function()
		local units = FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector(0,0,0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false)		
		local good_unit_count = 0
		local bad_unit_count = 0
		local good_build_count = 0
		local bad_build_count = 0
		local dummy_count = 0

		for _, unit in pairs(units) do
			if unit:GetTeamNumber() == 2 then
				if unit:IsBuilding() then
					good_build_count = good_build_count+1
				else
					good_unit_count = good_unit_count +1
				end
			elseif unit:GetTeamNumber() == 3 then
				if unit:IsBuilding() then
					bad_build_count = bad_build_count+1
				else
					bad_unit_count = bad_unit_count +1
				end
			end
			if unit:GetUnitName() == "npc_dummy_unit" or unit:GetUnitName() == "npc_dummy_unit_perma" then			
				dummy_count = dummy_count +1
			end
		end

		CustomNetTables:SetTableValue("netgraph", "hero_number", {value = PlayerResource:GetPlayerCount()})
		CustomNetTables:SetTableValue("netgraph", "good_unit_number", {value = good_unit_count -4}) -- developer statues
		CustomNetTables:SetTableValue("netgraph", "bad_unit_number", {value = bad_unit_count -4}) -- developer statues
		CustomNetTables:SetTableValue("netgraph", "good_build_number", {value = good_build_count})
		CustomNetTables:SetTableValue("netgraph", "bad_build_number", {value = bad_build_count})
		CustomNetTables:SetTableValue("netgraph", "total_unit_number", {value = #units})
		CustomNetTables:SetTableValue("netgraph", "total_dummy_number", {value = dummy_count})
		CustomNetTables:SetTableValue("netgraph", "total_dummy_created_number", {value = dummy_created_count})
--		CustomNetTables:SetTableValue("netgraph", "total_particle_number", {value = total_particles})
--		CustomNetTables:SetTableValue("netgraph", "total_particle_created_number", {value = total_particles_created})

--		for i = 0, PlayerResource:GetPlayerCount() -1 do
--			CustomNetTables:SetTableValue("netgraph", "hero_particle_"..i-1, {particle = hero_particles[i-1], pID = i-1})
--			CustomNetTables:SetTableValue("netgraph", "hero_total_particle_"..i-1, {particle = total_hero_particles[i-1], pID = i-1})
--		end
	return tick
	end)
end

function DonatorCompanion(ID, unit_name)
if unit_name == nil then return end
local hero = PlayerResource:GetPlayer(ID):GetAssignedHero()
local color = hero:GetFittingColor()
local model = GetKeyValueByHeroName(unit_name, "Model")
local model_scale = GetKeyValueByHeroName(unit_name, "ModelScale")

	if hero.companion then
		hero.companion:ForceKill(false)
	end

	local companion = CreateUnitByName("npc_imba_donator_companion", hero:GetAbsOrigin() + RandomVector(200), true, hero, hero, hero:GetTeamNumber())
	companion:SetModel(model)
	companion:SetOriginalModel(model)
	companion:SetOwner(hero)
	companion:SetControllableByPlayer(hero:GetPlayerID(), true)

	companion:AddNewModifier(companion, nil, "modifier_companion", {})

	hero.companion = companion

	if model == "models/courier/baby_rosh/babyroshan.vmdl" then
		local particle_name = {}
		particle_name[0] = "particles/econ/courier/courier_donkey_ti7/courier_donkey_ti7_ambient.vpcf"
		particle_name[1] = "particles/econ/courier/courier_golden_roshan/golden_roshan_ambient.vpcf"
		particle_name[2] = "particles/econ/courier/courier_platinum_roshan/platinum_roshan_ambient.vpcf"
		particle_name[3] = "particles/econ/courier/courier_roshan_darkmoon/courier_roshan_darkmoon.vpcf" -- particles/econ/courier/courier_roshan_darkmoon/courier_roshan_darkmoon_flying.vpcf
		particle_name[4] = "particles/econ/courier/courier_roshan_desert_sands/baby_roshan_desert_sands_ambient.vpcf"
		particle_name[5] = "particles/econ/courier/courier_roshan_lava/courier_roshan_lava.vpcf"
		particle_name[6] = "particles/econ/courier/courier_roshan_frost/courier_roshan_frost_ambient.vpcf"
		-- also attach eyes effect later
		local random_int = RandomInt(0, #particle_name)

		local particle = ParticleManager:CreateParticle(particle_name[random_int], PATTACH_ABSORIGIN_FOLLOW, companion)
		if random_int <= 4 then
			companion:SetMaterialGroup(tostring(random_int))
		else
			companion:SetModel("models/courier/baby_rosh/babyroshan_elemental.vmdl")
			companion:SetOriginalModel("models/courier/baby_rosh/babyroshan_elemental.vmdl")
			companion:SetMaterialGroup(tostring(random_int-4))
		end
	elseif unit_name == "npc_imba_donator_companion_suthernfriend" then
		companion:SetMaterialGroup("1")
	elseif model == "models/heroes/mario/mario_model.vmdl" then
		companion:SetMaterialGroup(tostring(RandomInt(0, 2)))
		companion:SetModelScale(0.5)
	elseif unit_name == "npc_imba_donator_companion_baekho" then
		local particle = ParticleManager:CreateParticle("particles/econ/courier/courier_baekho/courier_baekho_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, companion)
	end

	companion:SetModelScale(model_scale)

	if string.find(model, "flying") then
		companion:SetMoveCapability(DOTA_UNIT_CAP_MOVE_FLY)
	end

--	if super_donator then
--		local ab = companion:FindAbilityByName("companion_morph")
--		ab:SetLevel(1)
--		ab:CastAbility()		
--	end
end

function CountdownTimer()
	nCOUNTDOWNTIMER = nCOUNTDOWNTIMER - 1
	local t = nCOUNTDOWNTIMER
	-- print( t )
	local minutes = math.floor(t / 60)
	local seconds = t - (minutes * 60)
	local m10 = math.floor(minutes / 10)
	local m01 = minutes - (m10 * 10)
	local s10 = math.floor(seconds / 10)
	local s01 = seconds - (s10 * 10)
	local broadcast_gametimer = 
		{
			timer_minute_10 = m10,
			timer_minute_01 = m01,
			timer_second_10 = s10,
			timer_second_01 = s01,
		}
	CustomGameEventManager:Send_ServerToAllClients( "countdown", broadcast_gametimer )
	if t <= 120 then
		CustomGameEventManager:Send_ServerToAllClients( "time_remaining", broadcast_gametimer )
	end
end

function CheatDetector()
	if CustomNetTables:GetTableValue("game_options", "game_count").value == 1 then
		if Convars:GetBool("sv_cheats") == true or GameRules:IsCheatMode() then
			if not IsInToolsMode() then
				log.info("Cheats have been enabled, game don't count.")
				CustomNetTables:SetTableValue("game_options", "game_count", {value = 0})
				CustomGameEventManager:Send_ServerToAllClients("safe_to_leave", {})
				return true
			end
		end
	end

	return false
end

function IsDeveloper(ID)
	local developers = {
		"76561198052613450",
		"76561198015161808",
	}

	for i = 1, #developers do
		local steam_id = tostring(PlayerResource:GetSteamID(ID))
		if steam_id == developers[i] then
			return true
		end
	end

	return false
end

function GetReductionFromArmor(armor)
	local m = 0.06 * armor
	return 100 * (1 - m/(1+math.abs(m)))
end

-- Autoattack lifesteal
function CDOTA_BaseNPC:GetLifesteal()
	local lifesteal = 0
	for _, parent_modifier in pairs(self:FindAllModifiers()) do
		if parent_modifier.GetModifierLifesteal then
			lifesteal = lifesteal + parent_modifier:GetModifierLifesteal()
		end
	end

	return lifesteal
end

-- Thanks to LoD-Redux & darklord for this!
function DisplayError(playerID, message)
	local player = PlayerResource:GetPlayer(playerID)
	if player then
		CustomGameEventManager:Send_ServerToPlayer(player, "CreateIngameErrorMessage", {message=message})
	end
end
