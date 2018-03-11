print ('[PUDGEWARS] pudgewars.lua' )

USE_LOBBY=false
THINK_TIME = FrameTime()

STARTING_GOLD = 0
MAX_LEVEL = 40

-- Fill this table up with the required XP per level if you want to change it
XP_PER_LEVEL_TABLE = {}
XP_PER_LEVEL_TABLE[1] = 0
XP_PER_LEVEL_TABLE[2] = 50
XP_PER_LEVEL_TABLE[3] = 200
XP_PER_LEVEL_TABLE[4] = 450
XP_PER_LEVEL_TABLE[5] = 800
XP_PER_LEVEL_TABLE[6] = 1100
XP_PER_LEVEL_TABLE[7] = 1700
XP_PER_LEVEL_TABLE[8] = 2400
XP_PER_LEVEL_TABLE[9] = 3100
XP_PER_LEVEL_TABLE[10] = 3900
XP_PER_LEVEL_TABLE[11] = 4500
XP_PER_LEVEL_TABLE[12] = 5000
XP_PER_LEVEL_TABLE[13] = 6500
XP_PER_LEVEL_TABLE[14] = 8000
XP_PER_LEVEL_TABLE[15] = 9000
XP_PER_LEVEL_TABLE[16] = 10500
XP_PER_LEVEL_TABLE[17] = 11000
XP_PER_LEVEL_TABLE[18] = 12000
XP_PER_LEVEL_TABLE[19] = 13500
XP_PER_LEVEL_TABLE[20] = 15000
XP_PER_LEVEL_TABLE[21] = 16500
XP_PER_LEVEL_TABLE[22] = 18000
XP_PER_LEVEL_TABLE[23] = 20000
XP_PER_LEVEL_TABLE[24] = 21000
XP_PER_LEVEL_TABLE[25] = 22000
XP_PER_LEVEL_TABLE[26] = 23000
XP_PER_LEVEL_TABLE[27] = 25000
XP_PER_LEVEL_TABLE[28] = 27000
XP_PER_LEVEL_TABLE[29] = 29000
XP_PER_LEVEL_TABLE[30] = 31000
XP_PER_LEVEL_TABLE[31] = 34000
XP_PER_LEVEL_TABLE[32] = 37000
XP_PER_LEVEL_TABLE[33] = 40000
XP_PER_LEVEL_TABLE[34] = 43000
XP_PER_LEVEL_TABLE[35] = 46000
XP_PER_LEVEL_TABLE[36] = 49000
XP_PER_LEVEL_TABLE[37] = 54000
XP_PER_LEVEL_TABLE[38] = 58000
XP_PER_LEVEL_TABLE[39] = 62000
XP_PER_LEVEL_TABLE[40] = 66000
XP_PER_LEVEL_TABLE[41] = 70000
XP_PER_LEVEL_TABLE[42] = 74000

GameMode = nil
PudgeArray = {}

--Rune globals
shield_carrier = nil
rune_spell_caster_good = nil
has_been_in_wait_for_players = false

if PudgeWarsMode == nil then
		PudgeWarsMode = class({})
		print("created PW")
		--[[
	print ( '[PUDGEWARS] creating pudgewars game mode' )
	PudgeWarsMode = {}
	PudgeWarsMode.szEntityClassName = "pudgewars"
	PudgeWarsMode.szNativeClassName = "dota_base_game_mode"
	PudgeWarsMode.__index = PudgeWarsMode --]]
end

function PudgeWarsMode:new( o )
	print ( '[PUDGEWARS] PudgeWarsMode:new' )
	o = o or {}
	setmetatable( o, PudgeWarsMode )
	return o
end

function PudgeWarsMode:InitGameMode()
	print('[PUDGEWARS] Starting to load Pudgewars gamemode...')

	-- Global Variables
	self.RESPAWN_TIME = 8.0
	PRE_GAME_TIME = 10.0

	-- Runes Variables
	RUNE_SPAWN_TIME = 40.0
	RUNE_TEXT_DURATION = 4.0
	RUNE_SLOW = false
	RUNE_SLOW_DURATION = 15.0
	RUNE_SHIELD_DURATION = 12.0
	RUNE_FIRE_DURATION = 24.0

	-- Setup rules
	GameRules:SetHeroRespawnEnabled(true)
	GameRules:SetUseUniversalShopMode(false)
	GameRules:SetHeroSelectionTime(0.0)
	GameRules:SetPreGameTime(PRE_GAME_TIME)
	GameRules:SetPostGameTime(20.0)
	GameRules:SetGoldPerTick(0)
	GameRules:SetHeroMinimapIconScale(0.8)
	GameRules:SetCreepMinimapIconScale(0)
	GameRules:SetRuneMinimapIconScale(0.7)
	GameRules:SetSameHeroSelectionEnabled(true)
	GameRules:SetHideKillMessageHeaders(true)
	GameRules:GetGameModeEntity():SetCustomGameForceHero("npc_dota_hero_pudge")

	GameRules:GetGameModeEntity():SetItemAddedToInventoryFilter(function(ctx, event)
		local hero = EntIndexToHScript(event.inventory_parent_entindex_const)
		local item = EntIndexToHScript(event.item_entindex_const)

		-- remove tp given at the beginning
		if item:GetAbilityName() == "item_tpscroll" and item:GetPurchaser() == nil then
			return false
		end

    	return true
	end, self)

	print('[PUDGEWARS] Rules set')

	InitLogFile( "log/pudgewars.txt","")

	-- Hooks
	ListenToGameEvent('entity_killed', Dynamic_Wrap(self, 'OnEntityKilled'), self)
	ListenToGameEvent('player_connect_full', Dynamic_Wrap(self, 'AutoAssignPlayer'), self)
	ListenToGameEvent('dota_item_purchased', Dynamic_Wrap(self, 'OnItemPurchased'), self)
	ListenToGameEvent('dota_player_used_ability', Dynamic_Wrap(self, 'AbilityUsed'), self)
	ListenToGameEvent('dota_item_picked_up', Dynamic_Wrap( self, 'ItemPickedUp' ), self )
	ListenToGameEvent('npc_spawned', Dynamic_Wrap( self, 'OnNPCSpawned'), self)
	ListenToGameEvent('dota_player_gained_level', Dynamic_Wrap( self, 'OnLevelUp'), self)
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(self, 'OnGameRulesStateChange'), self)

	CustomGameEventManager:RegisterListener( "pudgewars_player_vote50", OnPlayerVote50 )
	CustomGameEventManager:RegisterListener( "pudgewars_player_vote75", OnPlayerVote75 )
	CustomGameEventManager:RegisterListener( "pudgewars_player_vote100", OnPlayerVote100 )
	CustomGameEventManager:RegisterListener( "pudgewars_vote_update", OnVoteUpdate )

	-- Change random seed
	local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
	math.randomseed(tonumber(timeTxt))
		
	-- Init self
	PudgeWarsMode = self
	-- Timers
	self.timers = {}

	-- userID map
	self.vUserIds = {}
	self.vSteamIds = {}

	self.vPlayers = {}
	self.vRadiant = {}
	self.vDire = {}

	--Score
	self.scoreDire = 0
	self.scoreRadiant = 0
	self.kills_to_win = 50
	self.vote_50_votes = 0
	self.vote_75_votes = 0
	self.vote_100_votes = 0
	self.is_voting = false
	self.vote_start_time = 0

	--runes
	_G.all_flame_hooks = {}

	--tomes
	self.health_tome_modifier_item = nil

	PudgeWarsMode:StartTimers()
	PudgeWarsMode:SpawnRuneSpellCasters()
	PudgeWarsMode:SpawnVisionDummies()
	PudgeWarsMode:SpawnFuntainDummy()
	--PudgeWarsMode:InitScaleForm()

	-- print('[PUDGEWARS] Starting stats')
	-- statcollection.addStats({
	--   modID = '8a404b7c81ab60ec9bc9298e9b76b251'
	-- })

	print('[PUDGEWARS] Done loading Pudgewars gamemode!\n\n')
end

function PudgeWarsMode:CaptureGameMode()
	if GameMode == nil then
		-- Set GameMode parameters
		GameMode = GameRules:GetGameModeEntity()		
		-- Disables recommended items...though I don't think it works
		GameMode:SetRecommendedItemsDisabled( true )
		-- Override the normal camera distance.  Usual is 1134
		GameMode:SetCameraDistanceOverride( 1134.0 )
		-- Set Buyback options
		GameMode:SetCustomBuybackCostEnabled( true )
		GameMode:SetCustomBuybackCooldownEnabled( true )
		GameMode:SetBuybackEnabled( false )
		-- Override the top bar values to show your own settings instead of total deaths
		GameMode:SetTopBarTeamValuesOverride ( true )
		-- Use custom hero level maximum and your own XP per level
		GameMode:SetUseCustomHeroLevels ( true )
		GameMode:SetCustomHeroMaxLevel ( MAX_LEVEL )
		GameMode:SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )
		GameMode:SetAnnouncerDisabled(true)

		print( '[PUDGEWARS] NOT Beginning Think' ) 
		GameMode:SetContextThink("PudgewarsThink", Dynamic_Wrap( PudgeWarsMode, 'Think' ), THINK_TIME )
	end 
end

function PudgeWarsMode:OnGameRulesStateChange(keys)
	local newState = GameRules:State_Get()

	if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		-- start slower thinker to avoid lags
		Timers:CreateTimer(function()
			self:SlowThink()
			return 1.0
		end)

		-- start spawn rune timer
		Timers:CreateTimer(RUNE_SPAWN_TIME, function()
			PudgeWarsMode:SpawnRune()
			return RUNE_SPAWN_TIME
		end)
	end
end

function PudgeWarsMode:SlowThink()
	for _, hero in pairs(HeroList:GetAllHeroes()) do
		-- model bug fix
--		if PudgeArray[hero:GetPlayerID()].modelName == "" then
--			PudgeWarsMode:AssignHookModel(hero)    
--		end

		if PlayerResource:GetConnectionState(hero:GetPlayerID()) <= 2 and hero.anti_afk ~= false then
			hero.anti_afk = false
			hero:RespawnHero(false, false)
			hero:RemoveModifierByName("modifier_command_restricted")
		elseif PlayerResource:GetConnectionState(hero:GetPlayerID()) > 2 and hero.anti_afk ~= true then
			if hero:IsAlive() then
				hero.anti_afk = true
				FindClearSpaceForUnit(hero, Entities:FindByName(nil, "anti_afk_"..hero:GetTeamNumber()):GetAbsOrigin(), true)
				hero:AddNewModifier(hero, nil, "modifier_command_restricted", {})
			end
		end
	end

	-- handle the rune slow modifier duration
	if RUNE_SLOW ~= false then
		RUNE_SLOW = RUNE_SLOW - 1

		if RUNE_SLOW <= 0 then
			RUNE_SLOW = false
		end
	end
end

function OnVoteUpdate( Index,keys )
	local killsVoted = keys.killsVoted
	if killsVoted == 1 then
		PudgeWarsMode .vote_50_votes = PudgeWarsMode.vote_50_votes + 1
	elseif killsVoted == 2 then
		PudgeWarsMode .vote_75_votes = PudgeWarsMode .vote_75_votes + 1
	elseif killsVoted == 3 then
		PudgeWarsMode .vote_100_votes = PudgeWarsMode  .vote_100_votes + 1
	end
end

function OnPlayerVote50( Index,keys )
	print("Vote 50")
	PudgeWarsMode .vote_50_votes = PudgeWarsMode.vote_50_votes + 1
	local votes_for_50 = PudgeWarsMode.vote_50_votes
	local votes_for_75 = PudgeWarsMode.vote_75_votes
	local votes_for_100 = PudgeWarsMode.vote_100_votes
	local vote_update_info = 
	{
		votes_50 = PudgeWarsMode.vote_50_votes,
		votes_75 = PudgeWarsMode.vote_75_votes,
		votes_100 = PudgeWarsMode.vote_100_votes,
	}

	CustomGameEventManager:Send_ServerToAllClients( "pudgewars_vote_blocks_update", vote_update_info )
end

function OnPlayerVote75( Index,keys )
	print("Vote 75")
	PudgeWarsMode .vote_75_votes = PudgeWarsMode .vote_75_votes + 1
	local vote_update_info = 
	{
		votes_50 = PudgeWarsMode.vote_50_votes,
		votes_75 = PudgeWarsMode.vote_75_votes,
		votes_100 = PudgeWarsMode.vote_100_votes,
	}

	CustomGameEventManager:Send_ServerToAllClients( "pudgewars_vote_blocks_update", vote_update_info )
end

function OnPlayerVote100( Index,keys )
	print("Vote 100")

	PudgeWarsMode.vote_100_votes = PudgeWarsMode.vote_100_votes + 1

	local vote_update_info = 
	{
		votes_50 = PudgeWarsMode.vote_50_votes,
		votes_75 = PudgeWarsMode.vote_75_votes,
		votes_100 = PudgeWarsMode.vote_100_votes,
	}

	CustomGameEventManager:Send_ServerToAllClients( "pudgewars_vote_blocks_update", vote_update_info )
end

function PudgeWarsMode:AbilityUsed(keys)
	local playerID = keys.PlayerID
	local abilityName = keys.abilityname
	local hero = PudgeArray[playerID].pudgeunit

	for _, hero in pairs(HeroList:GetAllHeroes()) do
		if hero:GetPlayerID() == playerID then
			if abilityName == "item_tome_of_health" then
				if self.health_tome_modifier_item then
				else
					self.health_tome_modifier_item = CreateItem("item_health_tome_modifiers", hero, hero) 
				end
				local modifier_item = self.health_tome_modifier_item
				modifier_item:ApplyDataDrivenModifier(hero, hero, "modifier_health_tome", { duration = -1 }) 
			end

			if abilityName == "item_tome_of_damage" then
				PudgeArray[playerID].damagetomes = PudgeArray[playerID].damagetomes + 1
			end
		end
	end
end

function PudgeWarsMode:CloseServer()
	-- Just exit
	SendToServerConsole('exit')
end

function PudgeWarsMode:ItemPickedUp( keys )
	print("[PUDGEWARS] ItemPickedUp")
	local playerID = keys.PlayerID
	local itemname = keys.itemname
	local item_ent = EntIndexToHScript( keys.ItemEntityIndex )
	local hero = PlayerResource:GetSelectedHeroEntity(keys.PlayerID)
	local item_owner = item_ent:GetPurchaser()
	local item_cost = item_ent:GetCost()
	local item_level = nil
	local item_short_name = nil
	local inventory_item_level = nil
	local result_level = nil
	local new_item = nil
	local combination_has_happened = false
	local inventory_item_name = nil

	-- Dissalow people from picking up other people's items
	if hero == item_owner then
	else
		if string.find(itemname,"item_lycan_paw") or string.find(itemname,"item_naix_jaw") or string.find(itemname, "item_grappling_hook") or string.find(itemname, "item_tiny_arm") or string.find(itemname, "item_barathrum_lantern") or string.find(itemname, "item_techies_explosive_barrel") or string.find(itemname, "item_strygwyr_claw") or string.find(itemname, "item_ricochet_turbine") or string.find(itemname, "item_pudgewars_earthshaker_totem") then
			UTIL_RemoveImmediate(item_ent)
			local item_pos = hero:GetAbsOrigin()
			local item = CreateItem(itemname, item_owner, nil)
			local item_drop = CreateItemOnPosition(item_pos)
			if item_drop then
					item_drop:SetContainedItem( item )
			end
			item:SetPurchaser(item_owner)
		end
	end

	if hero == item_owner then
		-- Grab item level and short version of name
		if string.find(itemname,"item_lycan_paw") or string.find(itemname,"item_naix_jaw") or string.find(itemname, "item_grappling_hook") or string.find(itemname, "item_tiny_arm") or string.find(itemname, "item_barathrum_lantern") or string.find(itemname, "item_techies_explosive_barrel") or string.find(itemname, "item_strygwyr_claw") or string.find(itemname, "item_ricochet_turbine") or string.find(itemname, "item_pudgewars_earthshaker_totem") then
			if string.find(itemname, "2") then
				item_level = 2
				item_short_name = string.sub(itemname, 1, string.len(itemname) - 2)
			elseif string.find(itemname, "3") then
				item_level = 3
				item_short_name = string.sub(itemname, 1, string.len(itemname) - 2)
			elseif string.find(itemname, "4") then
				item_level = 4
				item_short_name = string.sub(itemname, 1, string.len(itemname) - 2)
			elseif string.find(itemname, "5") then
				item_level = 5
				item_short_name = string.sub(itemname, 1, string.len(itemname) - 2)
			else
				item_level = 1
				item_short_name = itemname
			end

			-- Look for repeated item in player inventory
			for i = 0, 11 do
				local item = hero:GetItemInSlot(i)
				if item then
					if string.find(item:GetAbilityName(), item_short_name) and item ~= item_ent and combination_has_happened == false then
						print('has repeated item')
						-- Store name in variable
						inventory_item_name = item:GetAbilityName()

						-- Remove old items
						UTIL_RemoveImmediate(item)
						UTIL_RemoveImmediate(item_ent)

						-- Get inventory item level
						inventory_item_level = string.sub(inventory_item_name, string.len(inventory_item_name), string.len(inventory_item_name))
						if inventory_item_level ~= '2' and inventory_item_level ~= '3' and inventory_item_level ~= '4' and inventory_item_level ~= '5' then
								inventory_item_level = '1'
						end

						-- Find the resultant level
						print('inventory_item_level is ' .. inventory_item_level)
						print('picked up item level is ' .. item_level)
						result_level = inventory_item_level + item_level
						print('result level is ' .. result_level)

						-- Grant the player the appropriate level item and give him gold back if it is past 5
						if result_level > 5 then
							print('result larger than 5')
							newItem = CreateItem(item_short_name .. '_5', hero, nil)
							hero:AddItem(newItem)
							hero:ModifyGold(item_cost * (result_level - 5), true, 1)
						else
							print('result smaller than 5')
							newItem = CreateItem(item_short_name .. '_' .. result_level, hero, nil)
							hero:AddItem(newItem)
						end

						-- Make sure nothing happens twice
						combination_has_happened = true
					end
				end
			end
		end    
	end
end

function PudgeWarsMode:OnNPCSpawned( keys )
	local spawnedUnit = EntIndexToHScript( keys.entindex )
	local player = spawnedUnit:GetPlayerOwner()

	if spawnedUnit:GetUnitName() == "npc_vision_dummy" then
		spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_tower_truesight_aura", {duration = 30})
		spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_invisible", {})
	elseif string.find(spawnedUnit:GetUnitName(), "npc_dota_mine") then
		spawnedUnit:AddAbility('vision_dummy_passive')
		local spawnedUnitPassive = spawnedUnit:FindAbilityByName('vision_dummy_passive')
		spawnedUnitPassive:SetLevel(1)
	elseif spawnedUnit:GetUnitName() == "npc_dummy_rune_diretide" or spawnedUnit:GetUnitName() == "npc_dummy_rune_lightning" or spawnedUnit:GetUnitName() == "npc_dummy_rune_haste" or spawnedUnit:GetUnitName() == "npc_dummy_rune_gold" or spawnedUnit:GetUnitName() == "npc_dummy_rune_ion" or spawnedUnit:GetUnitName() == "npc_dummy_rune_fire" or spawnedUnit:GetUnitName() == "npc_dummy_rune_dynamite" then
		PudgeWarsMode:MoveRune(spawnedUnit)
	elseif string.find(spawnedUnit:GetUnitName(), "barrier") then
		local owner = spawnedUnit:GetOwner()
		spawnedUnit:SetForwardVector(owner:GetForwardVector())

		PudgeWarsMode:CreateTimer(DoUniqueString("clear_space"), {
			endTime = GameRules:GetGameTime() + 0.07,
			callback = function(reflex, args)
			FindClearSpaceForUnit(spawnedUnit, spawnedUnit:GetAbsOrigin(), true ) 
			return
		end})
	elseif spawnedUnit:GetUnitName() == "npc_dota_hero_pudge" then
		if spawnedUnit:GetPlayerOwnerID() ~= -1 then
			if PudgeArray[ spawnedUnit:GetPlayerOwnerID() ] == null then
				PudgeWarsMode:InitPudge( spawnedUnit )

				local vote_update_info = 
				{
					votes_50 = self.vote_50_votes,
					votes_75 = self.vote_75_votes,
					votes_100 = self.vote_100_votes,
					vote_visible = self.is_voting,
				}
				
				CustomGameEventManager:Send_ServerToPlayer( player,"pudgewars_vote_update", vote_update_info )
			end
		end
	end
end

function PudgeWarsMode:OnLevelUp( keys )
	local player = EntIndexToHScript(keys.player)
	local hero = player:GetAssignedHero()
	local hero_level = hero:GetLevel()

	local extra_ab_points = {17, 19, 21, 22, 23, 24}

	for i = 0, #extra_ab_points do
		if hero_level == extra_ab_points[i] then
			hero:SetAbilityPoints(hero:GetAbilityPoints() + 1)
		end
	end

	if hero_level > 40 then
		hero:SetAbilityPoints(hero:GetAbilityPoints() - 1)
	end
end

function PudgeWarsMode:AutoAssignPlayer(keys)
	print ('[PUDGEWARS] AutoAssignPlayer FIXED')
	PudgeWarsMode:CaptureGameMode()

	local entIndex = keys.index+1
	local ply = EntIndexToHScript(entIndex)
	local playerID = ply:GetPlayerID()

	self.vUserIds[keys.userid] = ply
	self.vSteamIds[PlayerResource:GetSteamAccountID(playerID)] = ply

	-- If we're not on D2MODD.in, assign players round robin to teams
	if not USE_LOBBY and playerID == -1 then
		if #self.vRadiant > #self.vDire then
			-- ply:SetTeam(DOTA_TEAM_BADGUYS)
			--ply:__KeyValueFromInt('teamnumber', DOTA_TEAM_BADGUYS)
			table.insert (self.vDire, ply)
		else
			-- ply:SetTeam(DOTA_TEAM_GOODGUYS)
			--ply:__KeyValueFromInt('teamnumber', DOTA_TEAM_GOODGUYS)
			table.insert (self.vRadiant, ply)
		end

		playerID = ply:GetPlayerID()
	end  

	self.vPlayers[playerID] = ply
end


function PudgeWarsMode:OnItemPurchased(keys)
	-- The playerID of the hero who is buying something
	local plyID = keys.PlayerID
	if not plyID then return end

	local playerID = keys.PlayerID
	local itemname = keys.itemname
	local hero = PlayerResource:GetSelectedHeroEntity(keys.PlayerID)

	for i=0,11 do
		local item = hero:GetItemInSlot(i)

		if item then
			if item:GetAbilityName() == itemname then
				local itempurchased = item

				if itemname == "item_tome_of_damage" then
					if PudgeArray[playerID].damagetomes >= 10 then
						local cost  = itempurchased:GetCost()
						if itempurchased:GetCurrentCharges() == 1 then
							UTIL_RemoveImmediate(itempurchased)
						else
							itempurchased:SetCurrentCharges(itempurchased:GetCurrentCharges() - 1)
						end
						hero:ModifyGold(cost, true, 1)
					end
				end

				if itemname == 'item_lycan_paw' or itemname == 'item_naix_jaw' or itemname == 'item_grappling_hook' or itemname == 'item_tiny_arm' or itemname == 'item_barathrum_lantern' or itemname == 'item_techies_explosive_barrel' or itemname == 'item_strygwyr_claw' or itemname == 'item_ricochet_turbine' or itemname == 'item_pudgewars_earthshaker_totem' then
					PudgeWarsMode:UpgradeItem(itemname,item,itempurchased,hero)
				end
			end
		end
	end
end


function PudgeWarsMode:Think()
	-- If the game's over, it's over.
	if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		local plyCount = 0

		for i=0,9 do
			if PlayerResource:IsValidPlayer(i) then
				plyCount = plyCount + 1
			end
		end

	--  statcollection.addStats({
	--    player_count = plyCount
	--    })
	--  statcollection.addStats({
	--    modes = {"first_to_" .. PudgeWarsMode.kills_to_win}
	--    })
	--  print("[PUDGEWARS] SENDING STATS")
		--send stats - Stats get sent automatically now
		--statcollection.sendStats()
		return
	end

	if PudgeWarsMode.is_voting then
		local vote_timer_table =
		{
			time_elapsed = GameRules:GetGameTime() - PudgeWarsMode.vote_start_time,
		}
		CustomGameEventManager:Send_ServerToAllClients( "pudgewars_vote_timer_update", vote_timer_table )
	end

	-- Track game time, since the dt passed in to think is actually wall-clock time not simulation time.
	local now = GameRules:GetGameTime()
	--print("now: " .. now)
	if PudgeWarsMode.t0 == nil then
		PudgeWarsMode.t0 = now
	end
	local dt = now - PudgeWarsMode.t0
	PudgeWarsMode.t0 = now

	--PudgeWarsMode:thinkState( dt )

	-- Process timers
	for k,v in pairs(PudgeWarsMode.timers) do
		local bUseGameTime = false
		if v.useGameTime and v.useGameTime == true then
			bUseGameTime = true;
		end
		-- Check if the timer has finished
		if (bUseGameTime and GameRules:GetGameTime() > v.endTime) or (not bUseGameTime and Time() > v.endTime) then
			-- Remove from timers list
			PudgeWarsMode.timers[k] = nil

			-- Run the callback
			local status, nextCall = pcall(v.callback, PudgeWarsMode, v)

			-- Make sure it worked
			if status then
				-- Check if it needs to loop
				if nextCall then
					-- Change it's end time
					v.endTime = nextCall
					PudgeWarsMode.timers[k] = v
				end

			else
				-- Nope, handle the error
				PudgeWarsMode:HandleEventError('Timer', k, nextCall, v)
			end
		end
	end

	-- Apply slow modifier if slow rune is picked up
	if RUNE_SLOW ~= false then
		for _, hero in pairs(HeroList:GetAllHeroes()) do
			if not hero:HasModifier("modifier_slow_rune") then
				hero:AddNewModifier(hero, nil, "modifier_slow_rune", {})
			end
		end
	else
		for _, hero in pairs(HeroList:GetAllHeroes()) do
			if hero:HasModifier("modifier_slow_rune") then
				hero:RemoveModifierByName("modifier_slow_rune")
			end
		end
	end

	return THINK_TIME
end

function PudgeWarsMode:HandleEventError(name, event, err, v)
	-- This gets fired when an event throws an error

	-- Log to console
	print(err)

	-- Ensure we have data
	name = tostring(name or 'unknown')
	event = tostring(event or 'unknown')
	err = tostring(err or 'unknown')

	-- Tell everyone there was an error
	Say(nil, name .. ' threw an error on event '..event, false)
	Say(nil, err, false)
		
	if v.errorcallback then
		v.errorcallback() -- call the errorcallback specified by the timer
	end

	-- Prevent loop arounds
	if not self.errorHandled then
		-- Store that we handled an error
		self.errorHandled = true
	end
end

function PudgeWarsMode:CreateTimer(name, args)
	--[[
	args: {
	endTime = Time you want this timer to end: Time() + 30 (for 30 seconds from now),
	useGameTime = use Game Time instead of Time()
	callback = function(frota, args) to run when this timer expires,
	text = text to display to clients,
	send = set this to true if you want clients to get this,
	persist = bool: Should we keep this timer even if the match ends?
	}

	If you want your timer to loop, simply return the time of the next callback inside of your callback, for example:

	callback = function()
	return Time() + 30 -- Will fire again in 30 seconds
	end
	]]

	if not args.endTime or not args.callback then
		print("Invalid timer created: "..name)
		return
	end

	-- Store the timer
	self.timers[name] = args
end

function PudgeWarsMode:RemoveTimer(name)
	-- Remove this timer
	self.timers[name] = nil
end

function PudgeWarsMode:RemoveTimers(killAll)
	local timers = {}

	-- If we shouldn't kill all timers
	if not killAll then
		-- Loop over all timers
		for k,v in pairs(self.timers) do
			-- Check if it is persistant
			if v.persist then
				-- Add it to our new timer list
				timers[k] = v
			end
		end
	end

	-- Store the new batch of timers
	self.timers = timers
end


function PudgeWarsMode:OnEntityKilled(keys)
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
		killedUnit:SetTimeUntilRespawn(self.RESPAWN_TIME)

		if killedUnit:GetTeam() == DOTA_TEAM_BADGUYS then
			if killerEntity:GetTeam() == 2 then
				self.scoreRadiant = self.scoreRadiant + 1
				CustomNetTables:SetTableValue("game_score", "team_score", {radiant_score = self.scoreRadiant, dire_score = self.scoreDire})
			end
		elseif killedUnit:GetTeam() == DOTA_TEAM_GOODGUYS then
			if killerEntity:GetTeam() == 3 then
				self.scoreDire = self.scoreDire + 1
				CustomNetTables:SetTableValue("game_score", "team_score", {radiant_score = self.scoreRadiant, dire_score = self.scoreDire})
			end
		end

		if self.scoreDire >= self.kills_to_win then
			GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
			GameRules:MakeTeamLose(DOTA_TEAM_GOODGUYS)
			GameRules:Defeated()
		elseif self.scoreRadiant >= self.kills_to_win then
			GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
			GameRules:MakeTeamLose(DOTA_TEAM_BADGUYS)
			GameRules:Defeated()
		end
	end
end
