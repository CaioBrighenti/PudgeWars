ListenToGameEvent('npc_spawned', function(keys)
	local spawnedUnit = EntIndexToHScript( keys.entindex )
	local player = spawnedUnit:GetPlayerOwner()

	if spawnedUnit:GetUnitName() == "npc_dota_campfire" then
		spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_campfire", {})
	elseif spawnedUnit:GetUnitName() == "npc_vision_dummy" then
		spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_tower_truesight_aura", {duration = 30})
		spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_invisible", {})
	elseif string.find(spawnedUnit:GetUnitName(), "npc_dota_mine") then
		spawnedUnit:AddAbility('vision_dummy_passive')
		local spawnedUnitPassive = spawnedUnit:FindAbilityByName('vision_dummy_passive')
		spawnedUnitPassive:SetLevel(1)
	elseif string.find(spawnedUnit:GetUnitName(), "npc_dummy_rune_") then
		Timers:CreateTimer(0.4, function()
			spawnedUnit:MoveToPosition(Vector(0, 2000, 0))
		end)
	elseif string.find(spawnedUnit:GetUnitName(), "barrier") then
		local owner = spawnedUnit:GetOwner()
		spawnedUnit:SetForwardVector(owner:GetForwardVector())

		GameMode:CreateTimer(DoUniqueString("clear_space"), {
			endTime = GameRules:GetGameTime() + 0.07,
			callback = function(reflex, args)
			FindClearSpaceForUnit(spawnedUnit, spawnedUnit:GetAbsOrigin(), true ) 
			return
		end})
	elseif spawnedUnit:IsRealHero() then
		if spawnedUnit:GetPlayerOwnerID() ~= -1 then
			if PudgeArray[ spawnedUnit:GetPlayerOwnerID() ] == null then
				GameMode:InitPudge( spawnedUnit )
			end

			if not spawnedUnit:HasModifier("modifier_ability_points") then
				spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_ability_points", {}):SetStackCount(spawnedUnit:GetAbilityPoints())
			end
		end
	end
end, nil)

ListenToGameEvent('dota_player_gained_level', function(keys)
	local player = EntIndexToHScript(keys.player)
	local hero = player:GetAssignedHero()
	local hero_level = hero:GetLevel()

	local extra_ab_points = {17, 19, 21, 22, 23, 24, 26}

	for i = 0, #extra_ab_points do
		if hero_level == extra_ab_points[i] then
			hero:SetAbilityPoints(hero:GetAbilityPoints() + 1)
		end
	end

	if hero_level > 40 then
		hero:SetAbilityPoints(hero:GetAbilityPoints() - 1)
	end

	local modifier = hero:FindModifierByName("modifier_ability_points")
	if modifier then
		modifier:SetStackCount(hero:GetAbilityPoints())
	end
end, nil)

local first_blood = false
ListenToGameEvent('entity_killed', function(keys)
	local killedUnit = EntIndexToHScript(keys.entindex_killed)
	local killerEntity = nil

	if keys.entindex_attacker ~= nil then
		killerEntity = EntIndexToHScript(keys.entindex_attacker)
	else
		return
	end

	if string.find(killedUnit:GetClassname(), "creep") and string.find(killedUnit:GetUnitName(), "mine") and not killedUnit:HasModifier("modifier_pudge_meat_hook") then
		Timers:CreateTimer(1.0, function()
			if killedUnit and IsValidEntity(killedUnit) then
				killedUnit:RemoveSelf()
			end
		end)   

		return
	end

	if string.find(killedUnit:GetClassname(), "creature") and string.find(killedUnit:GetUnitName(), "barrier") then
		Timers:CreateTimer(1.0, function()
			if killedUnit and IsValidEntity(killedUnit) then
				killedUnit:RemoveSelf()
			end
		end) 

		return
	end

	if killedUnit:IsRealHero() then
		local kill_score = 1
		if killedUnit.headshot == true then
			killedUnit.headshot = false
			kill_score = 2
		end
		if first_blood == false then
			kill_score = kill_score + 4
			first_blood = true
		end
		if killedUnit:GetTeam() == DOTA_TEAM_BADGUYS then
			if killerEntity:GetTeam() == 2 then
				self.scoreRadiant = self.scoreRadiant + kill_score
				CustomNetTables:SetTableValue("game_score", "team_score", {radiant_score = self.scoreRadiant, dire_score = self.scoreDire})

				-- weird bug since Dota 7.28, requires manual score setup now
				GameRules:GetGameModeEntity():SetCustomDireScore(GetTeamHeroKills(DOTA_TEAM_BADGUYS))
			end
		elseif killedUnit:GetTeam() == DOTA_TEAM_GOODGUYS then
			if killerEntity:GetTeam() == 3 then
				self.scoreDire = self.scoreDire + kill_score
				CustomNetTables:SetTableValue("game_score", "team_score", {radiant_score = self.scoreRadiant, dire_score = self.scoreDire})
			end
		end

		if self.scoreDire >= self.kills_to_win then
			GAME_WINNER_TEAM = 2
			GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
			GameRules:MakeTeamLose(DOTA_TEAM_GOODGUYS)
--			GameRules:Defeated()
		elseif self.scoreRadiant >= self.kills_to_win then
			GAME_WINNER_TEAM = 3
			GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
			GameRules:MakeTeamLose(DOTA_TEAM_BADGUYS)
--			GameRules:Defeated()
		end

		return
	end
end, nil)

ListenToGameEvent('player_chat', function(keys)
	local text = keys.text
--	local caster = PlayerResource:GetSelectedHeroEntity(keys.playerid)

	-- This Handler is only for commands, ends the function if first character is not "-"
	if not (string.byte(text) == 45) then
		return nil
	end

	for str in string.gmatch(text, "%S+") do
		if IsInToolsMode() or GameRules:IsCheatMode() or api.imba.is_developer(steamid) then
			if str == "-win" then
				local random_int = RandomInt(2, 3)
				if random_int == 2 then
					GAME_WINNER_TEAM = 3
				else
					GAME_WINNER_TEAM = 2
				end
				GameRules:SetGameWinner(random_int)
			end
		end
	end
end, nil)
