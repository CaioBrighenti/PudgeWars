print("[RUNES] Runes start loading")
function PudgeWarsMode:RuneHooked(unit,caster,rune_type)
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
	
        --remove the dummy unit that slows units after 15 seconds
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
        
        --Apply the ionshield particle to the caster
        local shiled_bar = ParticleManager:CreateParticle("particles/pw/shield_barrier.vpcf", PATTACH_RENDERORIGIN_FOLLOW, caster)
        _G.shield_carrier = caster
        local start_time = GameRules:GetGameTime()
        --for 12 seconds, deal 15 damage every server-tick to units in a 400-radius
        PudgeWarsMode:CreateTimer(DoUniqueString("shiledbarrier"), {
            endTime = GameRules:GetGameTime(),
	        useGameTime = true,
            callback = function(reflex, args)
                _G.shield_carrier = caster
                local center_vec = _G.shield_carrier:GetAbsOrigin()
                local units = Entities:FindAllInSphere(center_vec, 400)
                for k,v in pairs(units) do
                    if IsValidEntity(v) and string.find(v:GetClassname(), "pudge") and v ~= _G.shield_carrier then
                        dealDamage(_G.shield_carrier,v,15)
                    end
                end
                if GameRules:GetGameTime() - start_time >=12 then
                    _G.shield_carrier = nil
                    ParticleManager:DestroyParticle(shiled_bar,true)
                    return
                end
                return GameRules:GetGameTime() + 0.1
            end
          })
    elseif rune_type == 4 then
        sendAMsg("FIRE!")
        PudgeArray[ caster:GetPlayerOwnerID() ].use_flame = true
        --Set use_flame for the hook-spell, remove use_flame and all stored hooks after 24 seconds
        PudgeWarsMode:CreateTimer(DoUniqueString("shiledbarrier"), {
            endTime = GameRules:GetGameTime() + 24,
	        useGameTime = true,
            callback = function(reflex, args)
                PudgeArray[ caster:GetPlayerOwnerID() ].use_flame = false
                for key,flame in pairs(self.all_flame_hooks) do
                    if flame then
		              print("destroy flame")
                        flame:RemoveSelf()
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
                --kill all Pudges in a 400 radius after 10 seconds
                for k,v in pairs(units) do
                    if IsValidEntity(v) and string.find(v:GetClassname(), "pudge") and v ~= caster then
                        dealDamage(caster,v,10000)
                        local headshotParticle = ParticleManager:CreateParticle( 'particles/units/heroes/hero_tinker/tinker_missle_explosion.vpcf', PATTACH_OVERHEAD_FOLLOW, v)
                        local headshotPos = v:GetOrigin()
                        ParticleManager:SetParticleControl( headshotParticle, 4, Vector( headshotPos.x, headshotPos.y, headshotPos.z) )
		             end
                end
                --Kill pudge last to give him all EXP and stuff
                caster:EmitSound('Hero_Alchemist.UnstableConcoction.Stun')
                dealDamage(caster,caster,10000)
                local headshotParticle = ParticleManager:CreateParticle( 'particles/units/heroes/hero_tinker/tinker_missle_explosion.vpcf', PATTACH_OVERHEAD_FOLLOW, caster)
                local headshotPos = caster:GetOrigin()
                ParticleManager:SetParticleControl( headshotParticle, 4, Vector( headshotPos.x, headshotPos.y, headshotPos.z) )
                return
		end
		})

        --Visual and sound timers for the dynamite rune
	    PudgeWarsMode:CreateTimer(DoUniqueString("dynamite3"), {
            endTime = GameRules:GetGameTime() + 7,
	    useGameTime = true,
            callback = function(reflex, args)
                    sendAMsg("3")
                    caster:EmitSound('Ability.XMark.Target_Movement')
                    return
		end
		})
	    PudgeWarsMode:CreateTimer(DoUniqueString("dynamite2"), {
            endTime = GameRules:GetGameTime() + 8,
	    useGameTime = true,
            callback = function(reflex, args)
                    sendAMsg("2")
                    caster:EmitSound('Ability.XMark.Target_Movement')
                    return
		end
		})
	    PudgeWarsMode:CreateTimer(DoUniqueString("dynamite1"), {
            endTime = GameRules:GetGameTime() + 9,
	    useGameTime = true,
            callback = function(reflex, args)
                    sendAMsg("1")
                    caster:EmitSound('Ability.XMark.Target_Movement')
                    return
		end
		})
    elseif rune_type == 6 then
	    sendAMsg("THUNDER!")
        --cast "pudge_wars_lightning_effect" on the caster for visual and for letting the hook-spell know that it should do lightning
        local abil_lightning = _G.rune_spell_caster_good:FindAbilityByName("pudge_wars_lightning_effect")
        _G.rune_spell_caster_good:CastAbilityOnTarget(caster,abil_lightning,0)
    elseif rune_type == 7 then
        sendAMsg("SPOOKY!")
        EmitGlobalSound("diretide_select_target_Stinger")

        local tombLocation = caster:GetAbsOrigin()
        
        --Spawn tombstone
        local spookyId = ParticleManager:CreateParticle("particles/doto/generic_hero_status/death_tombstone_alt.vpcf", PATTACH_ABSORIGIN, caster) 
        ParticleManager:SetParticleControl(spookyId,0, tombLocation)
        ParticleManager:SetParticleControl(spookyId,1, tombLocation)
        ParticleManager:SetParticleControl(spookyId,2, tombLocation)
        
        --hide the caster
        caster:AddNewModifier(caster, nil, "modifier_obsidian_destroyer_astral_imprisonment_prison", {duration=8})

        --spawn the spooky unit
        local spookyUnit = CreateUnitByName("npc_dummy_rune_diretide_unit", tombLocation, true, caster,caster, caster:GetTeamNumber())
        spookyUnit:SetControllableByPlayer(caster:GetPlayerOwnerID(),true)
        spookyUnit:AddNewModifier(caster,nil, "modifier_invulnerable", {duration=8}) 

        --emit sound for the laserbeam
        StartSoundEvent("Hero_Phoenix.SunRay.Loop", spookyUnit)
        --EmitGlobalSound("Hero_Phoenix.SunRay.Loop")

        --attach the rope
        PudgeWarsMode:CreateTimer(DoUniqueString("spooky_rune"), {
            endTime = GameRules:GetGameTime() + 0.1,
            useGameTime = true,
            callback = function(reflex, args)
                if IsValidEntity(spookyUnit) and spookyUnit:IsAlive() then
                    ParticleManager:SetParticleControl(spookyId,10, spookyUnit:GetAbsOrigin() + Vector(0,0,250))
                    return GameRules:GetGameTime() + 0.1
                end
                return        
            end
        })
        --End the spell after 8 seconds
        PudgeWarsMode:CreateTimer(DoUniqueString("spooky_rune"), {
            endTime = GameRules:GetGameTime() + 8,
            useGameTime = true,
            callback = function(reflex, args)
                --rune effect is over:
                --make sure the caster comes back, remove the particles, stop the sound, remove the spookyUnit 
                caster:SetAbsOrigin(tombLocation)
                ParticleManager:DestroyParticle(spookyId,false)
                StopSoundEvent("Hero_Phoenix.SunRay.Loop", spookyUnit)
                spookyUnit:Destroy()
                return        
            end
        })
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
    local rune_type = RandomInt(1,5)
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
    elseif rune_type==7 then
        --IMPORTANT: Dont call this for now!!!
       local rune = CreateUnitByName( "npc_dummy_rune_diretide", Vector(0,-1500,0), true, nil, nil, DOTA_TEAM_NOTEAM)
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
