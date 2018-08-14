function PudgeWarsMode:RuneHooked(unit, caster, rune_type)
	if rune_type == 1 then
		--Slows everybody with aura, give to the caster bonus movespeed.
		Notifications:TopToAll({text="HYPERSPEED RUNE!", duration=RUNE_TEXT_DURATION, style = {color = "Red"}})
		for _, hero in pairs(HeroList:GetAllHeroes()) do
			if hero == caster then
				hero:AddNewModifier(hero, nil, "modifier_rune_haste", {duration = RUNE_SLOW_DURATION}) 
			else
				hero:AddNewModifier(hero, nil, "modifier_slow_rune", {duration = RUNE_SLOW_DURATION})
			end
		end
	elseif rune_type == 2 then
		--Gold rune
		Notifications:Bottom(PlayerResource:GetPlayer(caster:GetPlayerID()), {text="You hooked a gold rune! +500 gold", duration=RUNE_TEXT_DURATION, style = {color = "Gold"}})
	elseif rune_type == 3 then
		--Ion Rune
		Notifications:TopToAll({text="SHIELD RUNE!", duration=RUNE_TEXT_DURATION, style = {color = "DodgerBlue"}})
		caster:AddNewModifier(caster, nil, "modifier_shield_rune", {duration = RUNE_SHIELD_DURATION})
	elseif rune_type == 4 then
		Notifications:TopToAll({text="FIRE RUNE!", duration=RUNE_TEXT_DURATION, style = {color = "Orange"}})
		caster:AddNewModifier(caster, nil, "modifier_fire_rune", {duration = RUNE_FIRE_DURATION})
	elseif rune_type == 5 then
		--Dynamite rune
		Notifications:TopToAll({text="DYNAMITE RUNE!", duration=RUNE_TEXT_DURATION, style = {color = "DarkRed"}})
		DynamiteRune(caster, 400, 10)
	elseif rune_type == 6 then
		Notifications:TopToAll({text="THUNDER RUNE!", duration=RUNE_TEXT_DURATION, style = {color = "Blue"}})
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
	ParticleManager:SetParticleControl(runeParticle, 4, Vector( runePos.x, runePos.y, runePos.z))
end

function PudgeWarsMode:SpawnRune()
	local runes = {
		"npc_dummy_rune_haste",
		"npc_dummy_rune_gold",
		"npc_dummy_rune_ion",
		"npc_dummy_rune_fire",
		"npc_dummy_rune_dynamite",
		"npc_dummy_rune_lightning",
--		"npc_dummy_rune_diretide",
	}
	local rune_type = RandomInt(1, #runes)

	local rune = CreateUnitByName(runes[rune_type], Vector(0, -1800, 0), true, nil, nil, DOTA_TEAM_NOTEAM)
	rune:AddNewModifier(rune, nil, "modifier_phased", {})
end
