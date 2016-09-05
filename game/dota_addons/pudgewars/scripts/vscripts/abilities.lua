print("[ABILITIES] abilities loading")
-- A helper function for dealing damage from a source unit to a target unit.  Damage dealt is pure damage
function dealDamage(source, target, damage)
    if damage <= 0 or source == nil or target == nil then
	   return
    end

    --local dmgTable = {8192,4096,2048,1024,512,256,128,64,32,16,8,4,2,1}
    --local item = CreateItem( "item_deal_damage", source, source) --creates an item
    --
    --for i=1,#dmgTable do
	--   local val = dmgTable[i]
	--   local count = math.floor(damage / val)
	--   if count >= 1 then
	--       item:ApplyDataDrivenModifier( source, target, "dealDamage" .. val, {duration=0} )
	--       damage = damage - val
	--   end
    --end
    --UTIL_RemoveImmediate(item)
    --item = nil
    local damageTable = {
        victim = target,
        attacker = source,
        damage = damage,
        damage_type = DAMAGE_TYPE_PURE,
    }
 
    ApplyDamage(damageTable)
end

function castSpell(source, target, spell, spell_level, time_out)
    local caster = nil
    if damage == "" then
	return
    end
  
    if source ~= nil then
    	caster = CreateUnitByName("npc_dota_danger_indicator", target:GetAbsOrigin(), false, source, source, source:GetTeamNumber())
    else
    	caster = CreateUnitByName("npc_dota_danger_indicator", target:GetAbsOrigin(), false, nil, nil, DOTA_TEAM_NOTEAM)
    end


    caster:AddNewModifier(caster, nil, "modifier_invulnerable", {})
    caster:AddNewModifier(caster, nil, "modifier_phased", {})
    --local dummy = unit:FindAbilityByName("reflex_dummy_unit")
    --dummy:SetLevel(1)
   
    local mana = caster:GetMana()
  
    caster:AddAbility(spell)
    local ability = caster:FindAbilityByName( spell )
    ability:SetLevel(spell_level)
    diff = target:GetAbsOrigin() - caster:GetAbsOrigin()
    diff.z = 0
    caster:SetForwardVector(diff:Normalized())
  

    PudgeWarsMode:CreateTimer(DoUniqueString("spawn"), {
    endTime = GameRules:GetGameTime() + 0.070,
    useGameTime = true,
    callback = function(reflex, args)
	--Cast ability on target, wait time_out seconds and check if spell was scuccesfull
	caster:CastAbilityOnTarget(target, ability, 0 )

	  PudgeWarsMode:CreateTimer(DoUniqueString("spell"), {
	    endTime = GameRules:GetGameTime() + time_out,
	    useGameTime = true,
	    callback = function(reflex, args)
		--after time_out seconds check if the spell has successfully been cast
		if IsValidEntity(caster) and caster:GetMana() >= mana and mana ~= 0 and spell ~= "" then
		    --If it was not successfull, try it all again.
		    print ("[ABILITIES] WARNING: castSpell did not cast spell (Spell needs to have a mana cost) -- retrying : ")
		    castSpell(source, target, spell, spell_level, time_out)
		end
		caster:Destroy()
	    end
	  })   
    end
    })  
end

function castInstantSpell(caster, spell, spell_level, time_out)

    if caster == nil then
	return
    end
    if damage == "" then
	return
    end
  
    caster:AddNewModifier(caster, nil, "modifier_invulnerable", {})
    caster:AddNewModifier(caster, nil, "modifier_phased", {})
    --local dummy = unit:FindAbilityByName("reflex_dummy_unit")
    --dummy:SetLevel(1)
   
    local mana = caster:GetMana()
  
    caster:AddAbility(spell)
    local ability = caster:FindAbilityByName( spell )
    ability:SetLevel(spell_level)

    --Wait two frames to let the NPC spawn
    PudgeWarsMode:CreateTimer(DoUniqueString("spawn"), {
    endTime = GameRules:GetGameTime() + 0.070,
    useGameTime = true,
    callback = function(reflex, args)
	--Cast ability on target, wait time_out seconds and check if spell was scuccesfull
    if ability then
        caster:CastAbilityImmediately(ability, 0)
    end

	  PudgeWarsMode:CreateTimer(DoUniqueString("spell"), {
	    endTime = GameRules:GetGameTime() + time_out,
	    useGameTime = true,
	    callback = function(reflex, args)
		--after time_out seconds check if the spell has successfully been cast
		if IsValidEntity(caster) and caster:GetMana() >= mana and mana ~= 0 and spell ~= "" then
		    --If it was not successfull, try it all again.
		    print ("[ABILITIES] WARNING: castInstantSpell did not cast spell (Spell needs to have a mana cost) -- retrying : ")
		    castInstantSpell(caster, spell, spell_level, time_out)
		end
		caster:Destroy()
	    end
	  })   
    end
    })
end

function PudgeWarsMode:KillTarget(caster,unit)
   dealDamage(caster,unit,unit:GetMaxHealth() + 1000)
end

function applyRupture(source, target)
  local hasStrygwyr = false
  local ruptureLevel = nil
  if source ~= nil and target ~= nil then
    if source:GetTeam() ~= target:GetTeam() then 
      for i=0,5 do
        item = source:GetItemInSlot(i)
        if item and IsValidEntity(item) and item:GetAbilityName() == 'item_strygwyr_claw' then
          hasStrygwyr = true
          ruptureLevel = "1"
        elseif item and IsValidEntity(item) and item:GetAbilityName() == 'item_strygwyr_claw_2' then
          hasStrygwyr = true
          ruptureLevel = "2"
        elseif item and IsValidEntity(item) and item:GetAbilityName() == 'item_strygwyr_claw_3' then
          hasStrygwyr = true
          ruptureLevel = "3"
        elseif item and IsValidEntity(item) and item:GetAbilityName() == 'item_strygwyr_claw_4' then
          hasStrygwyr = true
          ruptureLevel = "4"
        elseif item and IsValidEntity(item) and item:GetAbilityName() == 'item_strygwyr_claw_5' then
          hasStrygwyr = true
          ruptureLevel = "5"
        end
      end

      if hasStrygwyr == true then
        ruptureUnit =  CreateUnitByName("npc_pudgewars_rupture_dummy", target:GetAbsOrigin(), false, source, source, source:GetTeamNumber())
        if ruptureUnit then
          ruptureUnit:AddNewModifier(ruptureUnit, nil, "modifier_invulnerable", {})
          ruptureUnit:AddNewModifier(ruptureUnit, nil, "modifier_phased", {})
          local ruptureAbilityName = "pudge_wars_bloodseeker_rupture_" .. ruptureLevel
          ruptureUnit:AddAbility(ruptureAbilityName)
          ruptureAbility = ruptureUnit:FindAbilityByName( ruptureAbilityName )
          if ruptureAbility then
            ruptureAbility:SetLevel(1)
            ruptureUnit:CastAbilityOnTarget(target, ruptureAbility, 0)
          end
          return ruptureUnit
        end
      end 
    end
  end
  return nil
end

function RevealUsed( keys )
    local targetUnit = keys.target_entities[1]
    local casterUnit = keys.caster

    for i=0,5 do
        local item = casterUnit:GetItemInSlot(i)
        if item then
            if item:GetAbilityName() == 'item_pudge_wars_reveal' then
                if item:GetCurrentCharges() == 1 then
                    UTIL_RemoveImmediate(item)
                else
                    item:SetCurrentCharges(item:GetCurrentCharges() - 1)
                end
            end
        end
    end
end

function WisdomTomeUsed( keys )
    local casterUnit = keys.caster
    local casterLevel = casterUnit:GetLevel()
    casterUnit:AddExperience(_G.XP_PER_LEVEL_TABLE[casterLevel + 1] - _G.XP_PER_LEVEL_TABLE[casterLevel], false, false)
end

function DamageTomeUsed( keys )
    local casterUnit = keys.caster
    local casterLevel = casterUnit:GetLevel()
    local playerID = casterUnit:GetPlayerOwnerID()

    if PudgeArray[playerID].damagetomes < 11 then
        local minDamage = casterUnit:GetBaseDamageMin()
        local maxDamage = casterUnit:GetBaseDamageMax()
        casterUnit:SetBaseDamageMin( minDamage )
        casterUnit:SetBaseDamageMax( maxDamage )
        local newMinDamage = casterUnit:GetBaseDamageMin()
        local newMaxDamage = casterUnit:GetBaseDamageMax()
        local damageDiff = newMinDamage - minDamage
        casterUnit:SetBaseDamageMin( newMinDamage - 2 * damageDiff )
        casterUnit:SetBaseDamageMax( newMaxDamage - 2 * damageDiff )
        local newNewMinDamage = casterUnit:GetBaseDamageMin()
        local newNewMaxDamage = casterUnit:GetBaseDamageMax()
        casterUnit:SetBaseDamageMin( newNewMinDamage - (damageDiff - 25))
        casterUnit:SetBaseDamageMax( newNewMaxDamage - (damageDiff - 25))

        for i=0,5 do
            local item = casterUnit:GetItemInSlot(i)
            if item then
            if item:GetAbilityName() == 'item_tome_of_damage' then
                if item:GetCurrentCharges() == 1 then
                    UTIL_RemoveImmediate(item)
                else
                    item:SetCurrentCharges(item:GetCurrentCharges() - 1)
                end
            end
            end
        end
    end

end

function HealthTomeUsed( keys )

end

function SpawnBarrier( keys )
    local point = keys.target_points[1]
    local caster = keys.caster
    local level = keys.SpellLevel

    CreateUnitByName( "npc_pudge_wars_barrier_" .. level, point, false, caster, caster, caster:GetTeam() ) 
end


function OnTinyArm( keys )
    local casterUnit = keys.caster
    local point = keys.target_points[1]
    local hasLevel5 = casterUnit:HasItemInInventory("item_tiny_arm_5")
    
    if point.x < -1440 or point.x > 1440 then
	for i=0,5 do
	    local item = casterUnit:GetItemInSlot(i)
	    if item and IsValidEntity(item) and string.find(item:GetAbilityName(), "item_tiny") then
		item:EndCooldown()
	    end
	end
	return
    end

    -- don't go on cooldown if there aren't any units
    local entities = Entities:FindAllInSphere(casterUnit:GetAbsOrigin(), 250)
    local count = 0
    for k,v in pairs(entities) do
        if string.find(v:GetClassname(), "pudge") or string.find(v:GetClassname(), "creep") then
            print(v:GetUnitName())
            if string.find(v:GetUnitName(), "pudge") or string.find(v:GetUnitName(), "mine") then 
                count = count + 1
            end
        end
    end
    if count <= 1 then
        for i=0,5 do
            local item = casterUnit:GetItemInSlot(i)
            if item and IsValidEntity(item) and string.find(item:GetAbilityName(), "item_tiny") then
                item:EndCooldown()
            end
        end
        return
    end

    --give them the ability and spawn dummy
    casterUnit:AddAbility("tiny_arm")
    local abil = casterUnit:FindAbilityByName("tiny_arm")
    abil:SetLevel(4)
    local targetUnit = CreateUnitByName("npc_tiny_arm_dummy", point, false, nil, nil, casterUnit:GetTeam()) 

    --start timer to remove ability
    PudgeWarsMode:CreateTimer(DoUniqueString("spell"), {
	    endTime = GameRules:GetGameTime() + .3,
	    useGameTime = true,
	    callback = function(reflex, args)
		casterUnit:RemoveAbility("tiny_arm")
		targetUnit:ForceKill(false)
	    end
	  })   

    if hasLevel5 then
        --start timer to stunf when target lands
	local startTime = GameRules:GetGameTime()
	PudgeWarsMode:CreateTimer(DoUniqueString("spell"), {
    	    endTime = GameRules:GetGameTime(),
	    useGameTime = true,
	    callback = function(reflex, args)
		local entities = Entities:FindAllInSphere(point, 200)
		for key,ent in pairs(entities) do
		   if (string.find(ent:GetClassname(), "pudge")) and (ent:HasModifier("modifier_tiny_toss")) then
			if ent:GetTeam() ~= casterUnit:GetTeam() then
			    ent:AddNewModifier(casterUnit, nil, "modifier_stunned", {duration=2})
			    dealDamage(casterUnit,ent,100)
			end
		    return
		   end
		end
		if GameRules:GetGameTime() - startTime > 10 then
		    return
		end
		return GameRules:GetGameTime()
	    end
	  })   	
    end
    --Execute the ability
    casterUnit:CastAbilityOnTarget( targetUnit, abil, casterUnit:GetPlayerOwnerID() )
end

function OnGrapplingHook( keys )
    local casterUnit = keys.caster
    local targetPoint = keys.target_points[1]

    casterUnit:AddAbility("pudge_wars_grappling_hook")
    local abil = casterUnit:FindAbilityByName("pudge_wars_grappling_hook")
    abil:SetLevel(1)
    
    --start timer to remove ability
    PudgeWarsMode:CreateTimer(DoUniqueString("spell"), {
	    endTime = GameRules:GetGameTime() + 5.5,
	    useGameTime = true,
	    callback = function(reflex, args)
		casterUnit:RemoveAbility("pudge_wars_grappling_hook")	
	    end
	  }) 

    if targetPoint ~= null then
        local order =
        {
            UnitIndex = casterUnit:entindex(),
            OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
            Position = targetPoint,
            AbilityIndex = abil:entindex()
        }
        ExecuteOrderFromTable(order)
    end
end

function OnGrapplingHook_2( keys )
    local casterUnit = keys.caster
    local targetPoint = keys.target_points[1]
    
    casterUnit:AddAbility("pudge_wars_grappling_hook_2")
    local abil = casterUnit:FindAbilityByName("pudge_wars_grappling_hook_2")
    abil:SetLevel(1)
    
    --start timer to remove ability
    PudgeWarsMode:CreateTimer(DoUniqueString("spell"), {
	    endTime = GameRules:GetGameTime() + 5.5,
	    useGameTime = true,
	    callback = function(reflex, args)
		casterUnit:RemoveAbility("pudge_wars_grappling_hook_2")	
	    end
	  })

    if targetPoint ~= null then
        local order =
        {
            UnitIndex = casterUnit:entindex(),
            OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
            Position = targetPoint,
            AbilityIndex = abil:entindex()
        }
        ExecuteOrderFromTable(order)
    end
end

function OnGrapplingHook_3( keys )
    local casterUnit = keys.caster
    local targetPoint = keys.target_points[1]

    casterUnit:AddAbility("pudge_wars_grappling_hook_3")
    local abil = casterUnit:FindAbilityByName("pudge_wars_grappling_hook_3")
    abil:SetLevel(1)
    
    --start timer to remove ability
    PudgeWarsMode:CreateTimer(DoUniqueString("spell"), {
	    endTime = GameRules:GetGameTime() + 5.5,
	    useGameTime = true,
	    callback = function(reflex, args)
		casterUnit:RemoveAbility("pudge_wars_grappling_hook_3")	
	    end
	  }) 

    if targetPoint ~= null then
        local order =
        {
            UnitIndex = casterUnit:entindex(),
            OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
            Position = targetPoint,
            AbilityIndex = abil:entindex()
        }
        ExecuteOrderFromTable(order)
    end
end

function OnGrapplingHook_4( keys )
    local casterUnit = keys.caster
    local targetPoint = keys.target_points[1]

    casterUnit:AddAbility("pudge_wars_grappling_hook_4")
    local abil = casterUnit:FindAbilityByName("pudge_wars_grappling_hook_4")
    abil:SetLevel(1)
    
    --start timer to remove ability
    PudgeWarsMode:CreateTimer(DoUniqueString("spell"), {
	    endTime = GameRules:GetGameTime() + 5.5,
	    useGameTime = true,
	    callback = function(reflex, args)
		casterUnit:RemoveAbility("pudge_wars_grappling_hook_4")	
	    end
	  }) 

    if targetPoint ~= null then
        local order =
        {
            UnitIndex = casterUnit:entindex(),
            OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
            Position = targetPoint,
            AbilityIndex = abil:entindex()
        }
        ExecuteOrderFromTable(order)
    end
end

function OnGrapplingHook_5( keys )
    local casterUnit = keys.caster
    local targetPoint = keys.target_points[1]

    casterUnit:AddAbility("pudge_wars_grappling_hook_5")
    local abil = casterUnit:FindAbilityByName("pudge_wars_grappling_hook_5")
    abil:SetLevel(1)
    
    --start timer to remove ability
    PudgeWarsMode:CreateTimer(DoUniqueString("spell"), {
	    endTime = GameRules:GetGameTime() + 5.5,
	    useGameTime = true,
	    callback = function(reflex, args)
		casterUnit:RemoveAbility("pudge_wars_grappling_hook_5")	
	    end
	  }) 

    if targetPoint ~= null then
        local order =
        {
            UnitIndex = casterUnit:entindex(),
            OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
            Position = targetPoint,
            AbilityIndex = abil:entindex()
        }
        ExecuteOrderFromTable(order)
    end
end

function OnUpgradeHookDamage( keys )
    local casterUnit = keys.caster
    local damageLevel = PudgeArray[casterUnit:GetPlayerOwnerID()].hookDamageLevel
    if PudgeArray[casterUnit:GetPlayerOwnerID()].upgradePoints > 0 then   -- Check if the hero has enough points to spend
        if PudgeArray[casterUnit:GetPlayerOwnerID()].hookDamageLevel < 10 then    --- Check if ability is not already max level
            --Assign modelName if it hasnt been done to stop model bug.
            if PudgeArray[casterUnit:GetPlayerOwnerID()].modelName == "" then
                PudgeWarsMode:AssignHookModel(casterUnit)    
            end 
            PudgeArray[casterUnit:GetPlayerOwnerID()].hookDamageLevel = PudgeArray[casterUnit:GetPlayerOwnerID()].hookDamageLevel + 1 --Increment hookDamageLevel by one if caster has leveled up, and if the hookDamageLevel is not at level 4
            PudgeArray[casterUnit:GetPlayerOwnerID()].upgradePoints = PudgeArray[casterUnit:GetPlayerOwnerID()].upgradePoints - 1
            PudgeWarsMode:UpdateUpgradePoints(casterUnit)
            if damageLevel == 0 then
                casterUnit:RemoveAbility("pudge_wars_upgrade_hook_damage")
                print("pudge_wars_upgrade_hook_damage removed")
            else
                casterUnit:RemoveAbility("pudge_wars_upgrade_hook_damage_" .. damageLevel)
                print("pudge_wars_upgrade_hook_damage_" .. damageLevel .. "removed")
            end
            casterUnit:AddAbility("pudge_wars_upgrade_hook_damage_" .. (damageLevel + 1))
            upgradeAbility = casterUnit:FindAbilityByName("pudge_wars_upgrade_hook_damage_" .. (damageLevel + 1))
            upgradeAbility:SetLevel(1)
        end
    end
end

function OnUpgradeHookDistance( keys )
    local casterUnit = keys.caster
    local distanceLevel = PudgeArray[casterUnit:GetPlayerOwnerID()].hookDistanceLevel
    if PudgeArray[casterUnit:GetPlayerOwnerID()].upgradePoints > 0 then   -- Check if the hero has enough points to spend
        if PudgeArray[casterUnit:GetPlayerOwnerID()].hookDistanceLevel < 10 then    --- Check if ability is not already max level
            --Assign modelName if it hasnt been done to stop model bug.
            if PudgeArray[casterUnit:GetPlayerOwnerID()].modelName == "" then
                PudgeWarsMode:AssignHookModel(casterUnit)    
            end 
            PudgeArray[casterUnit:GetPlayerOwnerID()].hookDistanceLevel = PudgeArray[casterUnit:GetPlayerOwnerID()].hookDistanceLevel + 1 --Increment hookDistanceLevel by one if caster has leveled up, and if the hookDistanceLevel is not at level 4
            PudgeArray[casterUnit:GetPlayerOwnerID()].upgradePoints = PudgeArray[casterUnit:GetPlayerOwnerID()].upgradePoints - 1
            PudgeWarsMode:UpdateUpgradePoints(casterUnit)
            if distanceLevel == 0 then
                casterUnit:RemoveAbility("pudge_wars_upgrade_hook_range")
                print("pudge_wars_upgrade_hook_range removed")
            else
                casterUnit:RemoveAbility("pudge_wars_upgrade_hook_range_" .. distanceLevel)
                print("pudge_wars_upgrade_hook_range_" .. distanceLevel .. "removed")
            end
            casterUnit:AddAbility("pudge_wars_upgrade_hook_range_" .. (distanceLevel + 1))
            upgradeAbility = casterUnit:FindAbilityByName("pudge_wars_upgrade_hook_range_" .. (distanceLevel + 1))
            upgradeAbility:SetLevel(1)
        end
    end
end

function OnUpgradeHookSpeed( keys )
    local casterUnit = keys.caster
    local speedLevel = PudgeArray[casterUnit:GetPlayerOwnerID()].hookSpeedLevel
    if PudgeArray[casterUnit:GetPlayerOwnerID()].upgradePoints > 0 then   -- Check if the hero has enough points to spend
        if PudgeArray[casterUnit:GetPlayerOwnerID()].hookSpeedLevel < 10 then    --- Check if ability is not already max level
            --Assign modelName if it hasnt been done to stop model bug.
            if PudgeArray[casterUnit:GetPlayerOwnerID()].modelName == "" then
                PudgeWarsMode:AssignHookModel(casterUnit)    
            end 
            PudgeArray[casterUnit:GetPlayerOwnerID()].hookSpeedLevel = PudgeArray[casterUnit:GetPlayerOwnerID()].hookSpeedLevel + 1 --Increment hookSpeedLevel by one if caster has leveled up, and if the hookSpeedLevel is not at level 4
            PudgeArray[casterUnit:GetPlayerOwnerID()].upgradePoints = PudgeArray[casterUnit:GetPlayerOwnerID()].upgradePoints - 1
            PudgeWarsMode:UpdateUpgradePoints(casterUnit)
            if speedLevel == 0 then
                casterUnit:RemoveAbility("pudge_wars_upgrade_hook_speed")
                print("pudge_wars_upgrade_hook_speed removed")
            else
                casterUnit:RemoveAbility("pudge_wars_upgrade_hook_speed_" .. speedLevel)
                print("pudge_wars_upgrade_hook_speed_" .. speedLevel .. "removed")
            end
            casterUnit:AddAbility("pudge_wars_upgrade_hook_speed_" .. (speedLevel + 1))
            upgradeAbility = casterUnit:FindAbilityByName("pudge_wars_upgrade_hook_speed_" .. (speedLevel + 1))
            upgradeAbility:SetLevel(1)
        end
    end
end

function OnUpgradeHookSize( keys )
    local casterUnit = keys.caster
    local sizeLevel = PudgeArray[casterUnit:GetPlayerOwnerID()].hookSizeLevel
    if PudgeArray[casterUnit:GetPlayerOwnerID()].upgradePoints > 0 then   -- Check if the hero has enough points to spend
        if PudgeArray[casterUnit:GetPlayerOwnerID()].hookSizeLevel < 10 then    --- Check if ability is not already max level
            --Assign modelName if it hasnt been done to stop model bug.
            if PudgeArray[casterUnit:GetPlayerOwnerID()].modelName == "" then
                PudgeWarsMode:AssignHookModel(casterUnit)    
            end 
            PudgeArray[casterUnit:GetPlayerOwnerID()].hookSizeLevel = PudgeArray[casterUnit:GetPlayerOwnerID()].hookSizeLevel + 1 --Increment hookSizeLevel by one if caster has leveled up, and if the hookSizeLevel is not at level 4
            PudgeArray[casterUnit:GetPlayerOwnerID()].upgradePoints = PudgeArray[casterUnit:GetPlayerOwnerID()].upgradePoints - 1
            PudgeWarsMode:UpdateUpgradePoints(casterUnit)
            if sizeLevel == 0 then
                casterUnit:RemoveAbility("pudge_wars_upgrade_hook_size")
                print("pudge_wars_upgrade_hook_size removed")
            else
                casterUnit:RemoveAbility("pudge_wars_upgrade_hook_size_" .. sizeLevel)
                print("pudge_wars_upgrade_hook_size_" .. sizeLevel .. "removed")
            end
            casterUnit:AddAbility("pudge_wars_upgrade_hook_size_" .. (sizeLevel + 1))
            upgradeAbility = casterUnit:FindAbilityByName("pudge_wars_upgrade_hook_size_" .. (sizeLevel + 1))
            upgradeAbility:SetLevel(1)
        end
    end
end

function OnAbilitiesUp( keys )
	local casterUnit = keys.caster
	local speedLevel = PudgeArray[casterUnit:GetPlayerOwnerID()].hookSpeedLevel
	local sizeLevel = PudgeArray[casterUnit:GetPlayerOwnerID()].hookSizeLevel 
	local distanceLevel = PudgeArray[casterUnit:GetPlayerOwnerID()].hookDistanceLevel 
	local damageLevel = PudgeArray[casterUnit:GetPlayerOwnerID()].hookDamageLevel
	casterUnit:RemoveAbility("pudge_wars_custom_hook")  
	casterUnit:RemoveAbility("pudge_wars_abilities_up")
	casterUnit:RemoveAbility("pudge_wars_empty1")
	casterUnit:RemoveAbility("pudge_wars_empty2")
	casterUnit:RemoveAbility("pudge_wars_empty3")
	casterUnit:RemoveAbility("techies_explosive_barrel_detonate")
	casterUnit:RemoveAbility("grappling_hook_blink")
	casterUnit:RemoveAbility("earthshaker_totem_fissure")

	if damageLevel ~= 0 then
		casterUnit:AddAbility("pudge_wars_upgrade_hook_damage_" .. damageLevel)
		PudgeWarsMode:SetAbilToLevelOne( casterUnit , "pudge_wars_upgrade_hook_damage_" .. damageLevel)
	else
		casterUnit:AddAbility("pudge_wars_upgrade_hook_damage")
		PudgeWarsMode:SetAbilToLevelOne( casterUnit , "pudge_wars_upgrade_hook_damage")
	end
	if distanceLevel ~= 0 then
		casterUnit:AddAbility("pudge_wars_upgrade_hook_range_" .. distanceLevel)
		PudgeWarsMode:SetAbilToLevelOne( casterUnit , "pudge_wars_upgrade_hook_range_" .. distanceLevel)
	else
		casterUnit:AddAbility("pudge_wars_upgrade_hook_range")
		PudgeWarsMode:SetAbilToLevelOne( casterUnit , "pudge_wars_upgrade_hook_range")	
	end
	if speedLevel ~= 0 then
		casterUnit:AddAbility("pudge_wars_upgrade_hook_speed_" .. speedLevel)
		PudgeWarsMode:SetAbilToLevelOne( casterUnit , "pudge_wars_upgrade_hook_speed_" .. speedLevel)
	else
		casterUnit:AddAbility("pudge_wars_upgrade_hook_speed")
		PudgeWarsMode:SetAbilToLevelOne( casterUnit , "pudge_wars_upgrade_hook_speed")
	end
	if sizeLevel ~= 0 then
		casterUnit:AddAbility("pudge_wars_upgrade_hook_size_" .. sizeLevel)
		PudgeWarsMode:SetAbilToLevelOne( casterUnit , "pudge_wars_upgrade_hook_size_" .. sizeLevel)
	else
		casterUnit:AddAbility("pudge_wars_upgrade_hook_size")
		PudgeWarsMode:SetAbilToLevelOne( casterUnit , "pudge_wars_upgrade_hook_size")
	end
	casterUnit:AddAbility('pudge_wars_abilities_down')
	PudgeWarsMode:SetAbilToLevelOne( casterUnit , "pudge_wars_abilities_down")
end

function OnAbilitiesDown( keys )
	local casterUnit = keys.caster
	local speedLevel = PudgeArray[casterUnit:GetPlayerOwnerID()].hookSpeedLevel
	local sizeLevel = PudgeArray[casterUnit:GetPlayerOwnerID()].hookSizeLevel 
	local distanceLevel = PudgeArray[casterUnit:GetPlayerOwnerID()].hookDistanceLevel 
	local damageLevel = PudgeArray[casterUnit:GetPlayerOwnerID()].hookDamageLevel
	casterUnit:RemoveAbility("pudge_wars_abilities_down")
	if sizeLevel ~= 0 then
		casterUnit:RemoveAbility("pudge_wars_upgrade_hook_size_" .. sizeLevel)
	else
		casterUnit:RemoveAbility("pudge_wars_upgrade_hook_size")
	end
	if speedLevel ~= 0 then
		casterUnit:RemoveAbility("pudge_wars_upgrade_hook_speed_" .. speedLevel)
	else
		casterUnit:RemoveAbility("pudge_wars_upgrade_hook_speed")
	end
	if damageLevel ~= 0 then
		casterUnit:RemoveAbility("pudge_wars_upgrade_hook_damage_" .. damageLevel)
	else
		casterUnit:RemoveAbility("pudge_wars_upgrade_hook_damage")
	end
	if distanceLevel ~= 0 then
		casterUnit:RemoveAbility("pudge_wars_upgrade_hook_range_" .. distanceLevel)
	else
		casterUnit:RemoveAbility("pudge_wars_upgrade_hook_range")
	end

	casterUnit:AddAbility("pudge_wars_custom_hook")
	PudgeWarsMode:SetAbilToLevelOne( casterUnit , "pudge_wars_custom_hook")
	if casterUnit:HasItemInInventory("item_techies_explosive_barrel_5") then
		casterUnit:AddAbility("techies_explosive_barrel_detonate")
		PudgeWarsMode:SetAbilToLevelOne( casterUnit , "techies_explosive_barrel_detonate")
	else
		casterUnit:AddAbility("pudge_wars_empty1")
		PudgeWarsMode:SetAbilToLevelOne( casterUnit, "pudge_wars_empty1")
	end
	if casterUnit:HasItemInInventory("item_grappling_hook_5") then
		casterUnit:AddAbility("grappling_hook_blink")
		PudgeWarsMode:SetAbilToLevelOne( casterUnit , "grappling_hook_blink")
	else
		casterUnit:AddAbility("pudge_wars_empty2")
		PudgeWarsMode:SetAbilToLevelOne( casterUnit, "pudge_wars_empty2")
	end
	if casterUnit:HasItemInInventory("item_pudgewars_earthshaker_totem_5") then
		casterUnit:AddAbility("earthshaker_totem_fissure")
		PudgeWarsMode:SetAbilToLevelOne( casterUnit , "earthshaker_totem_fissure")
	else
		casterUnit:AddAbility("pudge_wars_empty3")
		PudgeWarsMode:SetAbilToLevelOne( casterUnit, "pudge_wars_empty3")
	end    
	casterUnit:AddAbility("pudge_wars_abilities_up")
    PudgeWarsMode:SetAbilToLevelOne( casterUnit , "pudge_wars_abilities_up")
end

function OnTechiesExplosiveBarrelDetonate( keys )
    local caster = keys.caster
	
    PudgeWarsMode:CreateTimer(DoUniqueString("suicide3"), {
    endTime = GameRules:GetGameTime(),
    useGameTime = true,
    callback = function(reflex, args)
	    sendAMsg("3")
	    caster:EmitSound('Ability.XMark.Target_Movement')
	    return
	end
	})
    PudgeWarsMode:CreateTimer(DoUniqueString("suicide2"), {
    endTime = GameRules:GetGameTime() + 1,
    useGameTime = true,
    callback = function(reflex, args)
	    sendAMsg("2")
	    caster:EmitSound('Ability.XMark.Target_Movement')
	    return
	end
	})
    PudgeWarsMode:CreateTimer(DoUniqueString("suicide1"), {
    endTime = GameRules:GetGameTime() + 2,
    useGameTime = true,
    callback = function(reflex, args)
	    sendAMsg("1")
	    caster:EmitSound('Ability.XMark.Target_Movement')
	    
	    return
	end
	})

	
    PudgeWarsMode:CreateTimer(DoUniqueString("suicide1"), {
    endTime = GameRules:GetGameTime() + 3,
    useGameTime = true,
    callback = function(reflex, args)
	    local center_vec = caster:GetAbsOrigin()
	    local units = Entities:FindAllInSphere(center_vec, 200)
		for k,v in pairs(units) do
		if IsValidEntity(v) and string.find(v:GetClassname(), "pudge") and v ~= caster then
		    dealDamage(caster,v,v:GetMaxHealth() + 1000)
		    local headshotParticle = ParticleManager:CreateParticle( 'particles/units/heroes/hero_tinker/tinker_missle_explosion.vpcf', PATTACH_ABSORIGIN, v)
		    local headshotPos = v:GetOrigin()
		    ParticleManager:SetParticleControl( headshotParticle, 4, Vector( headshotPos.x, headshotPos.y, headshotPos.z) )
			end
	    end
	    --Kill pudge last to give him all EXP and stuff
	    caster:EmitSound('Hero_Alchemist.UnstableConcoction.Stun')
	    dealDamage(caster,caster,caster:GetMaxHealth() + 1000)
	    local headshotParticle = ParticleManager:CreateParticle( 'particles/units/heroes/hero_tinker/tinker_missle_explosion.vpcf', PATTACH_ABSORIGIN, caster)
	    local headshotPos = caster:GetOrigin()
	    ParticleManager:SetParticleControl( headshotParticle, 4, Vector( headshotPos.x, headshotPos.y, headshotPos.z) )
	    return
	end
	})
end

function MineSuicide( keys )
    local casterUnit = keys.caster
    casterUnit:ForceKill(false)
    casterUnit:EmitSound('Hero_Alchemist.UnstableConcoction.Stun')
end
