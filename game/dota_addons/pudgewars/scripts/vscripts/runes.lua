print("[RUNES] Runes start loading")
function PudgeWarsMode:RuneHooked(unit,caster,rune_type)
    --If a rune was hooked. Only haste for now...
    --Kill rune, give caster the bonus from runes, give everybody else debuffs thorugh dummy units (if needed).
    if rune_type == 1 then
        --Hyperspeed rune
        --Slows everybody with aura, the caster has haste so isnt affected by it.
        sendAMsg("HYPERSPEED!")
        caster:AddNewModifier(caster,nil, "modifier_rune_haste", {duration = 15}) 
        
        --Add particle effect on the hyperspeed caster
        local hyper_particle = _G.rune_spell_caster_good:FindAbilityByName("pudge_wars_hyper_speed_particles")
        _G.rune_spell_caster_good:CastAbilityOnTarget(caster,hyper_particle,0)

        local haste_rune_dummy_unit = CreateUnitByName( "npc_dummy_slow_auro", Vector(0,0,0), true, nil, nil, DOTA_TEAM_NOTEAM)
	haste_rune_dummy_unit:AddNewModifier(_G.haste_rune_dummy_unit, nil, 'modifier_invulnerable', {})
        local abil = haste_rune_dummy_unit:FindAbilityByName("rune_slow")
        abil:SetLevel(1)
	
	PudgeWarsMode:CreateTimer(DoUniqueString("hasterune"), {
            endTime = GameRules:GetGameTime() + 15,
	    useGameTime = true,
            callback = function(reflex, args)
		haste_rune_dummy_unit:ForceKill(false)
		haste_rune_dummy_unit:RemoveSelf()
		haste_rune_dummy_unit = nil
		return
            end
          })

    elseif rune_type == 2 then
        --Gold rune
        sendAMsg("GOLD!")
    elseif rune_type == 3 then
        --Ion Rune
        sendAMsg("SHIELD BARRIER!")
        local abil_ion = _G.rune_spell_caster_good:FindAbilityByName("pudge_wars_ion_shell")
        _G.rune_spell_caster_good:CastAbilityOnTarget(caster,abil_ion,0)
        _G.shield_carrier = caster
        local start_time = GameRules:GetGameTime()
        PudgeWarsMode:CreateTimer(DoUniqueString("shiledbarrier"), {
            endTime = GameRules:GetGameTime(),
	    useGameTime = true,
            callback = function(reflex, args)
                local center_vec = _G.shield_carrier:GetAbsOrigin()
                local units = Entities:FindAllInSphere(center_vec, 400)
                for k,v in pairs(units) do
                    if IsValidEntity(v) and string.find(v:GetClassname(), "pudge") and v ~= _G.shield_carrier then
                        dealDamage(_G.shield_carrier,v,15)
                    end
                end
                if GameRules:GetGameTime() - start_time >=12 then
                    _G.shield_carrier = nil
                    return
                end
                return GameRules:GetGameTime() + 0.1
            end
          })
    elseif rune_type == 4 then
        sendAMsg("FIRE!")
        PudgeArray[ caster:GetPlayerOwnerID() ].use_flame = true
        PudgeWarsMode:CreateTimer(DoUniqueString("shiledbarrier"), {
            endTime = GameRules:GetGameTime() + 24,
	    useGameTime = true,
            callback = function(reflex, args)
                PudgeArray[ caster:GetPlayerOwnerID() ].use_flame = false
                for key,flame in pairs(self.all_flame_hooks) do
                   if flame then
		       print("destroy flame")
                      flame:Destroy()
		    end
		    self.all_flame_hooks[key] = nil
                end
                return
            end
          })
    elseif rune_type == 5 then
        --Dynamite rune
        sendAMsg("DYNAMITE!")
        caster:AddNewModifier(caster,nil,"modifier_item_mask_of_madness_berserk",{duration = 10})
        PudgeWarsMode:CreateTimer(DoUniqueString("dynamite"), {
            endTime = GameRules:GetGameTime() + 10,
	    useGameTime = true,
            callback = function(reflex, args)
                local center_vec = caster:GetAbsOrigin()
                local units = Entities:FindAllInSphere(center_vec, 400)
                    for k,v in pairs(units) do
                        if IsValidEntity(v) and string.find(v:GetClassname(), "pudge") and v ~= caster then
                            dealDamage(caster,v,10000)
                            local headshotParticle = ParticleManager:CreateParticle( 'tinker_missle_explosion', PATTACH_OVERHEAD_FOLLOW, v)
                            local headshotPos = v:GetOrigin()
                            ParticleManager:SetParticleControl( headshotParticle, 4, Vector( headshotPos.x, headshotPos.y, headshotPos.z) )
			end
                    end
                    --Kill pudge last to give him all EXP and stuff
                    caster:EmitSound('pudgewars_mine_explode')
                    dealDamage(caster,caster,10000)
                    local headshotParticle = ParticleManager:CreateParticle( 'tinker_missle_explosion', PATTACH_OVERHEAD_FOLLOW, caster)
                    local headshotPos = caster:GetOrigin()
                    ParticleManager:SetParticleControl( headshotParticle, 4, Vector( headshotPos.x, headshotPos.y, headshotPos.z) )
                    return
		end
		})

	    PudgeWarsMode:CreateTimer(DoUniqueString("dynamite3"), {
            endTime = GameRules:GetGameTime() + 7,
	    useGameTime = true,
            callback = function(reflex, args)
                    sendAMsg("3")
                    caster:EmitSound('pudgewars_ticker')
                    return
		end
		})
	    PudgeWarsMode:CreateTimer(DoUniqueString("dynamite2"), {
            endTime = GameRules:GetGameTime() + 8,
	    useGameTime = true,
            callback = function(reflex, args)
                    sendAMsg("2")
                    caster:EmitSound('pudgewars_ticker')
                    return
		end
		})
	    PudgeWarsMode:CreateTimer(DoUniqueString("dynamite1"), {
            endTime = GameRules:GetGameTime() + 9,
	    useGameTime = true,
            callback = function(reflex, args)
                    sendAMsg("1")
                    caster:EmitSound('pudgewars_ticker')
                    return
		end
		})
    elseif rune_type == 6 then
	sendAMsg("THUNDER!")
        local abil_lightning = _G.rune_spell_caster_good:FindAbilityByName("pudge_wars_lightning_effect")
        _G.rune_spell_caster_good:CastAbilityOnTarget(caster,abil_lightning,0)
    end
    --Kill rune and remove it to stop death animation
    PudgeWarsMode:RuneHookedParticle(caster)
    dealDamage(caster, unit, 12000)
 
    --unit:RemoveSelf()
end

function PudgeWarsMode:RuneHookedParticle(unit)
    local runeParticle = ParticleManager:CreateParticle( 'sven_spell_gods_strength_wave', PATTACH_OVERHEAD_FOLLOW, unit)
    local runePos = unit:GetOrigin()
    ParticleManager:SetParticleControl( runeParticle, 4, Vector( runePos.x, runePos.y, runePos.z) )
end

function PudgeWarsMode:SpawnRune()
    local rune_type = 6--RandomInt(1,6)
    if rune_type==1 then   
        local rune = CreateUnitByName( "npc_dummy_rune_haste", Vector(0,-1500,0), true, nil, nil, DOTA_TEAM_NOTEAM)
        rune:AddNewModifier(rune,nil,"modifier_phased", {})
    elseif rune_type==2 then
        local rune = CreateUnitByName( "npc_dummy_rune_gold", Vector(0,-1500,0), true, nil, nil, DOTA_TEAM_NOTEAM)
        rune:AddNewModifier(rune,nil,"modifier_phased", {})
    elseif rune_type==3 then
        local rune = CreateUnitByName( "npc_dummy_rune_ion", Vector(0,-1500,0), true, nil, nil, DOTA_TEAM_NOTEAM)
        rune:AddNewModifier(rune,nil,"modifier_phased", {})
    elseif rune_type==4 then
        local rune = CreateUnitByName( "npc_dummy_rune_fire", Vector(0,-1500,0), true, nil, nil, DOTA_TEAM_NOTEAM)
        rune:AddNewModifier(rune,nil,"modifier_phased", {})
    elseif rune_type==5 then
        local rune = CreateUnitByName( "npc_dummy_rune_dynamite", Vector(0,-1500,0), true, nil, nil, DOTA_TEAM_NOTEAM) 
        rune:AddNewModifier(rune,nil,"modifier_phased", {})
    elseif rune_type==6 then
	local rune = CreateUnitByName( "npc_dummy_rune_lightning", Vector(0,-1500,0), true, nil, nil, DOTA_TEAM_NOTEAM)
	rune:AddNewModifier(rune,nil,"modifier_phased",{})
    end
end

function PudgeWarsMode:MoveRune(spawnedUnit)
    --Move the unit until it reaches y=1900 
    PudgeWarsMode:CreateTimer(DoUniqueString("moverune"), {
        endTime = GameRules:GetGameTime(),
        useGameTime = true,
        callback = function(reflex, args)
	    if not IsValidEntity(spawnedUnit) or not spawnedUnit:IsAlive() then return end

	    local vec_move_to = spawnedUnit:GetOrigin() + Vector(0,14,0)
            if vec_move_to.y >= 1900 then
                spawnedUnit:ForceKill(false)
		return
            else
                spawnedUnit:SetAbsOrigin(vec_move_to)
		return GameRules:GetGameTime()
            end
	end
    })   
end
