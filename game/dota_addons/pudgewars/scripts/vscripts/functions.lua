print("[FUNCTIONS] functions loading")

function PudgeWarsMode:SetAbilToLevelOne( spawnedUnit , hookAbility)
    if spawnedUnit:HasAbility(hookAbility) then
        local ability = spawnedUnit:FindAbilityByName(hookAbility)
        ability:SetLevel(1)
    end
end

function PudgeWarsMode:UpdateUpgradePoints( unit )
    if unit ~= nil then
        for i = 0,40 do
            if unit:HasAbility("pudge_wars_upgrade_points_" .. i) == true then
                local upgradeSkill = unit:FindAbilityByName("pudge_wars_upgrade_points_" .. i)
                unit:RemoveAbility("pudge_wars_upgrade_points_" .. i)
                unit:RemoveModifierByName("pudge_wars_upgrade_points_" .. i .. "_modifier")
            end
        end
        unit:AddAbility('pudge_wars_upgrade_points_' .. PudgeArray[unit:GetPlayerOwnerID()].upgradePoints)
        local upgradeSkill = unit:FindAbilityByName('pudge_wars_upgrade_points_' .. PudgeArray[unit:GetPlayerOwnerID()].upgradePoints)
        if upgradeSkill then
            upgradeSkill:SetLevel(1)
        end
    end
end

function PudgeWarsMode:AssignHookModel(hero)
    PudgeArray[hero:GetPlayerOwnerID()].modelName  = "none"
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

function PudgeWarsMode:UpgradeItem(itemname,item,itempurchased, hero)
    for j=0,11 do
        local item = hero:GetItemInSlot(j)
        if item and IsValidEntity(item) and item ~= itempurchased and itempurchased then
            if item:GetAbilityName() == itemname .. '_5' then
                local cost  = itempurchased:GetCost()
                UTIL_RemoveImmediate(itempurchased)
                hero:ModifyGold(cost, true, 1)
                break
            end
            if item and IsValidEntity(item) and item:GetAbilityName() == itemname .. '_4' then
                UTIL_RemoveImmediate(item)
                UTIL_RemoveImmediate(itempurchased)
                local newItem = CreateItem(itemname .. '_5', hero, nil)
                hero:AddItem(newItem)
                if PudgeArray[ hero:GetPlayerOwnerID() ].has_max_level_timer == false then
		        PudgeArray[ hero:GetPlayerOwnerID()].has_max_level_timer = true
                	PudgeWarsMode:CreateTimer(DoUniqueString("max_level_check" .. hero:GetPlayerOwnerID()), {
            			endTime = GameRules:GetGameTime() + 1,
            			callback = function(reflex, args)
                	   	
            				local detonateAbility = hero:FindAbilityByName("techies_explosive_barrel_detonate")
					local blinkAbility = hero:FindAbilityByName("grappling_hook_blink")
					local fissureAbility = hero:FindAbilityByName("earthshaker_totem_fissure")
					local hasMaxBarrel = hero:HasItemInInventory("item_techies_explosive_barrel_5")
					local hasMaxGrappling = hero:HasItemInInventory("item_grappling_hook_5")
					local hasMaxTotem = hero:HasItemInInventory("item_pudgewars_earthshaker_totem_5")
					local hasMaxNain = hero:HasItemInInventory("item_pudgewars_earthshaker_totem_5")
					
					if hero:HasAbility("pudge_wars_abilities_down") == false then
						if hasMaxBarrel == true and hero:HasAbility("pudge_wars_empty1") then
							hero:RemoveAbility("pudge_wars_empty1")
							hero:AddAbility("techies_explosive_barrel_detonate")
						PudgeWarsMode:SetAbilToLevelOne( hero , "techies_explosive_barrel_detonate")
						end
						if hasMaxGrappling == true and hero:HasAbility("pudge_wars_empty2") then
							hero:RemoveAbility("pudge_wars_empty2")
							hero:AddAbility("grappling_hook_blink")
						PudgeWarsMode:SetAbilToLevelOne( hero , "grappling_hook_blink")
						end
						if hasMaxTotem == true and hero:HasAbility("pudge_wars_empty3") then
							hero:RemoveAbility("pudge_wars_empty3")
							hero:AddAbility("earthshaker_totem_fissure")
						PudgeWarsMode:SetAbilToLevelOne( hero , "earthshaker_totem_fissure")
						end
				
						if hasMaxBarrel == false and hero:HasAbility("techies_explosive_barrel_detonate") then
							hero:RemoveAbility("techies_explosive_barrel_detonate")
							hero:AddAbility("pudge_wars_empty1")
						PudgeWarsMode:SetAbilToLevelOne( hero , "pudge_wars_empty1")
						end
						if hasMaxGrappling == false and hero:HasAbility("grappling_hook_blink") then
							hero:RemoveAbility("grappling_hook_blink")
							hero:AddAbility("pudge_wars_empty2")
						PudgeWarsMode:SetAbilToLevelOne( hero , "pudge_wars_empty2")
						end
						if hasMaxTotem == false and hero:HasAbility("earthshaker_totem_fissure") then
							hero:RemoveAbility("earthshaker_totem_fissure")
							hero:AddAbility("pudge_wars_empty3")
						PudgeWarsMode:SetAbilToLevelOne( hero , "pudge_wars_empty3")
						end
					end
	
                	   	return GameRules:GetGameTime() + 1
					end
					})	       
                	break
                end
            end
            if item and IsValidEntity(item) and item:GetAbilityName() == itemname .. '_3' then
                UTIL_RemoveImmediate(item)
                UTIL_RemoveImmediate(itempurchased)
                local newItem = CreateItem(itemname .. '_4', hero, nil)
                hero:AddItem(newItem)
                break
            end
            if item and IsValidEntity(item) and item:GetAbilityName() == itemname .. '_2' then
                UTIL_RemoveImmediate(item)
                UTIL_RemoveImmediate(itempurchased)
                local newItem = CreateItem(itemname .. '_3', hero, nil)
                hero:AddItem(newItem)
                break
            end
            if item and IsValidEntity(item) and item:GetAbilityName() == itemname then
                UTIL_RemoveImmediate(item)
                UTIL_RemoveImmediate(itempurchased)
                local newItem = CreateItem(itemname .. '_2', hero, nil)
                hero:AddItem(newItem)   
                break                             
            end
         end
    end
end

function PudgeWarsMode:CreateVisionUnit(unitname, unitOrigin, team)
    --ToDo: Add KV-files
    VisionDummy = CreateUnitByName( unitname, unitOrigin, false, nil, nil, team )
    VisionDummy:AddAbility('vision_dummy_passive')
    VisionDummy:AddNewModifier(VisionDummy, nil, 'modifier_invulnerable', {})
    VisionDummy:AddNewModifier(VisionDummy, nil, 'modifier_phased', {})
    local VisionDummyPassive = VisionDummy:FindAbilityByName('vision_dummy_passive')
    VisionDummyPassive:SetLevel(1)
    
end

function PudgeWarsMode:SpawnFuntainDummy()
    print("[FUNCTIONS] SpawnFuntainDummy")
    --ToDo: Add KV-files
    VisionDummy = CreateUnitByName( "npc_funtain_dummy", Vector(0,0,0), false, nil, nil, DOTA_TEAM_BADGUYS )
    VisionDummy:AddAbility('vision_dummy_passive')
    VisionDummy:AddNewModifier(VisionDummy, nil, 'modifier_invulnerable', {})
    local VisionDummyPassive = VisionDummy:FindAbilityByName('funtain_healing')
    VisionDummyPassive:SetLevel(1)
    local VisionDummyPassive2 = VisionDummy:FindAbilityByName('vision_dummy_passive')
    VisionDummyPassive:SetLevel(1)
end

function PudgeWarsMode:SpawnVisionDummies()
    --Vision in base 
    print("[FUNCTIONS] SpawnVisionDummies")
    PudgeWarsMode:CreateVisionUnit("npc_vision_dummy_2", Vector(-512, 0, 196), DOTA_TEAM_GOODGUYS)
    PudgeWarsMode:CreateVisionUnit("npc_vision_dummy_2", Vector(-1408, 0, 196), DOTA_TEAM_GOODGUYS)
    PudgeWarsMode:CreateVisionUnit("npc_vision_dummy_2", Vector(-1776, 0, 196), DOTA_TEAM_GOODGUYS)
    PudgeWarsMode:CreateVisionUnit("npc_vision_dummy_2", Vector(0, 128, 0), DOTA_TEAM_GOODGUYS)

    PudgeWarsMode:CreateVisionUnit("npc_vision_dummy_2", Vector(512, 0, 196), DOTA_TEAM_BADGUYS)
    PudgeWarsMode:CreateVisionUnit("npc_vision_dummy_2", Vector(1408, 0, 196), DOTA_TEAM_BADGUYS)
    PudgeWarsMode:CreateVisionUnit("npc_vision_dummy_2", Vector(1776, 0, 196), DOTA_TEAM_BADGUYS)
    PudgeWarsMode:CreateVisionUnit("npc_vision_dummy_2", Vector(0, 128, 0), DOTA_TEAM_BADGUYS)   

    PudgeWarsMode:CreateVisionUnit("npc_vision_dummy_2", Vector(0, 0, 196), DOTA_TEAM_GOODGUYS)
    PudgeWarsMode:CreateVisionUnit("npc_vision_dummy_2", Vector(0, -1500, 196), DOTA_TEAM_GOODGUYS)
    PudgeWarsMode:CreateVisionUnit("npc_vision_dummy_2", Vector(0, 1500, 196), DOTA_TEAM_GOODGUYS)

    PudgeWarsMode:CreateVisionUnit("npc_vision_dummy_2", Vector(0, 0, 196), DOTA_TEAM_BADGUYS)
    PudgeWarsMode:CreateVisionUnit("npc_vision_dummy_2", Vector(0, -1500, 196), DOTA_TEAM_BADGUYS)
    PudgeWarsMode:CreateVisionUnit("npc_vision_dummy_2", Vector(0, 1500, 196), DOTA_TEAM_BADGUYS) 
    
    local y_pos = -1500
    local start_x = 145
    for i=0,30 do
	if i == 12 then
	    start_x = start_x + 60
	elseif i == 18 then
	    start_x = 145
	end
	PudgeWarsMode:CreateVisionUnit("npc_vision_dummy_2", Vector(start_x, y_pos, 128), DOTA_TEAM_BADGUYS)
	PudgeWarsMode:CreateVisionUnit("npc_vision_dummy_2", Vector(-start_x, y_pos, 128), DOTA_TEAM_BADGUYS)
	
	PudgeWarsMode:CreateVisionUnit("npc_vision_dummy_2", Vector(start_x,y_pos, 128), DOTA_TEAM_GOODGUYS)
	PudgeWarsMode:CreateVisionUnit("npc_vision_dummy_2", Vector(-start_x, y_pos, 128), DOTA_TEAM_GOODGUYS)
	y_pos = y_pos + 100
    end

end

function PudgeWarsMode:SpawnRuneSpellCasters()
    print("[FUNCTIONS] Spawn Spell Casters")
    local abil_ion_good = nil
    local hyper_particle = nil
    local lightning_effect = nil

    -- ToDo: Add KV-files

    _G.rune_spell_caster_good = CreateUnitByName( "npc_ion_dummy", Vector(0,0,0), false, nil, nil, DOTA_TEAM_GOODGUYS )
    _G.rune_spell_caster_good:AddNewModifier(_G.rune_spell_caster_good , nil, 'modifier_invulnerable', {})
    _G.rune_spell_caster_good:AddNewModifier(_G.rune_spell_caster_good , nil, 'modifier_phased', {})
    abil_ion_good = _G.rune_spell_caster_good:FindAbilityByName("pudge_wars_ion_shell")
    abil_ion_good:SetLevel(1)

    hyper_particle = _G.rune_spell_caster_good:FindAbilityByName("pudge_wars_hyper_speed_particles")
    hyper_particle:SetLevel(1)

    lightning_effect = _G.rune_spell_caster_good:FindAbilityByName("pudge_wars_lightning_effect")
    lightning_effect:SetLevel(1)
    
end

function PudgeWarsMode:StartTimers()
    --start timers that are running from the start
    print("[FUNCTIONS] Starting timer")
   
	--start a timer that waits for the game to be in progress
	PudgeWarsMode:CreateTimer(DoUniqueString("waitforgamestart"), {
	    endTime = GameRules:GetGameTime() + 1,
	    useGameTime = true,
	    callback = function(reflex, args)
	    	--wait for the game to be in progress
		if not ((GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME) or (GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS)) or not(has_been_in_wait_for_players)then
		    return GameRules:GetGameTime() + 1 
		end
	       
		PudgeWarsMode:StartVoting() -- start voting when game is in progress
	   return -- stop wait for game to being timer
	end
    })

    
    PudgeWarsMode:CreateTimer(DoUniqueString("waitforgamestartdebug"), {
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

function PudgeWarsMode:StartVoting()
    
    --Start voting when game is in progress. Wait 25  (vote time) seconds and start the game timers
    PudgeWarsMode:CreateTimer(DoUniqueString("voting"), {
	endTime = GameRules:GetGameTime() + 0,
	useGameTime = true,
	callback = function(reflex, args)
	    PudgeWarsMode:StopVoting()
	    PudgeWarsMode:LaunchTimers()
	    return
	end
    })

    --for key,ply in pairs(PudgeArray) do 
	--ply.pudgeunit:AddNewModifier(ply.pudgeunit,nil,"modifier_stunned", {})
    --end
    
    --wait two seconds to let stuff get ready..
    PudgeWarsMode:CreateTimer(DoUniqueString("waitforsf"), {
	endTime = GameRules:GetGameTime() + 2,
	useGameTime = true,
	callback = function(reflex, args)
	    GameRules:SendCustomMessage("Welcome to <font color='#CC6600'>Pudge Wars!</font>", 0, 0)
	    GameRules:SendCustomMessage("Created by  <font color='#CC6600'>Kobb</font> and <font color='#CC6600'>Aderum</font>", 0, 0)
	    GameRules:SendCustomMessage("For more information and credits go to  <font color='#CC6600'>\"http://d2pudgewars.com\"</font>", 0, 0)

	    --FireGameEvent('pwgm_start_win_vote', {})
        self.vote_start_time = GameRules:GetGameTime()
         local vote_update_info = 
        {
            votes_50 = self.vote_50_votes,
            votes_75 = self.vote_75_votes,
            votes_100 = self.vote_100_votes,
            vote_visible = true,
        }
        CustomGameEventManager:Send_ServerToAllClients( "pudgewars_vote_update", vote_update_info )
        self.is_voting = true
	    print("Fired startWinVote")


	    for key,ply in pairs(PudgeArray) do 
		  --ply.pudgeunit:AddNewModifier(ply.pudgeunit,nil,"modifier_stunned", {})
		local pudge = ply.pudgeunit
		--Assign modelName if it hasnt been done to stop model bug.
		if PudgeArray[pudge:GetPlayerOwnerID()].modelName == "" then
            if pudge then
		      PudgeWarsMode:AssignHookModel(pudge)    
		    end
        end
	    end
	    return
	end
    })
end

function PudgeWarsMode:LaunchTimers()
	
    --start spawn rune timer
    PudgeWarsMode:CreateTimer(DoUniqueString("spawnrune"), {
	endTime = GameRules:GetGameTime() + 40,
	useGameTime = true,
	callback = function(reflex, args)
	    PudgeWarsMode:SpawnRune()
	    return GameRules:GetGameTime() + 40
	end
    })

    --start give gold timer
    PudgeWarsMode:CreateTimer(DoUniqueString("goldtick"), {
	endTime = GameRules:GetGameTime() + 10,
	useGameTime = true,
	callback = function(reflex, args)
	    for key,ply in pairs(PudgeArray) do
		ply.pudgeunit:ModifyGold(25,false,0)
	    end
	    return GameRules:GetGameTime() + 10
	end
    })

    --start tree_regrow timer
    PudgeWarsMode:CreateTimer(DoUniqueString("goldtick"), {
	endTime = GameRules:GetGameTime() + 1,
	useGameTime = true,
	callback = function(reflex, args)
	    GridNav:RegrowAllTrees()
	    return GameRules:GetGameTime() + 1
	end
    })
end

function PudgeWarsMode:StopVoting()
    for key,ply in pairs(PudgeArray) do 
--	   ply.pudgeunit:RemoveModifierByName("modifier_stunned")
    end
    if self.vote_100_votes >= self.vote_75_votes and self.vote_100_votes >= self.vote_50_votes then
	self.kills_to_win = 100
    elseif self.vote_75_votes > self.vote_100_votes and self.vote_75_votes >= self.vote_50_votes then
	self.kills_to_win = 75
    else
	self.kills_to_win = 50
    end
    self.is_voting = false
    --FireGameEvent('pwgm_end_win_vote', {})

    local votes_for_50 = self.vote_50_votes
    local votes_for_75 = self.vote_75_votes
    local votes_for_100 = self.vote_100_votes
     local vote_update_info = 
        {
            votes_50 = votes_for_50,
            votes_75 = votes_for_75,
            votes_100 = votes_for_100,
            vote_visible = false,
        }
    CustomGameEventManager:Send_ServerToAllClients( "pudgewars_vote_update", vote_update_info )

    GameRules:SendCustomMessage("50 kills: " .. self.vote_50_votes .. " votes" ,0,0)
    GameRules:SendCustomMessage("75 kills: " .. self.vote_75_votes.. " votes",0,0)
    GameRules:SendCustomMessage("100 kills: " .. self.vote_100_votes .. " votes",0,0)
    GameRules:SendCustomMessage("First to " .. self.kills_to_win .. " wins!", 0,0)
end

function sendAMsg(msg)
    local centerMessage = {
        message = msg,
        duration = 1
    }
    FireGameEvent( "show_center_message", centerMessage)
end

function sendAMsgTime(msg, time)
    local centerMessage = {
        message = msg,
        duration = time
    }
    FireGameEvent( "show_center_message", centerMessage)
end

function PudgeWarsMode:RollBash(per)
    return RandomInt(1,100) <= per
end
