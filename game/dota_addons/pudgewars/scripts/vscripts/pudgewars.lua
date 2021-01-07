USE_LOBBY = false
THINK_TIME = FrameTime()

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
end

function PudgeWarsMode:new( o )
	print ( '[PUDGEWARS] PudgeWarsMode:new' )
	o = o or {}
	setmetatable( o, PudgeWarsMode )
	return o
end

function PudgeWarsMode:InitGameMode()
	print('[PUDGEWARS] Starting to load Pudgewars gamemode...')

	CustomGameEventManager:RegisterListener("setting_vote", Dynamic_Wrap(PudgeWarsMode, "OnSettingVote"))

	-- Setup rules
	GameRules:SetHeroRespawnEnabled(true)
	GameRules:SetUseUniversalShopMode(false)
	GameRules:SetHeroSelectionTime(0.0)
	GameRules:SetPreGameTime(PRE_GAME_TIME)
	GameRules:SetTreeRegrowTime(TREE_REGROW_TIME)
	GameRules:SetPostGameTime(POST_GAME_TIME)
	GameRules:SetHeroMinimapIconScale(0.8)
	GameRules:SetCreepMinimapIconScale(0)
	GameRules:SetRuneMinimapIconScale(0.7)
	GameRules:SetSameHeroSelectionEnabled(true)
	GameRules:SetHideKillMessageHeaders(true)
	GameRules:GetGameModeEntity():SetCustomGameForceHero("npc_dota_hero_pudge")
	GameRules:GetGameModeEntity():SetFixedRespawnTime(FIXED_RESPAWN_TIME) 
	GameRules:SetFirstBloodActive(true)
	GameRules:SetHideKillMessageHeaders(false)

	if IsInToolsMode() then
		GameRules:SetCustomGameSetupAutoLaunchDelay(2.0)
	end

	self.itemKV = LoadKeyValues("scripts/npc/items.txt")
	for k,v in pairs(LoadKeyValues("scripts/npc/npc_items_custom.txt")) do
		if not self.itemKV[k] then
			self.itemKV[k] = v
		end
	end

	self.itemIDs = {}
	for k,v in pairs(self.itemKV) do
		if type(v) == "table" and v.ID then
			self.itemIDs[v.ID] = k
		end
	end

	print('[PUDGEWARS] Rules set')

	-- deprecated
--	InitLogFile( "log/pudgewars.txt","")

	-- Hooks
	ListenToGameEvent('entity_killed', Dynamic_Wrap(self, 'OnEntityKilled'), self)
	ListenToGameEvent('player_connect_full', Dynamic_Wrap(self, 'AutoAssignPlayer'), self)
	ListenToGameEvent('dota_item_purchased', Dynamic_Wrap(self, 'OnItemPurchased'), self)
	ListenToGameEvent('dota_player_used_ability', Dynamic_Wrap(self, 'AbilityUsed'), self)
--	ListenToGameEvent('dota_item_picked_up', Dynamic_Wrap( self, 'ItemPickedUp' ), self )
	ListenToGameEvent('npc_spawned', Dynamic_Wrap( self, 'OnNPCSpawned'), self)
	ListenToGameEvent('dota_player_gained_level', Dynamic_Wrap( self, 'OnLevelUp'), self)
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(self, 'OnGameRulesStateChange'), self)
	ListenToGameEvent('player_chat', Dynamic_Wrap(self, 'OnPlayerChat'), self)
	GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(self, "OrderFilter"), self)

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

	--runes
	_G.all_flame_hooks = {}

	--tomes
	self.health_tome_modifier_item = nil

	PudgeWarsMode:StartTimers()
	PudgeWarsMode:SpawnRuneSpellCasters()
	PudgeWarsMode:SpawnVisionDummies()
	PudgeWarsMode:SpawnFuntainDummy()

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
		-- Override the normal camera distance.  Usual is 1134
		GameMode:SetCameraDistanceOverride( 1134.0 )
		-- Set Buyback options
		GameMode:SetBuybackEnabled( false )
		-- Override the top bar values to show your own settings instead of total deaths
		GameMode:SetTopBarTeamValuesOverride ( true )
		-- Use custom hero level maximum and your own XP per level
		GameMode:SetUseCustomHeroLevels( true )
		GameMode:SetCustomHeroMaxLevel( MAX_LEVEL )
		GameMode:SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )
		GameMode:SetAnnouncerDisabled(true)

		FULL_ABANDON_TIME = 10.0

		print( '[PUDGEWARS] NOT Beginning Think' ) 
		GameMode:SetContextThink("PudgewarsThink", Dynamic_Wrap( PudgeWarsMode, 'Think' ), THINK_TIME )
	end 
end

function PudgeWarsMode:OnGameRulesStateChange(keys)
	local newState = GameRules:State_Get()

	if newState == DOTA_GAMERULES_STATE_PRE_GAME then
		GameRules:GetGameModeEntity():SetCustomDireScore(0)
		InitCampfires()
	elseif newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		local kills_to_win = {}
		kills_to_win[1] = 50
		kills_to_win[2] = 75
		kills_to_win[3] = 100
		kills_to_win[4] = 200

		CustomNetTables:SetTableValue("game_score" ,"max_score", {kills = kills_to_win[api:GetCustomGamemode()]})
		-- start slower thinker to avoid lags
		Timers:CreateTimer(function()
			self:SlowThink()
			return 1.0
		end)

		GameRules:SendCustomMessage("Good luck, have fun! May the headshot be with you.", 0, 0)

		-- start spawn rune timer
		Timers:CreateTimer(function()
			PudgeWarsMode:SpawnRune()
			return RUNE_SPAWN_TIME
		end)

		-- start gold tick time
		Timers:CreateTimer(function()
			if GameRules:State_Get() == DOTA_GAMERULES_STATE_POST_GAME then return nil end

			for i = 0, PlayerResource:GetPlayerCount() - 1 do
				if PlayerResource:IsValidPlayerID(i) then
					PlayerResource:ModifyGold(i, GOLD_PER_TICK, true, DOTA_ModifyGold_GameTick)
				end
			end

			return GOLD_TICK_TIME
		end)
	end
end

function PudgeWarsMode:SlowThink()
	if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then return nil end

	for _, hero in pairs(HeroList:GetAllHeroes()) do
		-- model bug fix
--		if PudgeArray[hero:GetPlayerID()].modelName == "" then
--			PudgeWarsMode:AssignHookModel(hero)    
--		end

		if PlayerResource:GetConnectionState(hero:GetPlayerID()) <= 2 and hero.anti_afk ~= false then
			hero.anti_afk = false
			hero:RespawnHero(false, false)
			hero:RemoveModifierByName("modifier_command_restricted")
			hero:RemoveModifierByName("modifier_invulnerable")
		elseif PlayerResource:GetConnectionState(hero:GetPlayerID()) > 2 and hero.anti_afk ~= true then
			if hero:IsAlive() then
				hero.anti_afk = true
				FindClearSpaceForUnit(hero, Entities:FindByName(nil, "anti_afk_"..hero:GetTeamNumber()):GetAbsOrigin(), true)
				hero:AddNewModifier(hero, nil, "modifier_command_restricted", {})
				hero:AddNewModifier(hero, nil, "modifier_invulnerable", {})
			end
		end

		local has_barrel_5 = false
		local has_grappling_5 = false
		local has_totem_5 = false

		if hero:FindAbilityByName("pudge_wars_abilities_down"):IsHidden() then
			for j = 0, 8 do
				local item = hero:GetItemInSlot(j)
				if item and IsValidEntity(item) then
					if has_barrel_5 == false then
						has_barrel_5 = item:GetAbilityName() == "item_techies_explosive_barrel" and item:GetLevel() == 5
					end
					if has_grappling_5 == false then
						has_grappling_5 = item:GetAbilityName() == "item_grappling_hook" and item:GetLevel() == 5
					end
					if has_totem_5 == false then
						has_totem_5 = item:GetAbilityName() == "item_pudgewars_earthshaker_totem" and item:GetLevel() == 5
					end
				end
			end
		end

		if hero:FindAbilityByName("pudge_wars_abilities_down"):IsHidden() then
			if has_barrel_5 then
				if hero:HasAbility("pudge_wars_empty1") then
					hero:RemoveAbility("pudge_wars_empty1")
					hero:AddAbility("techies_explosive_barrel_detonate"):SetLevel(1)
				end
			elseif has_barrel_5 == false then
				if hero:HasAbility("techies_explosive_barrel_detonate") then
					hero:RemoveAbility("techies_explosive_barrel_detonate")
					hero:AddAbility("pudge_wars_empty1"):SetLevel(1)
				end
			end

			if has_grappling_5 then
				if hero:HasAbility("pudge_wars_empty2") then
					hero:RemoveAbility("pudge_wars_empty2")
					hero:AddAbility("grappling_hook_blink"):SetLevel(1)
				end
			elseif has_grappling_5 == false then
				if hero:HasAbility("grappling_hook_blink") then
					hero:RemoveAbility("grappling_hook_blink")
					hero:AddAbility("pudge_wars_empty2"):SetLevel(1)
				end
			end

			if has_totem_5 then
				if hero:HasAbility("pudge_wars_empty3") then
					hero:RemoveAbility("pudge_wars_empty3")
					hero:AddAbility("earthshaker_totem_fissure"):SetLevel(1)
				end
			elseif has_totem_5 == false then
				if hero:HasAbility("earthshaker_totem_fissure") then
					hero:RemoveAbility("earthshaker_totem_fissure")
					hero:AddAbility("pudge_wars_empty3"):SetLevel(1)
				end
			end
		end
	end

	if not IsInToolsMode() then
		if not TEAM_ABANDON then
			TEAM_ABANDON = {} -- 10 second to abandon, is_abandoning?, player_count.
			TEAM_ABANDON[2] = {FULL_ABANDON_TIME, false, 0}
			TEAM_ABANDON[3] = {FULL_ABANDON_TIME, false, 0}
		end

		TEAM_ABANDON[2][3] = PlayerResource:GetPlayerCountForTeam(2)
		TEAM_ABANDON[3][3] = PlayerResource:GetPlayerCountForTeam(3)

		for ID = 0, PlayerResource:GetPlayerCount() -1 do
			local team = PlayerResource:GetTeam(ID)

			if PlayerResource:GetConnectionState(ID) ~= 2 then -- if disconnected then
				TEAM_ABANDON[team][3] = TEAM_ABANDON[team][3] -1
			end

			if TEAM_ABANDON[team][3] > 0 then
				TEAM_ABANDON[team][2] = false
			else
				if TEAM_ABANDON[team][2] == false then
					local abandon_text = "Radiant team has disconnected, game will end in "..FULL_ABANDON_TIME.." seconds..."
					if team == 3 then
						abandon_text = "Dire team has disconnected, game will end in "..FULL_ABANDON_TIME.." seconds..."
					end

					Notifications:BottomToAll({text = abandon_text, duration = TEAM_ABANDON[team][1], style = {color = "DodgerBlue"} })
				end

				TEAM_ABANDON[team][2] = true
				TEAM_ABANDON[team][1] = TEAM_ABANDON[team][1] -1

				if TEAM_ABANDON[2][1] <= 0 then
					GAME_WINNER_TEAM = 3
					GameRules:SetGameWinner(3)
				elseif TEAM_ABANDON[3][1] <= 0 then
					GAME_WINNER_TEAM = 2
					GameRules:SetGameWinner(2)
				end
			end
		end
	end

	-- Destroy runes when reaching destination
	local runes = FindUnitsInRadius(2, Entities:FindByName(nil, "kill_rune_point"):GetAbsOrigin(), nil, 200, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_DAMAGE_FLAG_NONE, FIND_ANY_ORDER, false)

	if #runes > 0 then
		for _, rune in pairs(runes) do
			rune:ForceKill(false)
		end
	end
end

function PudgeWarsMode:AbilityUsed(keys)
	local playerID = keys.PlayerID
	local abilityName = keys.abilityname

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
--[[
function PudgeWarsMode:ItemPickedUp( keys )
	print("[PUDGEWARS] ItemPickedUp")
	local playerID = keys.PlayerID
	local itemname = keys.itemname
	local item_ent = EntIndexToHScript( keys.ItemEntityIndex )
	local hero = PlayerResource:GetSelectedHeroEntity(keys.PlayerID)
	local item_owner = item_ent:GetPurchaser()

	-- Dissalow people from picking up other people's items
	if hero ~= item_owner then
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
end
]]

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
			end
		end
	end
end

function PudgeWarsMode:Think()
	-- If the game's over, it's over.
	if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		local players = {}
		local xp_info = {}

		for i = 0, PlayerResource:GetPlayerCount() - 1 do
			-- Placeholders
			local player = PlayerResource:GetPlayer(i)
			player.steamid = PlayerResource:GetSteamID(i)
			players[i] = player

			local level = 1
			local title = "Rookie"
			local color = "#FFFFFF"
			local xp_shit = {}
			xp_shit.xp = 0
			xp_shit.max_xp = 100
			local progress = xp_shit

--			local level = GetXPLevelByXp(player.xp)
--			local title = GetTitleIXP(level)
--			local color = GetTitleColorIXP(title, true)
--			local progress = GetXpProgressToNextLevel(player.xp)

			if level and title and color and progress then
				table.insert(xp_info, {
					steamid = player.steamid,
					level = level,
					title = title,
					color = color,
					progress = progress
				})
			end
		end

		CustomGameEventManager:Send_ServerToAllClients("end_game", {
			players = players,
			xp_info = xp_info,
			info = {
				winner = GAME_WINNER_TEAM,
				id = 0,
				radiant_score = self.scoreRadiant,
				dire_score = self.scoreDire,
			},
		})

		return
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

-- new system, double votes for donators 
ListenToGameEvent('game_rules_state_change', function(keys)
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_HERO_SELECTION then
		-- If no one voted, default to IMBA 10v10 gamemode
		GameRules:SetCustomGameDifficulty(1)
		api:SetCustomGamemode(1)

		if PudgeWarsMode.VoteTable == nil then return end
		local votes = PudgeWarsMode.VoteTable

		for category, pidVoteTable in pairs(votes) do
			-- Tally the votes into a new table
			local voteCounts = {}
			for pid, vote in pairs(pidVoteTable) do
				local gamemode = vote[1]
				local vote_count = vote[2]
				if not voteCounts[vote[1]] then voteCounts[vote[1]] = 0 end
				print(pid, vote[1], vote[2])
				voteCounts[vote[1]] = voteCounts[vote[1]] + vote[2]
			end

			-- Find the key that has the highest value (key=vote value, value=number of votes)
			local highest_vote = 0
			local highest_key = ""
			for k, v in pairs(voteCounts) do
				print(k, v)
				if v > highest_vote then
					highest_key = k
					highest_vote = v
				end
			end

			-- Check for a tie by counting how many values have the highest number of votes
			local tieTable = {}
			for k, v in pairs(voteCounts) do
				print(k, v)
				if v == highest_vote then
					table.insert(tieTable, k[1])
				end
			end

			-- Resolve a tie by selecting a random value from those with the highest votes
			if table.getn(tieTable) > 1 then
				print("Vote System: TIE!")
				highest_key = tieTable[math.random(table.getn(tieTable))]
			end

			-- Act on the winning vote
			if category == "gamemode" then
				api:SetCustomGamemode(highest_key)
			end

			-- Act on the winning vote
			if category == "difficulty" then
				GameRules:SetCustomGameDifficulty(highest_key)
			end

			print(category .. ": " .. highest_key)
		end
	end
end, nil)

local donator_list = {}
donator_list[1] = 5 -- Lead-Dev
donator_list[2] = 5 -- Dev
-- donator_list[3] = 5 -- Administrator
donator_list[4] = 1 -- Ember Donator
donator_list[7] = 2 -- Salamander Donator
donator_list[8] = 3 -- Icefrog Donator
donator_list[9] = 3 -- Gaben Donator

function PudgeWarsMode:OnSettingVote(keys)
	local pid = keys.PlayerID

	print(keys)

	if not PudgeWarsMode.VoteTable then PudgeWarsMode.VoteTable = {} end
	if not PudgeWarsMode.VoteTable[keys.category] then PudgeWarsMode.VoteTable[keys.category] = {} end

	if pid >= 0 then
		if not PudgeWarsMode.VoteTable[keys.category][pid] then PudgeWarsMode.VoteTable[keys.category][pid] = {} end

		PudgeWarsMode.VoteTable[keys.category][pid][1] = keys.vote

		if donator_list[api:GetDonatorStatus(pid)] then
			PudgeWarsMode.VoteTable[keys.category][pid][2] = donator_list[api:GetDonatorStatus(pid)]
		else
			PudgeWarsMode.VoteTable[keys.category][pid][2] = 1
		end
	end

--	Say(nil, keys.category, false)
--	Say(nil, tostring(keys.vote), false)

	-- TODO: Finish votes show up
	CustomGameEventManager:Send_ServerToAllClients("send_votes", {category = keys.category, vote = keys.vote, table = PudgeWarsMode.VoteTable[keys.category]})
end

-- Custom game-modes as per api:GetCustomGamemode():
-- 1: Standard
-- 2: Mutation
-- 3: Super Frantic
-- 4: Diretide
-- 5: Same Hero Selection

--[[

ListenToGameEvent('game_rules_state_change', function(keys)
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_HERO_SELECTION then		
		-- If no one voted, default to IMBA 10v10 gamemode
		GameRules:SetCustomGameDifficulty(2)

		if PudgeWarsMode.VoteTable == nil then return end
		local votes = PudgeWarsMode.VoteTable

		for category, pidVoteTable in pairs(votes) do
			-- Tally the votes into a new table
			local voteCounts = {}
			for pid, vote in pairs(pidVoteTable) do
				if not voteCounts[vote] then voteCounts[vote] = 0 end
				voteCounts[vote] = voteCounts[vote] + 1
			end

			print(voteCounts)

			-- Find the key that has the highest value (key=vote value, value=number of votes)
			local highest_vote = 0
			local highest_key = ""
			for k, v in pairs(voteCounts) do
				if v > highest_vote then
					highest_key = k
					highest_vote = v
				end
			end

			print("Highest vote:", highest_vote)
			-- if vote count is lower than player count / 4, default to whatever the standard is
			if highest_vote < 5 then
				if GetMapName() == "imba_10v10" then
					highest_key = 3
				else
					highest_key = 1
				end
			else
				-- Check for a tie by counting how many values have the highest number of votes
				local tieTable = {}
				for k, v in pairs(voteCounts) do
					if v == highest_vote then
						table.insert(tieTable, k)
					end
				end

				-- Resolve a tie by selecting a random value from those with the highest votes
				if table.getn(tieTable) > 1 then
					print("Vote System: TIE!")
					highest_key = tieTable[math.random(table.getn(tieTable))]
				end
			end

			-- Act on the winning vote
			if category == "gamemode" then
				api:SetCustomGamemode(highest_key)
			end

			-- Act on the winning vote
--			if category == "difficulty" then
--				GameRules:SetCustomGameDifficulty(highest_key)
--			end

			print(category .. ": " .. highest_key)
		end
	elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		GameRules:GetGameModeEntity():SetPauseEnabled(true)
	end
end, nil)

function PudgeWarsMode:OnSettingVote(keys)
	local pid = keys.PlayerID

	if not PudgeWarsMode.VoteTable then
		PudgeWarsMode.VoteTable = {}
	end

	if not PudgeWarsMode.VoteTable[keys.category] then
		PudgeWarsMode.VoteTable[keys.category] = {}
	end

	if pid >= 0 then
		PudgeWarsMode.VoteTable[keys.category][pid] = keys.vote
	end

--	Say(nil, keys.category, false)
--	Say(nil, tostring(keys.vote), false)

	-- TODO: Finish votes show up
	CustomGameEventManager:Send_ServerToAllClients("send_votes", {category = keys.category, vote = keys.vote, table = PudgeWarsMode.VoteTable[keys.category]})
end

--]]