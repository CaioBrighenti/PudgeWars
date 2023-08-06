print("[FUNCTIONS] functions loading")

function GameMode:AssignHookModel(hero)
	PudgeArray[hero:GetPlayerOwnerID()].modelName = "none"
	--[[
	local cur = hero:FirstMoveChild()
	local count = 0
	--find hook model
	while cur ~= nil do
	  cur = cur:NextMovePeer()
	  if count == 6 and cur ~= nil and cur:GetModelName() ~= "" then
		PudgeArray[hero:GetPlayerOwnerID()].modelName = cur:GetModelName()
		print(PudgeArray[hero:GetPlayerOwnerID()].modelName)
	  end
	  count = count +1
	end
	if PudgeArray[hero:GetPlayerOwnerID()].modelName  == "" then
	  PudgeArray[hero:GetPlayerOwnerID()].modelName  = "none"
	end --]]
end

function GameMode:CreateVisionUnit(unitname, unitOrigin, team)
	--ToDo: Add KV-files
	VisionDummy = CreateUnitByName(unitname, unitOrigin, false, nil, nil, team)
	VisionDummy:AddAbility('vision_dummy_passive')
	VisionDummy:AddNewModifier(VisionDummy, nil, 'modifier_invulnerable', {})
	VisionDummy:AddNewModifier(VisionDummy, nil, 'modifier_phased', {})
end

function GameMode:SpawnFuntainDummy()
	print("[FUNCTIONS] SpawnFuntainDummy")
	--ToDo: Add KV-files
	VisionDummy = CreateUnitByName("npc_funtain_dummy", Vector(0, 0, 0), false, nil, nil, DOTA_TEAM_BADGUYS)
	VisionDummy:AddAbility('vision_dummy_passive')
	VisionDummy:AddNewModifier(VisionDummy, nil, 'modifier_invulnerable', {})
end

function GameMode:SpawnVisionDummies()
	--Vision in base
	--	AddFOWViewer(2, Vector(-1200, -1300, 0), 1300, 99999, false)
	--	AddFOWViewer(2, Vector(-1200, 0, 0), 1300, 99999, false)
	--	AddFOWViewer(2, Vector(-1200, 1300, 0), 1300, 99999, false)

	GameMode:CreateVisionUnit("npc_vision_dummy_2", Vector(-1200, -1300, 0), DOTA_TEAM_GOODGUYS)
	GameMode:CreateVisionUnit("npc_vision_dummy_2", Vector(-1200, 0, 0), DOTA_TEAM_GOODGUYS)
	GameMode:CreateVisionUnit("npc_vision_dummy_2", Vector(-1200, 1300, 0), DOTA_TEAM_GOODGUYS)

	-- shop
	GameMode:CreateVisionUnit("npc_vision_dummy_2", Vector(-1800, 0, 500), DOTA_TEAM_GOODGUYS)

	GameMode:CreateVisionUnit("npc_vision_dummy_2", Vector(1200, -1300, 0), DOTA_TEAM_BADGUYS)
	GameMode:CreateVisionUnit("npc_vision_dummy_2", Vector(1200, 0, 0), DOTA_TEAM_BADGUYS)
	GameMode:CreateVisionUnit("npc_vision_dummy_2", Vector(1200, 1300, 0), DOTA_TEAM_BADGUYS)

	-- shop
	GameMode:CreateVisionUnit("npc_vision_dummy_2", Vector(1800, 0, 500), DOTA_TEAM_BADGUYS)

	--	AddFOWViewer(3, Vector(1200, -1300, 0), 1300, 99999, false)
	--	AddFOWViewer(3, Vector(1200, 0, 0), 1300, 99999, false)
	--	AddFOWViewer(3, Vector(1200, 1300, 0), 1300, 99999, false)
end

function GameMode:SpawnRuneSpellCasters()
	print("[FUNCTIONS] Spawn Spell Casters")

	-- ToDo: Add KV-files
	_G.rune_spell_caster_good = CreateUnitByName("npc_ion_dummy", Vector(0, 0, 0), false, nil, nil, DOTA_TEAM_GOODGUYS)
	_G.rune_spell_caster_good:AddNewModifier(_G.rune_spell_caster_good, nil, 'modifier_invulnerable', {})
	_G.rune_spell_caster_good:AddNewModifier(_G.rune_spell_caster_good, nil, 'modifier_phased', {})
end

function GameMode:StartTimers()
	--start timers that are running from the start
	print("[FUNCTIONS] Starting timer")

	--start a timer that waits for the game to be in progress
	GameMode:CreateTimer(DoUniqueString("waitforgamestart"), {
		endTime = GameRules:GetGameTime() + 1,
		useGameTime = true,
		callback = function(reflex, args)
			--wait for the game to be in progress
			if not ((GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME) or (GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS)) or not (has_been_in_wait_for_players) then
				return GameRules:GetGameTime() + 1
			end

			return -- stop wait for game to being timer
		end
	})


	GameMode:CreateTimer(DoUniqueString("waitforgamestartdebug"), {
		endTime = GameRules:GetGameTime() + 0.1,
		useGameTime = true,
		callback = function(reflex, args)
			if (GameRules:State_Get() == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD) or not (USE_LOBBY) then
				has_been_in_wait_for_players = true
				return
			end

			return GameRules:GetGameTime() + 0.1
		end
	})
end

function sendAMsg(msg)
	local centerMessage = {
		message = msg,
		duration = 1
	}
	FireGameEvent("show_center_message", centerMessage)
end

function sendAMsgTime(msg, time)
	local centerMessage = {
		message = msg,
		duration = time
	}
	FireGameEvent("show_center_message", centerMessage)
end

function GameMode:RollBash(per)
	return RandomInt(1, 100) <= per
end
