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
	local ability = caster:FindAbilityByName(spell)
	ability:SetLevel(spell_level)
	diff = target:GetAbsOrigin() - caster:GetAbsOrigin()
	diff.z = 0
	caster:SetForwardVector(diff:Normalized())


	GameMode:CreateTimer(DoUniqueString("spawn"), {
		endTime = GameRules:GetGameTime() + 0.070,
		useGameTime = true,
		callback = function(reflex, args)
			--Cast ability on target, wait time_out seconds and check if spell was scuccesfull
			caster:CastAbilityOnTarget(target, ability, 0)

			GameMode:CreateTimer(DoUniqueString("spell"), {
				endTime = GameRules:GetGameTime() + time_out,
				useGameTime = true,
				callback = function(reflex, args)
					--after time_out seconds check if the spell has successfully been cast
					if IsValidEntity(caster) and caster:GetMana() >= mana and mana ~= 0 and spell ~= "" then
						--If it was not successfull, try it all again.
						print("[ABILITIES] WARNING: castSpell did not cast spell (Spell needs to have a mana cost) -- retrying : ")
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
	local ability = caster:FindAbilityByName(spell)
	ability:SetLevel(spell_level)

	--Wait two frames to let the NPC spawn
	GameMode:CreateTimer(DoUniqueString("spawn"), {
		endTime = GameRules:GetGameTime() + 0.070,
		useGameTime = true,
		callback = function(reflex, args)
			--Cast ability on target, wait time_out seconds and check if spell was scuccesfull
			if ability then
				caster:CastAbilityImmediately(ability, 0)
			end

			GameMode:CreateTimer(DoUniqueString("spell"), {
				endTime = GameRules:GetGameTime() + time_out,
				useGameTime = true,
				callback = function(reflex, args)
					--after time_out seconds check if the spell has successfully been cast
					if IsValidEntity(caster) and caster:GetMana() >= mana and mana ~= 0 and spell ~= "" then
						--If it was not successfull, try it all again.
						print("[ABILITIES] WARNING: castInstantSpell did not cast spell (Spell needs to have a mana cost) -- retrying : ")
						castInstantSpell(caster, spell, spell_level, time_out)
					end
					caster:Destroy()
				end
			})
		end
	})
end

function GameMode:KillTarget(caster, unit)
	dealDamage(caster, unit, unit:GetMaxHealth() + 1000)
end

function applyRupture(source, target)
	local hasStrygwyr = false
	local ruptureLevel = nil

	if source ~= nil and target ~= nil then
		if source:GetTeam() ~= target:GetTeam() then
			for i = 0, 5 do
				local item = source:GetItemInSlot(i)

				if item and IsValidEntity(item) and item:GetAbilityName() == 'item_strygwyr_claw' then
					ruptureLevel = item:GetLevel()
					hasStrygwyr = true
				end
			end

			if hasStrygwyr == true then
				ruptureUnit = CreateUnitByName("npc_pudgewars_rupture_dummy", target:GetAbsOrigin(), false, source, source, source:GetTeamNumber())

				if ruptureUnit then
					ruptureUnit:AddNewModifier(ruptureUnit, nil, "modifier_invulnerable", {})
					ruptureUnit:AddNewModifier(ruptureUnit, nil, "modifier_phased", {})
					local ruptureAbilityName = "pudge_wars_bloodseeker_rupture"
					ruptureUnit:AddAbility(ruptureAbilityName)
					ruptureAbility = ruptureUnit:FindAbilityByName(ruptureAbilityName)

					if ruptureAbility then
						ruptureAbility:SetLevel(ruptureLevel)
						ruptureUnit:CastAbilityOnTarget(target, ruptureAbility, 0)
					end

					return ruptureUnit
				end
			end
		end
	end

	return nil
end

function RevealUsed(keys)
	local targetUnit = keys.target_entities[1]
	local caster = keys.caster

	for i = 0, 5 do
		local item = caster:GetItemInSlot(i)
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

function WisdomTomeUsed(keys)
	local caster = keys.caster
	local casterLevel = caster:GetLevel()
	caster:AddExperience(_G.XP_PER_LEVEL_TABLE[casterLevel + 1] - _G.XP_PER_LEVEL_TABLE[casterLevel], false, false)
end

function DamageTomeUsed(keys)
	local caster = keys.caster
	local casterLevel = caster:GetLevel()
	local playerID = caster:GetPlayerOwnerID()

	if PudgeArray[playerID].damagetomes < 11 then
		local minDamage = caster:GetBaseDamageMin()
		local maxDamage = caster:GetBaseDamageMax()
		caster:SetBaseDamageMin(minDamage)
		caster:SetBaseDamageMax(maxDamage)
		local newMinDamage = caster:GetBaseDamageMin()
		local newMaxDamage = caster:GetBaseDamageMax()
		local damageDiff = newMinDamage - minDamage
		caster:SetBaseDamageMin(newMinDamage - 2 * damageDiff)
		caster:SetBaseDamageMax(newMaxDamage - 2 * damageDiff)
		local newNewMinDamage = caster:GetBaseDamageMin()
		local newNewMaxDamage = caster:GetBaseDamageMax()
		caster:SetBaseDamageMin(newNewMinDamage - (damageDiff - 25))
		caster:SetBaseDamageMax(newNewMaxDamage - (damageDiff - 25))

		for i = 0, 5 do
			local item = caster:GetItemInSlot(i)
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

function HealthTomeUsed(keys)

end

function SpawnBarrier(keys)
	local point = keys.target_points[1]
	local caster = keys.caster
	local level = keys.SpellLevel

	CreateUnitByName("npc_pudge_wars_barrier_" .. level, point, false, caster, caster, caster:GetTeam())
end

function OnTinyArm(keys)
	local caster = keys.caster
	local point = keys.target_points[1]
	local damage = keys.ability:GetSpecialValueFor("damage")
	local stun_duration = keys.ability:GetSpecialValueFor("stun_duration")

	if point.x < -1440 or point.x > 1440 then
		keys.ability:EndCooldown()
		return
	end

	-- don't go on cooldown if there aren't any units
	local entities = Entities:FindAllInSphere(caster:GetAbsOrigin(), 250)
	local count = 0

	for k, v in pairs(entities) do
		if string.find(v:GetClassname(), "pudge") or string.find(v:GetClassname(), "creep") then
			print(v:GetUnitName())
			if string.find(v:GetUnitName(), "pudge") or string.find(v:GetUnitName(), "mine") then
				count = count + 1
			end
		end
	end

	if count <= 1 then
		keys.ability:EndCooldown()
		return
	end

	--give them the ability and spawn dummy
	caster:AddAbility("tiny_arm")
	local abil = caster:FindAbilityByName("tiny_arm")
	abil:SetLevel(keys.ability:GetLevel())
	local targetUnit = CreateUnitByName("npc_tiny_arm_dummy", point, false, nil, nil, caster:GetTeam())

	Timers:CreateTimer(0.3, function()
		caster:RemoveAbility("tiny_arm")
		targetUnit:ForceKill(false)
	end)

	if keys.ability:GetLevel() == 5 then
		--start timer to stunf when target lands
		local startTime = GameRules:GetGameTime()
		Timers:CreateTimer(function()
			local entities = Entities:FindAllInSphere(point, 200)

			for key, ent in pairs(entities) do
				if (string.find(ent:GetClassname(), "pudge")) and (ent:HasModifier("modifier_tiny_toss")) then
					if ent:GetTeam() ~= caster:GetTeam() then
						ent:AddNewModifier(caster, nil, "modifier_stunned", { duration = stun_duration })
						dealDamage(caster, ent, damage)
					end

					return
				end
			end

			if GameRules:GetGameTime() - startTime > 10 then
				return
			else
				return 1.0
			end
		end)
	end
	--Execute the ability
	caster:CastAbilityOnTarget(targetUnit, abil, caster:GetPlayerOwnerID())
end

function OnGrapplingHook(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]

	caster:AddAbility("pudge_wars_grappling_hook"):SetLevel(keys.ability:GetLevel())
	local ab = caster:FindAbilityByName("pudge_wars_grappling_hook")

	local order = { UnitIndex = caster:entindex(), OrderType = DOTA_UNIT_ORDER_CAST_POSITION, Position = targetPoint, AbilityIndex = ab:entindex() }
	ExecuteOrderFromTable(order)

	--start timer to remove ability
	Timers:CreateTimer(5.5, function()
		caster:RemoveAbility("pudge_wars_grappling_hook")
	end)
end

function OnAbilitiesUp(keys)
	local caster = keys.caster

	if not caster:FindAbilityByName(caster.ab2) then
		caster.ab2 = "techies_explosive_barrel_detonate"
	end

	if not caster:FindAbilityByName(caster.ab3) then
		caster.ab3 = "grappling_hook_blink"
	end

	if not caster:FindAbilityByName(caster.ab4) then
		caster.ab4 = "earthshaker_totem_fissure"
	end

	caster:SwapAbilities("pudge_wars_meat_hook", "pudge_wars_upgrade_hook_damage", false, true)
	caster:SwapAbilities(caster.ab2, "pudge_wars_upgrade_hook_range", false, true)
	caster:SwapAbilities(caster.ab3, "pudge_wars_upgrade_hook_speed", false, true)
	caster:SwapAbilities(caster.ab4, "pudge_wars_upgrade_hook_size", false, true)
	caster:SwapAbilities("pudge_wars_abilities_up", "pudge_wars_abilities_down", false, true)
end

function OnAbilitiesDown(keys)
	local caster = keys.caster

	caster:SwapAbilities("pudge_wars_meat_hook", "pudge_wars_upgrade_hook_damage", true, false)
	caster:SwapAbilities(caster.ab2, "pudge_wars_upgrade_hook_range", true, false)
	caster:SwapAbilities(caster.ab3, "pudge_wars_upgrade_hook_speed", true, false)
	caster:SwapAbilities(caster.ab4, "pudge_wars_upgrade_hook_size", true, false)
	caster:SwapAbilities("pudge_wars_abilities_up", "pudge_wars_abilities_down", true, false)
end

function OnTechiesExplosiveBarrelDetonate(keys)
	local caster = keys.caster

	DynamiteRune(caster, 200, -1, false)
end

function DynamiteRune(caster, radius_explosion, delay, bTargetAlly, damage)
	local i = delay + 1
	if damage == nil then damage = 100000 end

	caster:AddNewModifier(caster, nil, "modifier_silenced", { duration = delay })

	Timers:CreateTimer(function()
		if i >= 1 then
			i = i - 1

			if i <= 2 then
				Notifications:TopToAll({ text = "Dynamite rune: " .. i + 1, duration = 1.0 })
				caster:EmitSound('Ability.XMark.Target_Movement')
			end

			return 1.0
		else
			local center_vec = caster:GetAbsOrigin()
			local team_target = DOTA_UNIT_TARGET_TEAM_ENEMY
			if bTargetAlly == true then
				team_target = DOTA_UNIT_TARGET_TEAM_BOTH
			end
			local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius_explosion, team_target, DOTA_UNIT_TARGET_HERO, DOTA_DAMAGE_FLAG_NONE, FIND_ANY_ORDER, false)

			for k, v in pairs(units) do
				if IsValidEntity(v) and string.find(v:GetClassname(), "pudge") and v ~= caster then
					dealDamage(caster, v, damage)
					local headshotParticle = ParticleManager:CreateParticle('particles/units/heroes/hero_tinker/tinker_missle_explosion.vpcf', PATTACH_ABSORIGIN, v)
					local headshotPos = v:GetOrigin()
					ParticleManager:SetParticleControl(headshotParticle, 4, Vector(headshotPos.x, headshotPos.y, headshotPos.z))
				end
			end

			caster:EmitSound('Hero_Alchemist.UnstableConcoction.Stun')

			--Kill pudge last to give him all EXP and stuff
			if bTargetAlly == true then
				dealDamage(caster, caster, damage)
				local headshotParticle = ParticleManager:CreateParticle('particles/units/heroes/hero_tinker/tinker_missle_explosion.vpcf', PATTACH_ABSORIGIN, caster)
				local headshotPos = caster:GetOrigin()
				ParticleManager:SetParticleControl(headshotParticle, 4, Vector(headshotPos.x, headshotPos.y, headshotPos.z))
			end

			-- remove the mine
			caster:ForceKill(false)

			return nil
		end
	end)
end

function MineSuicide(keys)
	local caster = keys.caster
	caster:ForceKill(false)
	caster:EmitSound('Hero_Alchemist.UnstableConcoction.Stun')
end
